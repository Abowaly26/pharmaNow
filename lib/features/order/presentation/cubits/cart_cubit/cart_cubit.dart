import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/errors/error_handling.dart';
import 'package:pharma_now/features/cart/domain/repositories/cart_repository.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(CartInitial(cartEntity: const CartEntity(cartItems: []))) {
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      emit(CartLoading(cartEntity: state.cartEntity));
      final result =
          await _cartRepository.getCart().timeout(const Duration(seconds: 5));
      result.fold(
        (failure) => emit(CartError(
          message: failure is NetworkFailure
              ? 'No internet connection'
              : (failure is ServerFailure
                  ? 'Server error, please try again'
                  : 'Failed to load cart'),
          cartEntity: state.cartEntity,
        )),
        (cart) => emit(CartLoaded(cartEntity: cart)),
      );
    } catch (e) {
      emit(CartError(
        message: e is TimeoutException
            ? 'Connection timed out, check internet'
            : 'An unexpected error occurred',
        cartEntity: state.cartEntity,
      ));
    }
  }

  Future<void> _saveCart(CartEntity cart,
      {String? medicineId, CartEntity? previousCartEntity}) async {
    try {
      final result = await _cartRepository
          .saveCart(cart)
          .timeout(const Duration(seconds: 5));
      result.fold(
        (failure) {
          final newLoadingIds = Set<String>.from(state.loadingMedicineIds);
          if (medicineId != null) newLoadingIds.remove(medicineId);

          // ROLLBACK: Use previousCartEntity if available, otherwise fallback to current state
          // (though current state might be the "new" incorrect one in optimistic cases, so previous is key)
          final rollbackEntity = previousCartEntity ?? state.cartEntity;

          emit(CartError(
            message: failure is NetworkFailure
                ? 'No internet connection'
                : 'Failed to add to cart',
            cartEntity: rollbackEntity,
            loadingMedicineIds: newLoadingIds,
          ));
        },
        (_) {
          if (medicineId != null) {
            final newLoadingIds = Set<String>.from(state.loadingMedicineIds);
            newLoadingIds.remove(medicineId);
            emit(CartItemAdded(
              cartEntity: cart,
              loadingMedicineIds: newLoadingIds,
            ));
          }
        },
      );
    } catch (e) {
      final newLoadingIds = Set<String>.from(state.loadingMedicineIds);
      if (medicineId != null) newLoadingIds.remove(medicineId);

      final rollbackEntity = previousCartEntity ?? state.cartEntity;

      emit(CartError(
        message: e is TimeoutException
            ? 'Connection timed out, check internet'
            : 'Failed to save cart',
        cartEntity: rollbackEntity,
        loadingMedicineIds: newLoadingIds,
      ));
    }
  }

  void addMedicineToCart(MedicineEntity medicineEntity) async {
    if (state is CartLoading) {
      return;
    }

    final currentCartEntity = state.cartEntity;
    final medicineId = medicineEntity.code;

    // Add to loading state
    final newLoadingIds = Set<String>.from(state.loadingMedicineIds)
      ..add(medicineId);
    emit(CartLoaded(
      cartEntity: currentCartEntity,
      loadingMedicineIds: newLoadingIds,
    ));

    CartItemEntity? existingCartItem =
        currentCartEntity.getCartItem(medicineEntity);
    CartEntity newCartEntity;

    if (existingCartItem != null) {
      // Medicine exists, increase count
      final updatedItem =
          existingCartItem.copyWith(count: existingCartItem.count + 1);
      final newCartItems =
          List<CartItemEntity>.from(currentCartEntity.cartItems);
      final itemIndex = newCartItems.indexWhere(
          (item) => item.medicineEntity.code == medicineEntity.code);
      if (itemIndex != -1) {
        newCartItems[itemIndex] = updatedItem;
      }
      newCartEntity = currentCartEntity.copyWith(cartItems: newCartItems);
    } else {
      // Medicine does not exist, add new item
      final newCartItem =
          CartItemEntity(medicineEntity: medicineEntity, count: 1);
      newCartEntity = currentCartEntity.addCartItem(newCartItem);
    }

    await _saveCart(newCartEntity,
        medicineId: medicineId, previousCartEntity: currentCartEntity);
  }

  void deleteMedicineFromCart(CartItemEntity cartItem) async {
    if (state is CartLoading) return;

    final medicineId = cartItem.medicineEntity.code;
    final currentCartEntity = state.cartEntity;

    // Add to deleting state for optimistic UI / loading
    final newDeletingIds = Set<String>.from(state.deletingMedicineIds)
      ..add(medicineId);
    emit(CartLoaded(
      cartEntity: currentCartEntity,
      loadingMedicineIds: state.loadingMedicineIds,
      deletingMedicineIds: newDeletingIds,
    ));

    final newCartEntity = currentCartEntity.deleteCartItemFromCart(cartItem);

    try {
      final result = await _cartRepository
          .saveCart(newCartEntity)
          .timeout(const Duration(seconds: 5));
      result.fold(
        (failure) {
          final updatedDeletingIds = Set<String>.from(state.deletingMedicineIds)
            ..remove(medicineId);
          emit(CartError(
            message: failure is NetworkFailure
                ? 'No internet connection'
                : 'Failed to delete item',
            cartEntity: currentCartEntity,
            loadingMedicineIds: state.loadingMedicineIds,
            deletingMedicineIds: updatedDeletingIds,
          ));
        },
        (_) {
          final updatedDeletingIds = Set<String>.from(state.deletingMedicineIds)
            ..remove(medicineId);
          emit(CartItemRemoved(
            removedItem: cartItem,
            cartEntity: newCartEntity,
            loadingMedicineIds: state.loadingMedicineIds,
            deletingMedicineIds: updatedDeletingIds,
          ));
        },
      );
    } catch (e) {
      final updatedDeletingIds = Set<String>.from(state.deletingMedicineIds)
        ..remove(medicineId);
      emit(CartError(
        message: e is TimeoutException
            ? 'Connection timed out, check internet'
            : 'Failed to delete item',
        cartEntity: currentCartEntity,
        loadingMedicineIds: state.loadingMedicineIds,
        deletingMedicineIds: updatedDeletingIds,
      ));
    }
  }

  void undoDeleteMedicine(CartItemEntity cartItem) {
    addMedicineToCartWithCount(cartItem.medicineEntity, cartItem.count);
  }

  // Helper method to update quantity (increase/decrease)
  void updateCartItemQuantity(CartItemEntity cartItem, int newQuantity) {
    if (state is CartLoading) return;
    if (newQuantity <= 0) {
      deleteMedicineFromCart(cartItem);
      return;
    }

    final currentCartEntity = state.cartEntity;
    final itemIndex = currentCartEntity.cartItems.indexWhere(
        (item) => item.medicineEntity.code == cartItem.medicineEntity.code);

    if (itemIndex != -1) {
      final updatedItem =
          currentCartEntity.cartItems[itemIndex].copyWith(count: newQuantity);
      final newCartItems =
          List<CartItemEntity>.from(currentCartEntity.cartItems);
      newCartItems[itemIndex] = updatedItem;
      final newCartEntity = currentCartEntity.copyWith(cartItems: newCartItems);

      // OPTIMISTIC UPDATE
      emit(CartLoaded(cartEntity: newCartEntity));

      _saveCart(newCartEntity, previousCartEntity: currentCartEntity);
    }
  }

  void addMedicineToCartWithCount(
      MedicineEntity medicineEntity, int count) async {
    if (state is CartLoading) return;

    final currentCartEntity = state.cartEntity;
    final medicineId = medicineEntity.code;

    // Add to loading state
    final newLoadingIds = Set<String>.from(state.loadingMedicineIds)
      ..add(medicineId);
    emit(CartLoaded(
      cartEntity: currentCartEntity,
      loadingMedicineIds: newLoadingIds,
    ));

    CartItemEntity? existingCartItem =
        currentCartEntity.getCartItem(medicineEntity);
    CartEntity newCartEntity;

    if (existingCartItem != null) {
      // Medicine exists, update count
      final updatedItem =
          existingCartItem.copyWith(count: existingCartItem.count + count);
      final newCartItems =
          List<CartItemEntity>.from(currentCartEntity.cartItems);
      final itemIndex = newCartItems.indexWhere(
          (item) => item.medicineEntity.code == medicineEntity.code);
      if (itemIndex != -1) {
        newCartItems[itemIndex] = updatedItem;
      }
      newCartEntity = currentCartEntity.copyWith(cartItems: newCartItems);
    } else {
      // Medicine does not exist, add new item with count
      final newCartItem =
          CartItemEntity(medicineEntity: medicineEntity, count: count);
      newCartEntity = currentCartEntity.addCartItem(newCartItem);
    }

    await _saveCart(newCartEntity,
        medicineId: medicineId, previousCartEntity: currentCartEntity);
  }

  /// Clear the entire cart
  Future<void> clearCart() async {
    try {
      emit(CartLoading(cartEntity: state.cartEntity));
      final result =
          await _cartRepository.clearCart().timeout(const Duration(seconds: 5));
      result.fold(
        (failure) => emit(CartError(
          message: failure is NetworkFailure
              ? 'No internet connection'
              : 'Failed to clear cart',
          cartEntity: state.cartEntity,
        )),
        (_) => emit(CartLoaded(cartEntity: const CartEntity(cartItems: []))),
      );
    } catch (e) {
      emit(CartError(
        message: e is TimeoutException
            ? 'Connection timed out, check internet'
            : 'Failed to clear cart',
        cartEntity: state.cartEntity,
      ));
    }
  }

  /// Reset the cubit state to initial (empty cart)
  void reset() {
    emit(CartInitial(cartEntity: const CartEntity(cartItems: [])));
  }
}
