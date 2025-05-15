import 'dart:io';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';
import 'firebase_profile_error_handler.dart';

abstract class ProfileRepository {
  Future<void> updateUserProfile(UserEntity userEntity);
  Future<void> updateUserProfileImage(File imageFile);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logoutUser();
  Future<void> deleteUserAccount();
  Stream<UserEntity> getUserProfileStream();
}

class FirebaseProfileRepository implements ProfileRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<void> updateUserProfile(UserEntity userEntity) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    // Update displayName in Auth
    await currentUser.updateDisplayName(userEntity.name);

    // Update user data in Firestore
    await _firestore.collection('users').doc(currentUser.uid).update({
      'name': userEntity.name,
      'email': userEntity.email,
      // Add any additional fields here
    });
  }

  @override
  Future<void> updateUserProfileImage(File imageFile) async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    try {
      // Upload image to Firebase Storage
      final storageRef =
          _storage.ref().child('profile_images/${currentUser.uid}');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update photoURL in Auth
      await currentUser.updatePhotoURL(downloadUrl);

      // Update user data in Firestore
      await _firestore.collection('users').doc(currentUser.uid).update({
        'profileImageUrl': downloadUrl,
      });
    } catch (e) {
      throw Exception('Failed to update profile image: ${e.toString()}');
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
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to log out: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    final User? currentUser = _firebaseAuth.currentUser;

    if (currentUser == null) {
      throw Exception('No user is currently logged in');
    }

    try {
      // Delete user data from Firestore
      await _firestore.collection('users').doc(currentUser.uid).delete();

      // Delete profile image from Storage if exists
      try {
        await _storage
            .ref()
            .child('profile_images/${currentUser.uid}')
            .delete();
      } catch (e) {
        // Ignore if no profile image exists
      }

      // Delete user from Authentication
      await currentUser.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
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
      );
    });
  }
}
