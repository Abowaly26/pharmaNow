import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'shipingadressentity.g.dart';

@JsonSerializable(explicitToJson: true)
class ShippingAddressEntity extends Equatable {
  final String namee;
  final String email;
  final String address;
  final String city;
  final String apartmentNumber;
  final String phoneNumber;

  const ShippingAddressEntity({
    required this.namee,
    required this.email,
    required this.address,
    required this.city,
    required this.apartmentNumber,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [
        namee,
        email,
        address,
        city,
        apartmentNumber,
        phoneNumber,
      ];

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() => _$ShippingAddressEntityToJson(this);

  // Create from JSON from Firestore
  factory ShippingAddressEntity.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressEntityFromJson(json);

  ShippingAddressEntity copyWith({
    String? namee,
    String? email,
    String? address,
    String? city,
    String? apartmentNumber,
    String? phoneNumber,
  }) {
    return ShippingAddressEntity(
      namee: namee ?? this.namee,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
