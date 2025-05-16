import 'dart:developer';
import 'dart:io'; // Still required if other functions use it, otherwise it can be removed.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import 'package:pharma_now/features/profile/domain/repositories/profile_repository.dart';
// import 'package:google_sign_in/google_sign_in.dart';

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

  ProfileStatus get status => _status;
  String get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  // Removed profileImageUrl getter

  ProfileProvider() {
    _loadUserDataFromFirebase(FirebaseAuth.instance.currentUser!.uid);
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _status = ProfileStatus.loading;
        notifyListeners(); // Notify the UI that loading has started
        _loadUserDataFromFirebase(user.uid);
      } else {
        clearUserData();
      }
    });
  }

  Future<void> _loadUserDataFromFirebase(String uid) async {
    log('Loading user data for UID: $uid', name: 'ProfileProvider');
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && firebaseUser.uid == uid) {
          UserEntity? userDataFromFirestore =
              await _profileRepository.getUserProfile(uid);

          String authoritativeName =
              firebaseUser.displayName ?? firebaseUser.email!.split('@')[0];
          String authoritativeEmail = firebaseUser.email ?? '';

          log('Authoritative Name: $authoritativeName, Email: $authoritativeEmail',
              name: 'ProfileProvider');

          if (userDataFromFirestore != null) {
            bool needsUpdate = false;
            String currentNameInFirestore = userDataFromFirestore.name;
            String currentEmailInFirestore = userDataFromFirestore.email;

            if (currentNameInFirestore != authoritativeName ||
                currentEmailInFirestore != authoritativeEmail) {
              needsUpdate = true;
            }

            if (needsUpdate) {
              _currentUser = UserModel(
                uId: userDataFromFirestore.uId,
                name: authoritativeName,
                email: authoritativeEmail,
              );
              await _profileRepository.updateUserProfile(_currentUser!);
              log('Updated user profile in Firestore', name: 'ProfileProvider');
            } else {
              _currentUser = userDataFromFirestore;
            }
          } else {
            _currentUser = UserModel(
              name: authoritativeName,
              email: authoritativeEmail,
              uId: firebaseUser.uid,
            );
            await _profileRepository.updateUserProfile(_currentUser!);
            log('Created new user profile in Firestore',
                name: 'ProfileProvider');
          }
          _status = ProfileStatus.success;
          break; // Exit loop on success
        } else {
          log('No valid Firebase user found, during retry $retryCount',
              name: 'ProfileProvider');
          await clearUserData();
          return;
        }
      } catch (e) {
        retryCount++;
        log('Error loading user data (attempt $retryCount): $e',
            name: 'ProfileProvider');
        if (retryCount >= maxRetries) {
          _errorMessage =
              'Failed to load user data after $maxRetries attempts: ${e.toString()}';
          _status = ProfileStatus.error;
          _currentUser = null;
          break;
        }
        await Future.delayed(
            Duration(milliseconds: 500)); // Wait before retrying
      }
    }
    notifyListeners();
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
      // When updating the profile, we only update the name here.
      // Email should come from the authentication source.
      final updatedUser = UserModel(
        name: name,
        email: _currentUser!.email, // Retain current email from Provider
        uId: _currentUser!.uId,
      );
      await _profileRepository.updateUserProfile(updatedUser);
      _currentUser = updatedUser; // Update current user in Provider
      // Also update displayName in Firebase Auth if the name has changed
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.displayName != name) {
        await firebaseUser.updateDisplayName(name);
      }
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Removed updateProfileImage function entirely
  // Future<void> updateProfileImage(File imageFile) async { ... }

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

  Future<void> clearUserData() async {
    log('Clearing user data: $_currentUser', name: 'ProfileProvider');
    _currentUser = null;
    _status = ProfileStatus.initial;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _profileRepository.logoutUser();
      await clearUserData();
      // Clear any other local state if needed
      // For example, if you have a favorites provider:
      // final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
      // favoritesProvider.clearFavorites();
    } catch (e) {
      log('Logout error: $e', name: 'ProfileProvider');
      _errorMessage = 'Logout failed: ${e.toString()}';
      _status = ProfileStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  // ... (remaining functions like deleteAccount, resetStatus)
}
