class UserEntity {
  final String name;
  final String email;
  final String uId;
  final String? profileImageUrl;

  UserEntity({
    required this.name,
    required this.email,
    required this.uId,
    this.profileImageUrl,
  });

  /// Creates a copy of this entity with the given fields replaced
  UserEntity copyWith({
    String? name,
    String? email,
    String? uId,
    String? profileImageUrl,
  }) {
    return UserEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      uId: uId ?? this.uId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
