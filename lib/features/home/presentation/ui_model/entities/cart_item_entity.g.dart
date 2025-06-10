// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemEntity _$CartItemEntityFromJson(Map<String, dynamic> json) =>
    CartItemEntity(
      medicineEntity: CartItemEntity._medicineFromJson(
          json['medicineEntity'] as Map<String, dynamic>),
      count: (json['count'] as num).toInt(),
    );

Map<String, dynamic> _$CartItemEntityToJson(CartItemEntity instance) =>
    <String, dynamic>{
      'medicineEntity': CartItemEntity._medicineToJson(instance.medicineEntity),
      'count': instance.count,
    };
