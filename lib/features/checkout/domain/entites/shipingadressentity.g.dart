// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipingadressentity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingAddressEntity _$ShippingAddressEntityFromJson(
        Map<String, dynamic> json) =>
    ShippingAddressEntity(
      namee: json['namee'] as String,
      email: json['email'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      apartmentNumber: json['apartmentNumber'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$ShippingAddressEntityToJson(
        ShippingAddressEntity instance) =>
    <String, dynamic>{
      'namee': instance.namee,
      'email': instance.email,
      'address': instance.address,
      'city': instance.city,
      'apartmentNumber': instance.apartmentNumber,
      'phoneNumber': instance.phoneNumber,
    };
