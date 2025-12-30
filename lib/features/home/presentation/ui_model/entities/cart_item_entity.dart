import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:pharma_now/core/enitites/medicine_entity.dart';

part 'cart_item_entity.g.dart';

@JsonSerializable(explicitToJson: true)
class CartItemEntity extends Equatable {
  @JsonKey(
    toJson: _medicineToJson,
    fromJson: _medicineFromJson,
  )
  final MedicineEntity medicineEntity;
  final int count;

  static Map<String, dynamic> _medicineToJson(MedicineEntity medicine) =>
      medicine.toJson();
  static MedicineEntity _medicineFromJson(Map<String, dynamic> json) =>
      MedicineEntity.fromJson(json);

  const CartItemEntity({
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

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => _$CartItemEntityToJson(this);

  // Create from JSON from Firestore
  factory CartItemEntity.fromJson(Map<String, dynamic> json) =>
      _$CartItemEntityFromJson(json);
}
