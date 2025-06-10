// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewEntity _$ReviewEntityFromJson(Map<String, dynamic> json) => ReviewEntity(
      name: json['name'] as String,
      image: json['image'] as String,
      rating: json['rating'] as num,
      date: json['date'] as String,
      reviewDescription: json['reviewDescription'] as String,
    );

Map<String, dynamic> _$ReviewEntityToJson(ReviewEntity instance) =>
    <String, dynamic>{
      'name': instance.name,
      'image': instance.image,
      'rating': instance.rating,
      'date': instance.date,
      'reviewDescription': instance.reviewDescription,
    };
