import 'dart:io';

import 'package:pharma_now/core/enitites/review_entity.dart';

class MedicineEntity {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final File image;
  final num price;
  String? imageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating = 0;
  final int ratingCount = 0;
  final List<ReviewEntity> reviews;

  MedicineEntity({
    required this.reviews,
    required this.pharmacyName,
    required this.pharmacyId,
    required this.pharmcyAddress,
    this.imageUrl,
    required this.name,
    required this.description,
    required this.code,
    required this.quantity,
    required this.isNewProduct,
    required this.image,
    required this.price,
    required String pharmacyAddress,
    required num sellingCount,
  });
}
