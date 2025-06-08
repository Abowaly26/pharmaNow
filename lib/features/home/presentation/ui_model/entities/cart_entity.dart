import 'package:equatable/equatable.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';

import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> cartItems;
  CartEntity({required this.cartItems});

  addCartItem(CartItemEntity cartItemEntity) {
    cartItems.add(cartItemEntity);
  }

  deleteCartItemFromCart(CartItemEntity carItem) {
    cartItems.remove(carItem);
  }

  bool isExist(MedicineEntity medicineEntity) {
    for (var element in cartItems) {
      if (element.medicineEntity == medicineEntity) {
        return true;
      }
    }
    return false;
  }

  CartItemEntity getCartItem(MedicineEntity medicineEntity) {
    for (var element in cartItems) {
      if (element.medicineEntity == medicineEntity) {
        return element;
      }
    }
    return CartItemEntity(medicineEntity: medicineEntity, count: 1);
  }

  double calculateTotalPrice() {
    double totalPrice = 0;
    for (var element in cartItems) {
      totalPrice += element.calculateTotalPrice();
    }
    return totalPrice;
  }

  @override
  List<Object?> get props => [MedicineEntity];
}
