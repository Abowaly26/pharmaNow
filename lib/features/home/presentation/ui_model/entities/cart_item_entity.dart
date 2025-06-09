import 'package:equatable/equatable.dart';
import 'package:pharma_now/core/enitites/medicine_entity.dart';

class CartItemEntity extends Equatable {
  final MedicineEntity medicineEntity;
  final int count;

  CartItemEntity({
    required this.medicineEntity,
    required this.count,
  });

  num calculateTotalPrice() {
    return medicineEntity.price * count;
  }

  CartItemEntity copyWith({
    MedicineEntity? medicineEntity,
    int? count,
  }) {
    return CartItemEntity(
      medicineEntity: medicineEntity ?? this.medicineEntity,
      count: count ?? this.count,
    );
  }

  @override
  List<Object?> get props => [medicineEntity, count];
}
