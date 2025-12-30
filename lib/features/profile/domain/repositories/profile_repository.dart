import 'dart:io';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:pharma_now/core/services/supabase_storage.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<void> updateUserProfile(UserEntity userEntity);
  Future<String> updateUserProfileImage(File imageFile);
  Future<void> removeUserProfileImage();
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logoutUser();
  Future<void> deleteUserAccount();
  Stream<UserEntity> getUserProfileStream();
}

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SupabaseStorageService _supabaseStorage =
      GetIt.instance<SupabaseStorageService>();

  @override
  Future<void> updateUserProfile(UserEntity userEntity) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      log('No user logged in for profile update',
          name: 'FirebaseProfileRepository');
      throw Exception('No user is currently logged in');
    }

    log('Updating user profile for UID: ${currentUser.uid}',
        name: 'FirebaseProfileRepository');
    await currentUser.updateDisplayName(userEntity.name);

    final Map<String, dynamic> updateData = {
      'name': userEntity.name,
      'email': userEntity.email,
      'uId': currentUser.uid,
    };

    // Only include profileImageUrl if it's not null
    if (userEntity.profileImageUrl != null) {
      updateData['profileImageUrl'] = userEntity.profileImageUrl;
    }

    await _firestore.collection('users').doc(currentUser.uid).set(
          updateData,
          SetOptions(merge: true),
        );
    log('User profile updated in Firestore', name: 'FirebaseProfileRepository');
  }

  @override
  Future<String> updateUserProfileImage(File imageFile) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('User authentication required (User is null)');
    }

    try {
      log('Step 0: Deleting old profile image if exists...',
          name: 'FirebaseProfileRepository');
      await removeUserProfileImage();
    } catch (e) {
      log('Initial cleanup failed (probably no image exists): $e',
          name: 'FirebaseProfileRepository');
    }

    String downloadUrl;
    try {
      log('Step 1: Uploading to Supabase...',
          name: 'FirebaseProfileRepository');
      downloadUrl = await _supabaseStorage.uploadProfileImage(
        imageFile,
        currentUser.uid,
      );
    } catch (e) {
      log('Supabase Upload Failed: $e', name: 'FirebaseProfileRepository');
      throw Exception('Supabase Storage Error: ${e.toString()}');
    }

    try {
      log('Step 2: Updating Firebase Auth photoURL...',
          name: 'FirebaseProfileRepository');
      await currentUser.updatePhotoURL(downloadUrl);
    } catch (e) {
      log('Firebase Auth Update Failed: $e', name: 'FirebaseProfileRepository');
      // We don't throw here as the primary goal (upload & firestore) might still succeed
    }

    try {
      log('Step 3: Updating Firestore...', name: 'FirebaseProfileRepository');
      await _firestore.collection('users').doc(currentUser.uid).set({
        'profileImageUrl': downloadUrl,
      }, SetOptions(merge: true));

      log('Profile update completed successfully',
          name: 'FirebaseProfileRepository');
      return downloadUrl;
    } catch (e) {
      log('Firestore Update Failed: $e', name: 'FirebaseProfileRepository');
      throw Exception('Firestore Database Error: ${e.toString()}');
    }
  }

  @override
  Future<void> removeUserProfileImage() async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    try {
      log('Removing profile image for UID: ${currentUser.uid}',
          name: 'FirebaseProfileRepository');

      // Delete image from Supabase Storage
      await _supabaseStorage.deleteProfileImage(currentUser.uid);

      // Clear photoURL in Firebase Auth
      await currentUser.updatePhotoURL(null);

      // Remove profileImageUrl from Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'profileImageUrl': FieldValue.delete(),
      });

      log('Profile image removed successfully',
          name: 'FirebaseProfileRepository');
    } catch (e) {
      log('Error removing profile image: $e',
          name: 'FirebaseProfileRepository');
      throw Exception('Failed to remove profile image: ${e.toString()}');
    }
  }

  @override
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    // Get auth credentials from the user for re-authentication
    final AuthCredential credential = EmailAuthProvider.credential(
      email: currentUser.email!,
      password: currentPassword,
    );

    try {
      // Re-authenticate
      await currentUser.reauthenticateWithCredential(credential);

      // Change password
      await currentUser.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('The current password is incorrect');
      } else {
        throw Exception('Failed to change password: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to change password: ${e.toString()}');
    }
  }

  @override
  Future<void> logoutUser() async {
    try {
      // Clear local state
      await _firebaseAuth.signOut();
    } catch (e) {
      log('Logout error: $e', name: 'FirebaseProfileRepository');
      throw CustomException(message: 'Failed to log out: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    try {
      final String userEmail = currentUser.email!;
      final String currentUid = currentUser.uid;

      log('Starting deletion for user: $userEmail (UID: $currentUid)',
          name: 'FirebaseProfileRepository');

      // 1. Delete ALL documents with this email in Firestore
      // This handles cases where multiple "users" docs exist for the same email
      final QuerySnapshot emailMatches = await _firestore
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      final WriteBatch batch = _firestore.batch();
      int deletedCount = 0;

      for (var doc in emailMatches.docs) {
        log('Deleting user document: ${doc.id}',
            name: 'FirebaseProfileRepository');
        batch.delete(doc.reference);
        deletedCount++;
      }

      if (deletedCount > 0) {
        await batch.commit();
        log('Deleted $deletedCount user document(s) from Firestore',
            name: 'FirebaseProfileRepository');
      } else {
        log('No user documents found in Firestore to delete',
            name: 'FirebaseProfileRepository');
      }

      // 2. Delete profile image from Supabase Storage if exists
      // We try to delete using the current UID. If there were old UIDs,
      // their images might remain in storage, but since we deleted the DB record,
      // they effectively become orphaned and won't be linked to the new account.
      try {
        await _supabaseStorage.deleteProfileImage(currentUid);
      } catch (e) {
        // Ignore if no profile image exists
        log('No profile image to delete or error: $e',
            name: 'FirebaseProfileRepository');
      }

      // 3. Delete user from Authentication
      await currentUser.delete();
      log('User deleted from Firebase Authentication',
          name: 'FirebaseProfileRepository');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw RequiresRecentLoginException(
            'This sensitive operation requires you to re-authenticate.');
      }
      throw Exception('Failed to delete account: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  Future<UserEntity?> getUserProfile(String uid) async {
    log('Fetching user profile for UID: $uid',
        name: 'FirebaseProfileRepository');
    try {
      final docSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        // Ensure uId is included in the data
        data['uId'] = uid;
        log('User profile found in Firestore with profileImageUrl: ${data['profileImageUrl']}',
            name: 'FirebaseProfileRepository');
        return UserModel.fromJson(data);
      }
      log('No user profile found in Firestore',
          name: 'FirebaseProfileRepository');
      return null;
    } catch (e) {
      log('Error fetching user profile: $e', name: 'FirebaseProfileRepository');
      throw CustomException(
          message: 'Failed to fetch user profile: ${e.toString()}');
    }
  }

  @override
  Stream<UserEntity> getUserProfileStream() {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;

      return UserModel(
        name: data['name'] ?? '',
        email: data['email'] ?? '',
        uId: currentUser.uid,
        profileImageUrl: data['profileImageUrl'],
      );
    });
  }
}
