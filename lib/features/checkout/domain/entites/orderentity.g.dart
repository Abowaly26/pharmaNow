// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orderentity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderEntity _$OrderEntityFromJson(Map<String, dynamic> json) => OrderEntity(
      orderId: json['orderId'] as String?,
      cartItem: (json['cartItem'] as List<dynamic>)
          .map((e) => CartItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      payWithCash: json['payWithCash'] as bool,
      shippingAddressEntity: ShippingAddressEntity.fromJson(
          json['shippingAddressEntity'] as Map<String, dynamic>),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderStatus: json['orderStatus'] as String? ?? 'pending',
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String?,
    );

Map<String, dynamic> _$OrderEntityToJson(OrderEntity instance) =>
    <String, dynamic>{
      'orderId': instance.orderId,
      'cartItem': instance.cartItem.map((e) => e.toJson()).toList(),
      'payWithCash': instance.payWithCash,
      'shippingAddressEntity': instance.shippingAddressEntity.toJson(),
      'subtotal': instance.subtotal,
      'deliveryFee': instance.deliveryFee,
      'totalAmount': instance.totalAmount,
      'orderStatus': instance.orderStatus,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };
