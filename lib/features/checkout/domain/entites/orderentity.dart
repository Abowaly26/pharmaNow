import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pharma_now/features/checkout/domain/entites/shipingadressentity.dart';
import 'package:pharma_now/features/home/presentation/ui_model/entities/cart_item_entity.dart';

part 'orderentity.g.dart';

@JsonSerializable(explicitToJson: true)
class OrderEntity extends Equatable {
  final String? orderId;
  final List<CartItemEntity> cartItem;
  final bool payWithCash;
  final ShippingAddressEntity shippingAddressEntity;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String orderStatus;
  final DateTime createdAt;
  final String? userId;
  final String? paymentProofUrl;
  final String? prescriptionUrl;
  final String? paymentMethodName;
  final String? senderWalletPhone;
  final String? pharmacyWalletNumber;

  OrderEntity({
    this.orderId,
    required this.cartItem,
    required this.payWithCash,
    required this.shippingAddressEntity,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    this.orderStatus = 'pending',
    DateTime? createdAt,
    this.userId,
    this.paymentProofUrl,
    this.prescriptionUrl,
    this.paymentMethodName,
    this.senderWalletPhone,
    this.pharmacyWalletNumber,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  List<Object?> get props => [
        orderId,
        cartItem,
        payWithCash,
        shippingAddressEntity,
        subtotal,
        deliveryFee,
        totalAmount,
        orderStatus,
        createdAt,
        userId,
        paymentProofUrl,
        prescriptionUrl,
        paymentMethodName,
        senderWalletPhone,
        pharmacyWalletNumber,
      ];

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    final json = _$OrderEntityToJson(this);
    json['paymentMethodName'] = paymentMethodName;
    json['senderWalletPhone'] = senderWalletPhone;
    json['pharmacyWalletNumber'] = pharmacyWalletNumber;
    json['prescriptionUrl'] = prescriptionUrl;
    return json;
  }

  // Create from JSON from Firestore
  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final entity = _$OrderEntityFromJson(json);
    return entity.copyWith(
      paymentMethodName: json['paymentMethodName'] as String?,
      senderWalletPhone: json['senderWalletPhone'] as String?,
      pharmacyWalletNumber: json['pharmacyWalletNumber'] as String?,
      prescriptionUrl: json['prescriptionUrl'] as String?,
    );
  }

  OrderEntity copyWith({
    String? orderId,
    List<CartItemEntity>? cartItem,
    bool? payWithCash,
    ShippingAddressEntity? shippingAddressEntity,
    double? subtotal,
    double? deliveryFee,
    double? totalAmount,
    String? orderStatus,
    DateTime? createdAt,
    String? userId,
    String? paymentProofUrl,
    String? prescriptionUrl,
    String? paymentMethodName,
    String? senderWalletPhone,
    String? pharmacyWalletNumber,
    String? promoCode,
    double? discountAmount,
  }) {
    return OrderEntity(
      orderId: orderId ?? this.orderId,
      cartItem: cartItem ?? this.cartItem,
      payWithCash: payWithCash ?? this.payWithCash,
      shippingAddressEntity:
          shippingAddressEntity ?? this.shippingAddressEntity,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      paymentProofUrl: paymentProofUrl ?? this.paymentProofUrl,
      prescriptionUrl: prescriptionUrl ?? this.prescriptionUrl,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      senderWalletPhone: senderWalletPhone ?? this.senderWalletPhone,
      pharmacyWalletNumber: pharmacyWalletNumber ?? this.pharmacyWalletNumber,
    );
  }
}
