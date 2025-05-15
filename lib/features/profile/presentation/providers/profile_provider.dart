import 'dart:io';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import 'package:pharma_now/features/profile/domain/repositories/profile_repository.dart';
import 'package:pharma_now/constants.dart';

enum ProfileStatus {
  initial,
  loading,
  success,
  error,
}

class ProfileProvider extends ChangeNotifier {
  final FirebaseProfileRepository _profileRepository =
      FirebaseProfileRepository();
  ProfileStatus _status = ProfileStatus.initial;
  String _errorMessage = '';
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _profileImageUrl;

  ProfileStatus get status => _status;
  String get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get profileImageUrl => _profileImageUrl;

  ProfileProvider() {
    _loadUserData();
    _listenToUserChanges();
  }

  void _loadUserData() {
    try {
      final jsonString = prefs.getString(kUserData);
      if (jsonString != null && jsonString.isNotEmpty) {
        _currentUser = UserModel.fromJson(jsonDecode(jsonString));
        _loadProfileImage();
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data';
      _status = ProfileStatus.error;
      notifyListeners();
    }
  }

  void _loadProfileImage() {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.photoURL != null) {
        _profileImageUrl = currentUser.photoURL;
        notifyListeners();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _listenToUserChanges() {
    try {
      _profileRepository.getUserProfileStream().listen((userEntity) {
        _currentUser = userEntity;
        // Save updated user data to shared preferences
        final userJson = (userEntity as UserModel).toMap();
        prefs.setString(kUserData, jsonEncode(userJson));
        _loadProfileImage();
        notifyListeners();
      }, onError: (error) {
        _errorMessage = 'Error updating user data';
        _status = ProfileStatus.error;
        notifyListeners();
      });
    } catch (e) {
      // Handle possible exceptions if user is not logged in yet
    }
  }

  Future<void> updateProfile({required String name}) async {
    if (_currentUser == null) {
      _errorMessage = 'No user currently logged in';
      _status = ProfileStatus.error;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      final updatedUser = UserModel(
        name: name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
      );

      await _profileRepository.updateUserProfile(updatedUser);

      // Update local user data
      _currentUser = updatedUser;

      // Save to shared preferences
      prefs.setString(kUserData, jsonEncode(updatedUser.toMap()));

      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    if (_currentUser == null) {
      _errorMessage = 'No user currently logged in';
      _status = ProfileStatus.error;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await _profileRepository.updateUserProfileImage(imageFile);
      _loadProfileImage(); // Reload profile image after update
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = 'Profile picture update failed: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await _profileRepository.changePassword(currentPassword, newPassword);
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _profileRepository.logoutUser();

      // Clear local user data
      prefs.remove(kUserData);
      _currentUser = null;
      _profileImageUrl = null;

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      await _profileRepository.deleteUserAccount();

      // Clear local user data
      prefs.remove(kUserData);
      _currentUser = null;
      _profileImageUrl = null;

      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
    } catch (e) {
      _errorMessage = 'Account deletion failed: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetStatus() {
    _status = ProfileStatus.initial;
    _errorMessage = '';
    notifyListeners();
  }
}
