import 'dart:io';

import 'package:pharma_now/core/models/review_model.dart';

import '../enitites/medicine_entity.dart';

class MedicineModel {
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
  final num sellingCount;

  final List<ReviewModel> reviews;

  MedicineModel({
    required this.sellingCount,
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
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      name: json['name'],
      description: json['description'],
      code: json['code'],
      quantity: json['quantity'],
      isNewProduct: json['isNewProduct'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      pharmacyName: json['pharmacyName'],
      pharmacyId: json['pharmacyId'],
      pharmcyAddress: json['pharmcyAddress'],
      reviews: json['reviews'] != null
          ? json['reviews'].map((e) => ReviewModel.fromJson(e)) //.toList()
          : [],
      sellingCount: json['sellingCount'],
      image: File(json['image']),
    );
  }

  MedicineEntity toEntity() {
    return MedicineEntity(
      name: name,
      description: description,
      code: code,
      quantity: quantity,
      isNewProduct: isNewProduct,
      price: price,
      imageUrl: imageUrl,
      pharmacyName: pharmacyName,
      pharmacyId: pharmacyId,
      pharmcyAddress: pharmcyAddress,
      reviews: reviews.map((e) => e.toEntity()).toList(),
      sellingCount: sellingCount,
      image: image,
      pharmacyAddress: pharmcyAddress,
    );
  }

  toJson() {
    return {
      'name': name,
      'description': description,
      'code': code,
      'quantity': quantity,
      'isNewProduct': isNewProduct,
      'price': price,
      'imageUrl': imageUrl,
      'pharmacyName': pharmacyName,
      'pharmacyId': pharmacyId,
      'pharmcyAddress': pharmcyAddress,
      'reviews': reviews.map((e) => e.toJson()).toList(),
    };
  }
}
