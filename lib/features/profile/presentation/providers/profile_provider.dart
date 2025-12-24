import 'dart:developer';
import 'dart:io'; // Still required if other functions use it, otherwise it can be removed.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import 'package:pharma_now/features/profile/domain/repositories/profile_repository.dart';
import 'package:pharma_now/core/services/firebase_auth_service.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
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

          // Determine the authoritative name
          // 1. Prefer Firebase Auth displayName if available
          // 2. Fallback to Firestore name if Auth displayName is missing
          // 3. Last resort: Email prefix

          String? authDisplayName = firebaseUser.displayName;
          String authoritativeEmail = firebaseUser.email ?? '';

          if (userDataFromFirestore != null) {
            // User exists in Firestore
            String currentNameInFirestore = userDataFromFirestore.name;
            String currentEmailInFirestore = userDataFromFirestore.email;

            bool needsFirestoreUpdate = false;
            String finalName = currentNameInFirestore;

            if (authDisplayName != null && authDisplayName.isNotEmpty) {
              // Case A: Auth has a name.
              // If it differs from Firestore, we assume Auth (e.g. Google or fresh Login) is the source of truth,
              // OR we could assume Firestore is source of truth if we think Auth might possess stale data?
              // Usually for Google Sign In, Auth is truth. For Profile Edit, Firestore is updated then Auth.
              // Let's assume if they differ, we sync Auth -> Firestore, UNLESS Auth name is just email prefix?
              // No, we trust a non-empty displayName.

              if (currentNameInFirestore != authDisplayName) {
                finalName = authDisplayName;
                needsFirestoreUpdate = true;
              }
            } else {
              // Case B: Auth has NO name (e.g. legacy email/pass user).
              // Do NOT overwrite Firestore. Instead, backfill Auth.
              if (currentNameInFirestore.isNotEmpty) {
                try {
                  await firebaseUser.updateDisplayName(currentNameInFirestore);
                  await firebaseUser.reload();
                } catch (e) {
                  log('Failed to backfill displayName: $e',
                      name: 'ProfileProvider');
                }
              } else {
                // Both are empty? unlikely, but use email suffix
                finalName = authoritativeEmail.split('@')[0];
                needsFirestoreUpdate = true;
              }
            }

            // Check email sync
            if (currentEmailInFirestore != authoritativeEmail) {
              needsFirestoreUpdate = true;
            }

            if (needsFirestoreUpdate) {
              _currentUser = UserModel(
                uId: userDataFromFirestore.uId,
                name: finalName,
                email: authoritativeEmail,
              );
              await _profileRepository.updateUserProfile(_currentUser!);
              log('Updated user profile in Firestore to match Auth/Rules',
                  name: 'ProfileProvider');
            } else {
              _currentUser = userDataFromFirestore;
            }
          } else {
            // User does NOT exist in Firestore (New User or broken state)
            String nameToUse =
                authDisplayName ?? authoritativeEmail.split('@')[0];

            _currentUser = UserModel(
              name: nameToUse,
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

  Future<void> reauthenticateAndDelete(String? password) async {
    _isLoading = true;
    _status = ProfileStatus.loading;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user found');

      AuthCredential? credential;
      if (password != null) {
        credential = EmailAuthProvider.credential(
            email: user.email!, password: password);
      } else {
        // For Google re-auth, we need to trigger the sign-in flow again to get credentials
        // This is complex because GoogleSignIn returns a GoogleSignInAccount, not a credential directly without plugins.
        // Assuming we rely on the UI to just "Sign In" again or we use the GoogleAuthProvider credential if we had the token.
        throw Exception(
            'Google re-authentication not fully implemented in this flow. Please Log out and Log in again.');
      }

      if (credential != null) {
        await user.reauthenticateWithCredential(credential);
        await deleteAccount(); // Retry deletion
      }
    } catch (e) {
      _errorMessage = 'Re-authentication failed: ${e.toString()}';
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
