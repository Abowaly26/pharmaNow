import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:pharma_now/features/cart/domain/repositories/cart_repository.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepository _cartRepository;

  CartCubit({required CartRepository cartRepository})
      : _cartRepository = cartRepository,
        super(CartInitial(cartEntity: const CartEntity(cartItems: []))) {
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      emit(CartLoading(cartEntity: state.cartEntity));
      final result = await _cartRepository.getCart();
      result.fold(
        (failure) => emit(CartError(
          message:
              failure is ServerFailure ? 'Server error' : 'Failed to load cart',
          cartEntity: state.cartEntity,
        )),
        (cart) => emit(CartLoaded(cartEntity: cart)),
      );
    } catch (e) {
      emit(CartError(
        message: 'An unexpected error occurred',
        cartEntity: state.cartEntity,
      ));
    }
  }

  Future<void> _saveCart(CartEntity cart, {String? medicineId}) async {
    try {
      final result = await _cartRepository.saveCart(cart);
      result.fold(
        (failure) {
          final newLoadingIds = Set<String>.from(state.loadingMedicineIds);
          if (medicineId != null) newLoadingIds.remove(medicineId);
          emit(CartError(
            message: failure is ServerFailure
                ? 'Failed to save cart'
                : 'An error occurred',
            cartEntity: cart,
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
      emit(CartError(
        message: 'Failed to save cart',
        cartEntity: cart,
        loadingMedicineIds: newLoadingIds,
      ));
    }
  }

  void addMedicineToCart(MedicineEntity medicineEntity) async {
    if (state is! CartLoaded && state is! CartInitial) {
      return; // Should not happen if initialized correctly
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

    await _saveCart(newCartEntity, medicineId: medicineId);
  }

  void deleteMedicineFromCart(CartItemEntity cartItem) {
    if (state is! CartLoaded && state is! CartInitial) return;

    final currentCartEntity = state.cartEntity;
    final newCartEntity = currentCartEntity.deleteCartItemFromCart(cartItem);
    emit(CartItemRemoved(cartEntity: newCartEntity));
    _saveCart(newCartEntity);
  }

  // Helper method to update quantity (increase/decrease)
  void updateCartItemQuantity(CartItemEntity cartItem, int newQuantity) {
    if (state is! CartLoaded && state is! CartInitial) return;
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
      emit(CartLoaded(cartEntity: newCartEntity));
      _saveCart(newCartEntity);
    }
  }

  void addMedicineToCartWithCount(
      MedicineEntity medicineEntity, int count) async {
    if (state is! CartLoaded && state is! CartInitial) return;

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

    await _saveCart(newCartEntity, medicineId: medicineId);
  }

  /// Clear the entire cart
  Future<void> clearCart() async {
    try {
      emit(CartLoading(cartEntity: state.cartEntity));
      final result = await _cartRepository.clearCart();
      result.fold(
        (failure) => emit(CartError(
          message: failure is ServerFailure
              ? 'Failed to clear cart'
              : 'An error occurred',
          cartEntity: state.cartEntity,
        )),
        (_) => emit(CartLoaded(cartEntity: const CartEntity(cartItems: []))),
      );
    } catch (e) {
      emit(CartError(
        message: 'Failed to clear cart',
        cartEntity: state.cartEntity,
      ));
    }
  }

  /// Reset the cubit state to initial (empty cart)
  void reset() {
    emit(CartInitial(cartEntity: const CartEntity(cartItems: [])));
  }
}
