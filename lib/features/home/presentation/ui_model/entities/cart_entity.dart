import 'package:pharma_now/core/enitites/medicine_entity.dart';

import 'cart_item_entity.dart';

class CartEntity {
  final List<CartItemEntity> cartItems;
  CartEntity({required this.cartItems});

  addCartItem(CartItemEntity cartItemEntity) {
    cartItems.add(cartItemEntity);
  }

  isExist(MedicineEntity medicineEntity) {
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
}
