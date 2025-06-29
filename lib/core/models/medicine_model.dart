import 'package:pharma_now/core/helper_functions/get_avg_rating.dart';
import 'package:pharma_now/core/models/review_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import '../enitites/medicine_entity.dart';

class MedicineModel {
  final String name;
  final String description;
  final String code;
  final int quantity;
  final bool isNewProduct;
  final num price;
  String? subabaseORImageUrl;
  final String pharmacyName;
  final int pharmacyId;
  final String pharmcyAddress;
  final num avgRating;
  final int ratingCount = 0;
  final num sellingCount;
  final List<ReviewModel> reviews;
  final int discountRating;

  MedicineModel({
    required this.discountRating,
    required this.avgRating,
    required this.sellingCount,
    required this.reviews,
    required this.pharmacyName,
    required this.pharmacyId,
    required this.pharmcyAddress,
    this.subabaseORImageUrl,
    required this.name,
    required this.description,
    required this.code,
    required this.quantity,
    required this.isNewProduct,
    required this.price,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      discountRating: json['discountRating'] ?? 0,
      avgRating: getAvgRating(json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((e) => ReviewModel.fromJson(e)))
          : []),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      code: json['code'] ?? '',
      quantity: json['quantity'] ?? 0,
      isNewProduct: json['isNewProduct'] ?? false,
      price: json['price'] ?? 0,
      subabaseORImageUrl:
          json['subabaseImageUrl'] ?? json['subabaseORImageUrl'],
      pharmacyName: json['pharmacyName'] ?? '',
      pharmacyId: json['pharmacyId'] ?? 0,
      pharmcyAddress: json['pharmcyAddress'] ?? '',
      reviews: json['reviews'] != null
          ? List<ReviewModel>.from(
              json['reviews'].map((e) => ReviewModel.fromJson(e)))
          : [],
      sellingCount: json['sellingCount'] ?? 0,
    );
  }

  get discountRate => null;

  MedicineEntity toEntity() {
    return MedicineEntity(
      name: name,
      description: description,
      code: code,
      quantity: quantity,
      isNewProduct: isNewProduct,
      price: price,
      subabaseORImageUrl: subabaseORImageUrl,
      pharmacyName: pharmacyName,
      pharmacyId: pharmacyId,
      pharmcyAddress: pharmcyAddress,
      reviews: reviews.map((e) => e.toEntity()).toList(),
      sellingCount: sellingCount,
      discountRating: discountRating,
      avgRating: avgRating,
      ratingCount: ratingCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'code': code,
      'quantity': quantity,
      'isNewProduct': isNewProduct,
      'price': price,
      'subabaseORImageUrl': subabaseORImageUrl,
      'pharmacyName': pharmacyName,
      'pharmacyId': pharmacyId,
      'pharmcyAddress': pharmcyAddress,
      'reviews': reviews.map((e) => e.toJson()).toList(),
      'sellingCount': sellingCount,
      'discountRating': discountRating,
    };
  }
}

// داخل ملف user_model.dart
class UserModel implements UserEntity {
  // ... باقي الخصائص مثل uId, name, email
  final String? profileImageUrl; // <-- هذه الخاصية مهمة

  UserModel({
    // ... required this.uId, required this.name, required this.email,
    this.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // ... uId: json['uId'], name: json['name'], email: json['email'],
      profileImageUrl:
          json['profileImageUrl'] as String?, // يتم جلبها من Firestore
    );
  }

  // قد تحتاج أيضاً إلى دالة toJson إذا كنت تقوم بتحديث هذا الحقل في Firestore
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // ... data['uId'] = this.uId;
    data['profileImageUrl'] = this.profileImageUrl;
    return data;
  }

  @override
  // TODO: implement email
  String get email => throw UnimplementedError();

  @override
  // TODO: implement name
  String get name => throw UnimplementedError();

  @override
  // TODO: implement uId
  String get uId => throw UnimplementedError();
}
