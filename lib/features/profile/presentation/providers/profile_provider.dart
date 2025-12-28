import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import 'package:pharma_now/features/profile/domain/repositories/profile_repository.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

    // 1. Try to load from local storage first for immediate feedback
    try {
      String? localUserJson = prefs.getString(kUserData);
      if (localUserJson != null) {
        Map<String, dynamic> localUserMap = jsonDecode(localUserJson);
        // Verify it belongs to the current user
        if (localUserMap['uId'] == uid) {
          _currentUser = UserModel.fromJson(localUserMap);
          _status = ProfileStatus.success;
          notifyListeners();
          log('Loaded user data from SharedPreferences',
              name: 'ProfileProvider');
        }
      }
    } catch (e) {
      log('Failed to load local user data: $e', name: 'ProfileProvider');
    }

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && firebaseUser.uid == uid) {
          UserEntity? userDataFromFirestore =
              await _profileRepository.getUserProfile(uid);

          if (userDataFromFirestore != null) {
            // Check if user is signed in with Google
            bool isGoogleUser = firebaseUser.providerData
                .any((userInfo) => userInfo.providerId == 'google.com');

            // Use Firestore name as the primary source of truth regardless of auth method
            _currentUser = userDataFromFirestore;

            // Sync Auth displayName with Firestore name to ensure consistency
            if (firebaseUser.displayName != userDataFromFirestore.name) {
              try {
                await firebaseUser
                    .updateDisplayName(userDataFromFirestore.name);
                await firebaseUser.reload();
                log('Synced Auth displayName with Firestore name: ${userDataFromFirestore.name}',
                    name: 'ProfileProvider');
              } catch (e) {
                log('Failed to sync displayName: $e', name: 'ProfileProvider');
              }
            }

            // If the user is a Google user but has a different name in Firestore,
            // we still prioritize the Firestore name (the registered name)
            if (isGoogleUser &&
                firebaseUser.displayName != null &&
                firebaseUser.displayName != userDataFromFirestore.name) {
              log('Google display name (${firebaseUser.displayName}) differs from registered name (${userDataFromFirestore.name}). Using registered name.',
                  name: 'ProfileProvider');
            }
          } else {
            // User does NOT exist in Firestore (New User or broken state)
            // Reload user to get the latest displayName
            await firebaseUser.reload();
            final updatedUser = FirebaseAuth.instance.currentUser;

            String nameToUse = updatedUser?.displayName ??
                firebaseUser.email?.split('@')[0] ??
                '';

            _currentUser = UserModel(
              name: nameToUse,
              email: firebaseUser.email ?? '',
              uId: firebaseUser.uid,
            );
            await _profileRepository.updateUserProfile(_currentUser!);
            log('Created new user profile in Firestore',
                name: 'ProfileProvider');
          }
          _status = ProfileStatus.success;
          break; // Exit loop on success
        } else {
          log('No valid Firebase user found during retry $retryCount',
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
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: _currentUser!.profileImageUrl,
      );
      await _profileRepository.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
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

  /// Updates the user's profile image
  /// Upload to Supabase and save URL to Firestore
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
      log('Uploading profile image...', name: 'ProfileProvider');

      // Upload and get URL
      final String imageUrl =
          await _profileRepository.updateUserProfileImage(imageFile);

      log('Profile image uploaded. URL: $imageUrl', name: 'ProfileProvider');

      // Update current user with new image URL
      _currentUser = UserModel(
        name: _currentUser!.name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: imageUrl,
      );

      _status = ProfileStatus.success;
      log('Profile image updated successfully', name: 'ProfileProvider');
    } catch (e) {
      log('Error uploading profile image: $e', name: 'ProfileProvider');
      _errorMessage = 'Failed to upload profile image: ${e.toString()}';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Removes the user's profile image
  Future<void> removeProfileImage() async {
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
      log('Removing profile image...', name: 'ProfileProvider');

      await _profileRepository.removeUserProfileImage();

      // Update current user to remove image URL
      _currentUser = UserModel(
        name: _currentUser!.name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: null,
      );

      _status = ProfileStatus.success;
      log('Profile image removed successfully', name: 'ProfileProvider');
    } catch (e) {
      log('Error removing profile image: $e', name: 'ProfileProvider');
      _errorMessage = 'Failed to remove profile image: ${e.toString()}';
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

  Future<void> clearUserData() async {
    log('Clearing user data: $_currentUser', name: 'ProfileProvider');
    _currentUser = null;
    _status = ProfileStatus.initial;
    _errorMessage = '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> reauthenticateAndDelete(String? password) async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user found');

      AuthCredential? credential;

      // Check provider to decide on re-auth strategy
      // Check for Google provider FIRST (higher priority)
      bool isGoogleUser = user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com');

      bool isPasswordProvider = user.providerData
          .any((userInfo) => userInfo.providerId == 'password');

      if (isGoogleUser) {
        // For Google users, re-authenticate with Google Sign In
        try {
          final GoogleSignIn googleSignIn = GoogleSignIn();
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

          if (googleUser == null) {
            throw 'Google sign-in cancelled';
          }

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          await user.reauthenticateWithCredential(credential);
        } catch (e) {
          throw 'Failed to re-authenticate with Google. Please try again.';
        }
      } else if (isPasswordProvider) {
        if (password == null || password.isEmpty) {
          throw 'Please enter your password';
        }
        credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
      } else {
        // For Google or others, we attempt delete directly.
        // If it fails with 'requires-recent-login', we can't easily re-auth
        // without popping a Google Sign In flow, which defines a different UX.
        // For now, we proceed to delete.
      }

      await deleteAccount();
    } on FirebaseAuthException catch (e) {
      String msg = 'Re-authentication failed';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        msg = 'Incorrect password. Please try again.';
      } else if (e.code == 'requires-recent-login') {
        msg =
            'Security requires you to log out and log back in before deleting.';
      } else {
        msg = e.message ?? 'An error occurred during re-authentication';
      }
      _errorMessage = msg;
      _status = ProfileStatus.error;
      notifyListeners();
      throw msg; // Throw just the message string for clearer UI display
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      // Use the service to set the flag before signing out
      final authService = FirebaseAuthService();
      await authService.normalLogout(); // This calls signOut internally

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

  Future<void> deleteAccount() async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      FirebaseAuthService().setUserDeleted(true);
      await _profileRepository.deleteUserAccount();
      await clearUserData();
      _status = ProfileStatus.success;
    } catch (e) {
      // Propagate specific exceptions like RequiresRecentLoginException
      if (e is RequiresRecentLoginException) {
        rethrow;
      }
      _errorMessage = 'Account deletion failed: ${e.toString()}';
      _status = ProfileStatus.error;
      notifyListeners();
      rethrow;
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
