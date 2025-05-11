import 'package:pharma_now/core/enitites/review_entity.dart';

class MedicineEntity {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final num price;
  String? subabaseORImageUrl;
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
