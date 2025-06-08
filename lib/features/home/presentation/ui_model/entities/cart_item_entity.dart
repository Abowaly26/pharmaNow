import 'package:pharma_now/core/enitites/medicine_entity.dart';

class CartItemEntity {
  final MedicineEntity medicineEntity;
  int count;

  CartItemEntity({
    required this.medicineEntity,
    required this.count,
  });

  num calculateTotalPrice() {
    return medicineEntity.price * count;
  }

  increaseCount() {
    count++;
  }

  decreaseCount() {
    count--;
  }
}
