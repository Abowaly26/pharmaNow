import 'dart:convert';

import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

import '../../constants.dart';

UserEntity getUser() {
  var jsonString = prefs.getString(kUserData);

  if (jsonString == null || jsonString.isEmpty) {
    throw Exception("No user data found in SharedPreferences");
  }

  var userEntity = UserModel.fromJson(jsonDecode(jsonString));
  return userEntity;
}
