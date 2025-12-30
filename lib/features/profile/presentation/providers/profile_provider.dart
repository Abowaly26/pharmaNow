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
  bool _isNavigatingOut = false;
  bool _isPasswordUser = false;
  String? _currentLoginMethod;

  ProfileStatus get status => _status;
  String get errorMessage => _errorMessage;
  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isNavigatingOut => _isNavigatingOut;
  bool get isPasswordUser => _isPasswordUser;
  bool get isPasswordSession => _currentLoginMethod == 'password';

  ProfileProvider() {
    if (FirebaseAuth.instance.currentUser != null) {
      _loadUserDataFromFirebase(FirebaseAuth.instance.currentUser!.uid);
      _currentLoginMethod = prefs.getString(kLoginMethod);
    }
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _status = ProfileStatus.loading;
        notifyListeners();
        _currentLoginMethod = prefs.getString(kLoginMethod);
        _loadUserDataFromFirebase(user.uid);
      } else {
        if (!_isNavigatingOut) {
          clearUserData();
        } else {
          // Keep _currentUser to prevent background data from changing or showing placeholders
          // during the intentional logout/deletion transition/animation.
          log('Keeping user data during intentional navigation out',
              name: 'ProfileProvider');
          notifyListeners();
        }
      }
    });
  }

  Future<void> _loadUserDataFromFirebase(String uid) async {
    log('Loading user data for UID: $uid', name: 'ProfileProvider');
    _isNavigatingOut = false; // Reset navigation flag when loading new data

    try {
      String? localUserJson = prefs.getString(kUserData);
      if (localUserJson != null) {
        Map<String, dynamic> localUserMap = jsonDecode(localUserJson);
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
            bool isGoogleUser = firebaseUser.providerData
                .any((userInfo) => userInfo.providerId == 'google.com');

            if (isGoogleUser &&
                firebaseUser.photoURL != null &&
                (userDataFromFirestore.profileImageUrl == null ||
                    userDataFromFirestore.profileImageUrl!.isEmpty)) {
              userDataFromFirestore = userDataFromFirestore.copyWith(
                  profileImageUrl: firebaseUser.photoURL);
              await _profileRepository.updateUserProfile(userDataFromFirestore);
            }

            if (firebaseUser.displayName != userDataFromFirestore.name) {
              try {
                await firebaseUser
                    .updateDisplayName(userDataFromFirestore.name);
                await firebaseUser.reload();
              } catch (e) {
                log('Failed to sync displayName: $e', name: 'ProfileProvider');
              }
            }

            _currentUser = userDataFromFirestore;
            _isPasswordUser = firebaseUser.providerData
                .any((userInfo) => userInfo.providerId == 'password');
            await _saveUserToLocal(_currentUser!);
            _status = ProfileStatus.success;
            _isLoading = false;
            break;
          } else {
            // Firestore data doesn't exist yet. This could be a race condition during registration.
            // We wait and retry instead of immediately falling back to email prefix.
            log('User profile not found in Firestore for UID: $uid. Retrying... (attempt ${retryCount + 1})',
                name: 'ProfileProvider');

            if (retryCount >= maxRetries - 1) {
              // Final attempt failed. We don't create profiles here to avoid race conditions
              // with the Auth repository's registration/migration logic.
              _errorMessage = 'User profile data not found.';
              _status = ProfileStatus.error;
              _currentUser = null;
              break;
            }
          }
        } else {
          await clearUserData();
          return;
        }
      } catch (e) {
        retryCount++;
        if (retryCount >= maxRetries) {
          _errorMessage =
              'Failed to load user data after $maxRetries attempts: ${e.toString()}';
          _status = ProfileStatus.error;
          _currentUser = null;
          break;
        }
        await Future.delayed(Duration(milliseconds: 500));
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
      final updatedUser = UserModel(
        name: name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: _currentUser!.profileImageUrl,
      );
      await _profileRepository.updateUserProfile(updatedUser);
      _currentUser = updatedUser;
      await _saveUserToLocal(updatedUser);

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
      final String imageUrl =
          await _profileRepository.updateUserProfileImage(imageFile);

      _currentUser = UserModel(
        name: _currentUser!.name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: imageUrl,
      );

      await _saveUserToLocal(_currentUser!);
      _status = ProfileStatus.success;
    } catch (e) {
      log('Original upload error: $e', name: 'ProfileProvider');
      _errorMessage = 'error in upload image';
      _status = ProfileStatus.error;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
      await _profileRepository.removeUserProfileImage();

      _currentUser = UserModel(
        name: _currentUser!.name,
        email: _currentUser!.email,
        uId: _currentUser!.uId,
        profileImageUrl: null,
      );

      await _saveUserToLocal(_currentUser!);
      _status = ProfileStatus.success;
    } catch (e) {
      _errorMessage = 'Failed to remove profile photo: ${e.toString()}';
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
    log('Clearing user data', name: 'ProfileProvider');
    _currentUser = null;
    _status = ProfileStatus.initial;
    _errorMessage = '';
    _isLoading = false;
    _isNavigatingOut = false; // Reset navigation flag when clearing data
    _isPasswordUser = false;
    _currentLoginMethod = null;
    await prefs.remove(kLoginMethod);
    notifyListeners();
  }

  Future<void> reauthenticateAndDelete(String? password) async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    _isNavigatingOut = true; // Trigger skeleton immediately
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user found');

      AuthCredential? credential;
      bool isGoogleUser = user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com');

      if (password != null && password.isNotEmpty) {
        credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
      } else if (isGoogleUser) {
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
          if (e == 'Google sign-in cancelled') rethrow;
          throw 'Failed to re-authenticate with Google. Please try again.';
        }
      } else if (!isGoogleUser && user.email != null) {
        throw 'Please enter your password';
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
      _isNavigatingOut = false;
      _isLoading = false;
      notifyListeners();
      throw msg;
    } catch (e) {
      _isNavigatingOut = false;
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    log('ProfileProvider: Starting logout flow...', name: 'ProfileProvider');
    _status = ProfileStatus.loading;
    _isNavigatingOut = true;
    notifyListeners();
    try {
      final authService = FirebaseAuthService();
      await authService.normalLogout(); // This calls signOut internally

      // Don't reset status here, let navigation happen while in loading state
      // We keep _currentUser until the navigation happens or auth state changes
    } catch (e) {
      _isNavigatingOut = false;
      log('Logout error: $e', name: 'ProfileProvider');
      _errorMessage = 'Logout failed: ${e.toString()}';
      _status = ProfileStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    log('ProfileProvider: Starting account deletion flow...',
        name: 'ProfileProvider');
    _isLoading = true;
    _status = ProfileStatus.loading;
    _isNavigatingOut = true;
    notifyListeners();
    try {
      FirebaseAuthService().setUserDeleted(true);
      await _profileRepository.deleteUserAccount();

      // Status will be handled by navigation or success state
      _status = ProfileStatus.success;
    } catch (e) {
      _isNavigatingOut = false;
      _isLoading = false;
      if (e is RequiresRecentLoginException) {
        rethrow;
      }
      _errorMessage = 'Account deletion failed: ${e.toString()}';
      _status = ProfileStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveUserToLocal(UserEntity user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await prefs.setString(kUserData, jsonEncode(userModel.toMap()));
    } catch (e) {
      log('Failed to save user data to SharedPreferences: $e',
          name: 'ProfileProvider');
    }
  }

  void resetStatus() {
    _status = ProfileStatus.initial;
    _errorMessage = '';
    _isNavigatingOut = false; // Reset navigation flag
    notifyListeners();
  }
}
