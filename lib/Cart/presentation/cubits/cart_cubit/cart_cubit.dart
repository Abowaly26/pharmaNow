import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_entity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

import '../../../../core/enitites/medicine_entity.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartInitial(cartEntity: const CartEntity(cartItems: [])));

  void addMedicineToCart(MedicineEntity medicineEntity) {
    if (state is! CartLoaded && state is! CartInitial) return; // Should not happen if initialized correctly

    final currentCartEntity = (state as dynamic).cartEntity as CartEntity;
    
    CartItemEntity? existingCartItem = currentCartEntity.getCartItem(medicineEntity);
    CartEntity newCartEntity;

    if (existingCartItem != null) {
      // Medicine exists, increase count
      final updatedItem = existingCartItem.copyWith(count: existingCartItem.count + 1);
      // Replace the old item with the updated one
      final newCartItems = List<CartItemEntity>.from(currentCartEntity.cartItems);
      final itemIndex = newCartItems.indexWhere((item) => item.medicineEntity.code == medicineEntity.code);
      if (itemIndex != -1) {
        newCartItems[itemIndex] = updatedItem;
      }
      newCartEntity = currentCartEntity.copyWith(cartItems: newCartItems); // Assuming CartEntity has copyWith
    } else {
      // Medicine does not exist, add new item
      final newCartItem = CartItemEntity(medicineEntity: medicineEntity, count: 1);
      newCartEntity = currentCartEntity.addCartItem(newCartItem);
    }
    emit(CartItemAdded(cartEntity: newCartEntity));
  }

  void deleteMedicineFromCart(CartItemEntity cartItem) {
    if (state is! CartLoaded && state is! CartInitial) return;

    final currentCartEntity = (state as dynamic).cartEntity as CartEntity;
    final newCartEntity = currentCartEntity.deleteCartItemFromCart(cartItem);
    emit(CartItemRemoved(cartEntity: newCartEntity));
  }

  // Helper method to update quantity (increase/decrease)
  void updateCartItemQuantity(CartItemEntity cartItem, int newQuantity) {
    if (state is! CartLoaded && state is! CartInitial) return;
    if (newQuantity <= 0) {
      deleteMedicineFromCart(cartItem);
      return;
    }

    final currentCartEntity = (state as dynamic).cartEntity as CartEntity;
    final itemIndex = currentCartEntity.cartItems.indexWhere((item) => item.medicineEntity.code == cartItem.medicineEntity.code);

    if (itemIndex != -1) {
      final updatedItem = currentCartEntity.cartItems[itemIndex].copyWith(count: newQuantity);
      final newCartItems = List<CartItemEntity>.from(currentCartEntity.cartItems);
      newCartItems[itemIndex] = updatedItem;
      final newCartEntity = currentCartEntity.copyWith(cartItems: newCartItems); // Assuming CartEntity has copyWith
      emit(CartLoaded(cartEntity: newCartEntity));
    }
  }
}
