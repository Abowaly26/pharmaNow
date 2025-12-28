import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.name,
    required super.email,
    required super.uId,
    super.profileImageUrl,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      name: user.displayName ?? '',
      email: user.email ?? '',
      uId: user.uid,
      profileImageUrl: user.photoURL,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      uId: json['uId'] ?? '',
      profileImageUrl: json['profileImageUrl'],
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      name: user.name,
      email: user.email,
      uId: user.uId,
      profileImageUrl: user.profileImageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uId': uId,
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  UserModel copyWith({
    String? name,
    String? email,
    String? uId,
    String? profileImageUrl,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      uId: uId ?? this.uId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
