import 'package:equatable/equatable.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';

import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> cartItems;
  const CartEntity({required this.cartItems});

  CartEntity addCartItem(CartItemEntity cartItemEntity) {
    final newCartItems = List<CartItemEntity>.from(cartItems)
      ..add(cartItemEntity);
    return CartEntity(cartItems: newCartItems);
  }

  CartEntity deleteCartItemFromCart(CartItemEntity cartItem) {
    final newCartItems = List<CartItemEntity>.from(cartItems)..remove(cartItem);
    return CartEntity(cartItems: newCartItems);
  }

  bool isExist(MedicineEntity medicineEntity) {
    for (var element in cartItems) {
      if (element.medicineEntity == medicineEntity) {
        return true;
      }
    }
    return false;
  }

  CartItemEntity? getCartItem(MedicineEntity medicineEntity) {
    for (var element in cartItems) {
      if (element.medicineEntity == medicineEntity) {
        return element;
      }
    }
    return null; // Return null if not found, CartCubit will handle creation
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var element in cartItems) {
      totalPrice += element.calculateTotalPrice();
    }
    return totalPrice;
  }

  @override
  List<Object?> get props => [cartItems];

  CartEntity copyWith({
    List<CartItemEntity>? cartItems,
  }) {
    return CartEntity(
      cartItems: cartItems ?? this.cartItems,
    );
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(2).replaceAll(RegExp(r'\.0+$'), '');
  }

  // Helper method to calculate the discounted price
  String calculateDiscountedPrice(
      double originalPrice, double discountPercentage) {
    double discountAmount = originalPrice * (discountPercentage / 100);
    double discountedPrice = originalPrice - discountAmount;
    return formatPrice(discountedPrice);
  }
}
