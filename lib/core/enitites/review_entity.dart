import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'review_entity.g.dart';

@JsonSerializable()
class ReviewEntity extends Equatable {
  final String name;
  final String image;
  final num rating;
  final String date;
  final String reviewDescription;

  const ReviewEntity({
    required this.name,
    required this.image,
    required this.rating,
    required this.date,
    required this.reviewDescription,
  });

  @override
  List<Object> get props => [name, image, rating, date, reviewDescription];

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => _$ReviewEntityToJson(this);

  // Create from JSON from Firestore
  factory ReviewEntity.fromJson(Map<String, dynamic> json) => 
      _$ReviewEntityFromJson(json);
}
