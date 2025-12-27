import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pharma_now/core/enitites/review_entity.dart';

part 'medicine_entity.g.dart';

// Enum to represent the stock status, making the logic cleaner and more readable.
enum StockStatus { inStock, lowStock, outOfStock }

@JsonSerializable(explicitToJson: true)
class MedicineEntity extends Equatable {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final num price;
  @JsonKey()
  final String? subabaseORImageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating;
  final int ratingCount;
  final num sellingCount;
  final List<ReviewEntity> reviews;
  final int discountRating;

  MedicineEntity({
    required this.discountRating,
    required this.reviews,
    required this.pharmacyName,
    required this.pharmacyId,
    required this.pharmcyAddress,
    this.subabaseORImageUrl,
    required this.name,
    required this.description,
    required this.code,
    required this.quantity,
    required this.isNewProduct,
    required this.price,
    required this.sellingCount,
    this.avgRating = 0,
    this.ratingCount = 0,
  });

  @override
  List<Object?> get props => [code];

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => _$MedicineEntityToJson(this);

  // Create from JSON from Firestore
  factory MedicineEntity.fromJson(Map<String, dynamic> json) =>
      _$MedicineEntityFromJson(json);

  @override
  String toString() {
    return 'MedicineEntity(code: $code, name: $name, pharmcyAddress: $pharmcyAddress)';
  }
}

// class MedicineEntity {
//   final String name;
//   final String description;
//   final String code;
//   final int quantity;
//   final bool isNewProduct;

//   final num price;
//   String? subabaseORImageUrl;
//   final String pharmacyName;
//   final int pharmacyId;
//   final String pharmcyAddress;
//   final num avgRatting = 0;
//   final int rattingCount = 0;
//   final List<ReviewEntity> reviews;
//   final int discountRating;

//   MedicineEntity({
//     required this.discountRating,
//     required this.reviews,
//     required this.pharmacyName,
//     required this.pharmacyId,
//     required this.pharmcyAddress,
//     this.subabaseORImageUrl,
//     required this.name,
//     required this.description,
//     required this.code,
//     required this.quantity,
//     required this.isNewProduct,
//     required this.price,
//     required num sellingCount,
//   });
// }
