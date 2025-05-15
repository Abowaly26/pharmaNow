import 'dart:convert';

import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

import '../../constants.dart';

UserEntity getUser() {
  var jsonString = prefs.getString(kUserData);

  if (jsonString == null || jsonString.isEmpty) {
    // بدلاً من رمي استثناء، نُرجع كائن UserModel فارغ بقيم افتراضية
    return UserModel(name: '', email: '', uId: '');
  }

  try {
    var userEntity = UserModel.fromJson(jsonDecode(jsonString));
    return userEntity;
  } catch (e) {
    // معالجة أي خطأ في تحليل البيانات
    print("Error parsing user data: $e");
    return UserModel(name: '', email: '', uId: '');
  }
}
