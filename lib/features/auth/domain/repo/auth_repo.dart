import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/errors/exceptions.dart';

import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

abstract class AuthRepo {
  Future<Either<Failures, UserEntity>> createUserWithEmailAndPassword(
      String email, String password, String name);

  Future<Either<Failures, bool>> checkEmailExists(String email);

  Future<Either<Failures, UserEntity>> signInWithEmailAndPassword(
      String email, String password);

  Future<Either<Failures, UserEntity>> signinWithGoogle();

  Future addUserData({required UserEntity user});
  Future saveUserData({required UserEntity user});
  Future<UserEntity> getUserData({required String uid});

  Future<Either<Failures, bool>> checkEmailAlreadyExists(String email);

  // Future<Either<Failures, UserEntity>> signinWithFacebook();

  /// Sends email verification to the currently signed-in user
  Future<Either<Failures, void>> sendEmailVerification();

  /// Sends a password reset email to the provided address
  Future<Either<Failures, void>> sendPasswordResetEmail(String email);

  /// Reload user and return whether email is verified
  Future<Either<Failures, bool>> reloadAndCheckEmailVerified();

  /// Verify the reset password code and return email if valid
  Future<Either<Failures, String?>> verifyPasswordResetCode(String oobCode);

  /// Confirm password reset with a new password
  Future<Either<Failures, void>> confirmPasswordReset(
      {required String oobCode, required String newPassword});
}
