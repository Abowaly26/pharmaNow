// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineEntity _$MedicineEntityFromJson(Map<String, dynamic> json) =>
    MedicineEntity(
      discountRating: (json['discountRating'] as num).toInt(),
      reviews: (json['reviews'] as List<dynamic>)
          .map((e) => ReviewEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      pharmacyName: json['pharmacyName'] as String,
      pharmacyId: (json['pharmacyId'] as num).toInt(),
      pharmcyAddress: json['pharmcyAddress'] as String,
      subabaseORImageUrl: json['subabaseORImageUrl'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      code: json['code'] as String,
      quantity: (json['quantity'] as num).toInt(),
      isNewProduct: json['isNewProduct'] as bool,
      price: json['price'] as num,
      sellingCount: json['sellingCount'] as num,
      avgRating: json['avgRating'] as num? ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MedicineEntityToJson(MedicineEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'code': instance.code,
      'quantity': instance.quantity,
      'isNewProduct': instance.isNewProduct,
      'price': instance.price,
      'subabaseORImageUrl': instance.subabaseORImageUrl,
      'pharmacyName': instance.pharmacyName,
      'pharmacyId': instance.pharmacyId,
      'pharmcyAddress': instance.pharmcyAddress,
      'avgRating': instance.avgRating,
      'ratingCount': instance.ratingCount,
      'sellingCount': instance.sellingCount,
      'reviews': instance.reviews.map((e) => e.toJson()).toList(),
      'discountRating': instance.discountRating,
    };
