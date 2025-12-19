import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:pharma_now/core/services/database_service.dart';
import 'package:pharma_now/core/services/shard_preferences_singlton.dart';
import 'package:pharma_now/core/utils/backend_endpoint.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

import '../../../../core/services/firebase_auth_service.dart';

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuthService firebaseAuthService;
  final DatabaseService databaseService;

  AuthRepoImpl(
      {required this.firebaseAuthService, required this.databaseService});

  @override
  Future<Either<Failures, UserEntity>> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    User? user;
    try {
      user = await firebaseAuthService.createUserWithEmailAndPassword(
          email: email, password: password);

      var userEntity = UserEntity(
        name: name,
        email: email,
        uId: user.uid,
      );

      var isUserExist = await databaseService.checkIfDataExist(
          path: BackendEndpoint.isUserExist, docuementId: user.uid);
      if (isUserExist) {
        await getUserData(uid: user.uid);
      } else {
        await addUserData(user: userEntity);
      }

      // await addUserData(user: userEntity);

      return right(userEntity);
    } on CustomException catch (e) {
      await deleteUser(user);
      return left(ServerFailure(e.message));
    } catch (e) {
      await deleteUser(user);
      log('Exception in AuthRepoImpl.createUserWithEmailAndPassword: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, bool>> checkEmailExists(String email) async {
    try {
      final exists = await firebaseAuthService.checkUserExists(email);
      return right(exists);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.checkEmailExists: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, bool>> checkEmailAlreadyExists(String email) async {
    return checkEmailExists(email);
  }

  Future<void> deleteUser(User? user) async {
    if (user != null) {
      await firebaseAuthService.deleteUser();
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      var user = await firebaseAuthService.signInWithEmailAndPassword(
          email: email, password: password);

      // Block unverified accounts from signing in
      if (!(user.emailVerified)) {
        await FirebaseAuth.instance.signOut();
        return left(ServerFailure(
            'Please verify your email from the verification link we sent, then try signing in.'));
      }

      var userEntity = await getUserData(uid: user.uid);
      // var isUserExist = await databaseService.checkIfDataExist(
      //     path: BackendEndpoint.isUserExist, docuementId: user.uid);

      await saveUserData(user: userEntity);
      // if (isUserExist) {
      // await getUserData(uid: user.uid);
      // } else {
      //   await addUserData(user: userEntity);
      // }

      return right(userEntity);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.signInWithEmailAndPassword: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  // @override
  // Future<Either<Failures, UserEntity>> signinWithGoogle() async {
  //   User? user;
  //   try {
  //     user = await firebaseAuthService.signInWithGoogle();
  //     var userEntity = UserModel.fromFirebaseUser(user);
  //     // var userEntity = await getUserData(uid: user.uid);

  //     var isUserExist = await databaseService.checkIfDataExist(
  //         path: BackendEndpoint.isUserExist, docuementId: user.uid);
  //     if (isUserExist) {
  //       await getUserData(uid: user.uid);
  //     } else {
  //       await addUserData(user: userEntity);
  //     }

  //     await saveUserData(user: userEntity);
  //     return right(userEntity);
  //   } catch (e) {
  //     await deleteUser(user);
  //     log('Exception in AuthRepoImpl.singinWithGoogle: ${e.toString()}');
  //     return left(ServerFailure(
  //         'An error occurred on the server. Please try again later.'));
  //   }
  // }

  Future<Either<Failures, UserEntity>> signinWithGoogle() async {
    User? user;
    try {
      user = await firebaseAuthService.signInWithGoogle();
      // Change from UserModel to UserEntity here
      UserEntity userEntity = UserModel.fromFirebaseUser(user);

      var isUserExist = await databaseService.checkIfDataExist(
          path: BackendEndpoint.isUserExist, docuementId: user.uid);

      if (isUserExist) {
        userEntity = await getUserData(uid: user.uid);
      } else {
        await addUserData(user: userEntity);
      }

      await saveUserData(user: userEntity);
      return right(userEntity);
    } catch (e) {
      await deleteUser(user);
      log('Exception in AuthRepoImpl.singinWithGoogle: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  // @override
  // Future<Either<Failures, UserEntity>> signinWithFacebook() async {
  //   User? user;
  //   try {
  //     var user = await firebaseAuthService.signInWithFacebook();

  //     var userEntity = UserModel.fromFirebaseUser(user);
  //     await addUserData(user: userEntity);
  //     return right(userEntity);
  //   } on CustomException catch (e) {
  //     await deleteUser(user);
  //     return left(ServerFailure(e.message));
  //   } catch (e) {
  //     await deleteUser(user);
  //     log('Exception in AuthRepoImpl.signinWithFacebook: ${e.toString()}');
  //     return left(ServerFailure(
  //         'An error occurred on the server. Please try again later.'));
  //   }
  // }

  @override
  Future addUserData({required UserEntity user}) async {
    await databaseService.addData(
        path: BackendEndpoint.addUserData,
        data: UserModel.fromEntity(user).toMap(),
        documentId: user.uId);
  }

  @override
  Future<UserEntity> getUserData({required String uid}) async {
    var userData = await databaseService.getData(
        path: BackendEndpoint.getUserData, docuementId: uid);

    return UserModel.fromJson(userData);
  }

  @override
  @override
  Future<Either<Failures, void>> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        return left(ServerFailure('Please enter your email address'));
      }

      final sanitized = _sanitizeEmail(email);

      // Check the authentication provider for this email
      final provider = await firebaseAuthService.getProviderForEmail(sanitized);

      // Email is not associated with any account
      if (provider == null) {
        return left(ServerFailure('Account not found'));
      }

      // Email is associated with a Google account
      if (provider == 'google.com') {
        return left(ServerFailure(
            'This email is associated with a Google account. Please sign in with Google.'));
      }

      // Email is associated with a password account -> Send reset email
      if (provider == 'password') {
        await firebaseAuthService.sendPasswordResetEmail(sanitized);
        return right(null);
      }

      // Any other provider (e.g., Facebook)
      return left(ServerFailure('Cannot reset password for this account type'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return left(ServerFailure('Account not found'));
      } else if (e.code == 'invalid-email') {
        return left(ServerFailure('Invalid email address'));
      } else {
        return left(ServerFailure(
            'Failed to send reset link. Please try again later.'));
      }
    } catch (e) {
      return left(
          ServerFailure('An unexpected error occurred. Please try again.'));
    }
  }

  @override
  Future<void> saveUserData({required UserEntity user}) async {
    try {
      // Convert user entity to map and store in shared preferences
      final userJson = jsonEncode(UserModel.fromEntity(user).toMap());
      await prefs.setString(kUserData, userJson);
    } catch (e) {
      log('Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  @override
  Future<Either<Failures, void>> sendEmailVerification() async {
    try {
      await firebaseAuthService.sendEmailVerification();
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Error sending email verification: $e');
      return left(ServerFailure('Failed to send email verification'));
    }
  }

  @override
  Future<Either<Failures, bool>> reloadAndCheckEmailVerified() async {
    try {
      final isVerified =
          await firebaseAuthService.reloadAndCheckEmailVerified();
      return right(isVerified);
    } catch (e) {
      log('Exception in AuthRepoImpl.reloadAndCheckEmailVerified: ${e.toString()}');
      return left(ServerFailure('Failed to check verification status.'));
    }
  }

  @override
  Future<Either<Failures, String?>> verifyPasswordResetCode(
      String oobCode) async {
    try {
      final email = await firebaseAuthService.verifyPasswordResetCode(oobCode);
      return right(email);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.verifyPasswordResetCode: ${e.toString()}');
      return left(ServerFailure('Failed to verify reset link.'));
    }
  }

  @override
  Future<Either<Failures, void>> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await firebaseAuthService.confirmPasswordReset(
          oobCode: oobCode, newPassword: newPassword);
      return right(null);
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.confirmPasswordReset: ${e.toString()}');
      return left(ServerFailure('Failed to reset password.'));
    }
  }

  String _sanitizeEmail(String email) {
    if (email.isEmpty) return email;

    var sanitized = email.trim();

    // sanitized = sanitized.replaceAll(' ', '');

    sanitized = sanitized.toLowerCase();

    log('🔧 Sanitized email from "$email" to "$sanitized"');

    return sanitized;
  }
}
