import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_now/core/errors/exceptions.dart';

class FirebaseAuthService {
  Future deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
  }

  /// Returns the provider ID for the given email (e.g., 'password' or 'google.com')
  /// Returns null if no account exists with the given email
  Future<String?> getProviderForEmail(String email) async {
    try {
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) return null;

      // Convert sign-in method to provider ID
      if (methods.contains('password')) return 'password';
      if (methods.contains('google.com')) return 'google.com';
      if (methods.contains('facebook.com')) return 'facebook.com';

      return methods.first;
    } catch (e) {
      log('Error getting provider for email: $e');
      rethrow;
    }
  }

  Future<User> createUserWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in createUserWithEmailAndPassword: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'weak-password':
          throw CustomException(
              message:
                  'The password provided is too weak. Please use a stronger password.');
        case 'email-already-in-use':
          throw CustomException(
              message: 'An account already exists with this email address.');
        case 'invalid-email':
          throw CustomException(
              message:
                  'The email address is invalid. Please check and try again.');
        case 'operation-not-allowed':
          throw CustomException(
              message:
                  'Email/password accounts are not enabled. Please contact support.');
        case 'network-request-failed':
          throw CustomException(
              message:
                  'Network error. Please check your internet connection and try again.');
        case 'user-disabled':
          throw CustomException(
              message:
                  'This account has been disabled. Please contact support.');
        case 'too-many-requests':
          throw CustomException(
              message: 'Too many attempts. Please try again later.');
        default:
          throw CustomException(
              message:
                  'An error occurred during sign up. Please try again later.');
      }
    } catch (e) {
      log('Unexpected error in createUserWithEmailAndPassword: ${e.toString()}');
      throw CustomException(
          message: 'An unexpected error occurred. Please try again later.');
    }
  }

  Future<User> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in signInWithEmailAndPassword: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'user-not-found':
          throw CustomException(
              message:
                  'No account found with this email. Please check your email or sign up.');
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          throw CustomException(
              message: 'Incorrect email or password. Please try again.');
        case 'invalid-email':
          throw CustomException(
              message:
                  'The email address is invalid. Please check and try again.');
        case 'user-disabled':
          throw CustomException(
              message:
                  'This account has been disabled. Please contact support.');
        case 'too-many-requests':
          throw CustomException(
              message: 'Too many attempts. Please try again later.');
        case 'network-request-failed':
          throw CustomException(
              message:
                  'Network error. Please check your internet connection and try again.');
        default:
          throw CustomException(
              message:
                  'An error occurred during sign-in. Please try again later.');
      }
    } catch (e) {
      log('Unexpected error in signInWithEmailAndPassword: ${e.toString()}');
      throw CustomException(
          message: 'An unexpected error occurred. Please try again later.');
    }
  }

  Future<User> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return (await FirebaseAuth.instance.signInWithCredential(credential)).user!;
  }

  Future<User> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();

    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    return (await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential))
        .user!;
  }

  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// Sends an email verification to the currently signed-in user.
  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in sendEmailVerification: ${e.code} - ${e.message}');
      throw CustomException(
          message: e.message ?? 'Failed to send verification email.');
    } catch (e) {
      log('Unexpected error in sendEmailVerification: ${e.toString()}');
      throw CustomException(
          message: 'Unexpected error while sending verification email.');
    }
  }

  /// Checks whether an account exists for the given email by querying sign-in methods.
  Future<bool> checkUserExists(String email) async {
    try {
      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in checkUserExists: ${e.code} - ${e.message}');
      if (e.code == 'invalid-email') {
        throw CustomException(message: 'The email address is invalid.');
      }
      throw CustomException(
          message: 'Failed to validate email. Please try again later.');
    } catch (e) {
      log('Unexpected error in checkUserExists: ${e.toString()}');
      throw CustomException(
          message: 'Unexpected error while validating email.');
    }
  }

  /// Returns the list of sign-in providers for the given email (e.g., ['password'], ['google.com']).
  Future<List<String>> getSignInMethods(String email) async {
    try {
      if (email.isEmpty) {
        log('❌ Empty email provided to getSignInMethods');
        return [];
      }

      log('🔍 Fetching sign-in methods for: "$email"');

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        log('❌ Invalid email format: "$email"');
        throw CustomException(message: 'The email address format is invalid.');
      }

      final methods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      log('🔑 Found sign-in methods for "$email": $methods');
      return methods;
    } on FirebaseAuthException catch (e) {
      log('❌ FirebaseAuthException in getSignInMethods for "$email": ${e.code} - ${e.message}');

      if (e.code == 'invalid-email') {
        throw CustomException(
            message: 'The email address "$email" is not valid.');
      } else if (e.code == 'user-not-found') {
        log('ℹ️ No account found with email: $email');
        return [];
      }

      throw CustomException(
          message: 'Failed to check sign-in methods. ${e.message}');
    } catch (e) {
      log('❌ Unexpected error in getSignInMethods: ${e.toString()}');
      throw CustomException(
          message: 'An unexpected error occurred. Please try again.');
    }
  }

  /// Sends a password reset email to the specified email address.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      log('Firebase: Sending password reset email to $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      log('Firebase: Password reset email sent successfully to $email');
    } catch (e) {
      log('Firebase: Error sending password reset email to $email: $e');
      rethrow;
    }
  }

  /// Reloads the current user and returns whether their email is verified.
  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      await user.reload();
      return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    } catch (e) {
      log('Unexpected error in reloadAndCheckEmailVerified: ${e.toString()}');
      return false;
    }
  }

  /// Verifies the password reset code (oobCode). Returns the email if valid.
  Future<String?> verifyPasswordResetCode(String oobCode) async {
    try {
      final email =
          await FirebaseAuth.instance.verifyPasswordResetCode(oobCode);
      return email;
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in verifyPasswordResetCode: ${e.code} - ${e.message}');
      throw CustomException(message: _mapActionCodeError(e));
    } catch (e) {
      log('Unexpected error in verifyPasswordResetCode: ${e.toString()}');
      throw CustomException(
          message: 'Unexpected error while verifying reset link.');
    }
  }

  /// Confirms the password reset with the provided code and new password.
  Future<void> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException in confirmPasswordReset: ${e.code} - ${e.message}');
      if (e.code == 'weak-password') {
        throw CustomException(message: 'The password provided is too weak.');
      }
      throw CustomException(message: _mapActionCodeError(e));
    } catch (e) {
      log('Unexpected error in confirmPasswordReset: ${e.toString()}');
      throw CustomException(
          message: 'Unexpected error while resetting password.');
    }
  }

  String _mapActionCodeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return 'This link has expired. Please request a new reset email.';
      case 'invalid-action-code':
        return 'This reset link is invalid. Please request a new one.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this link.';
      default:
        return 'Failed to process the reset link. Please try again later.';
    }
  }
}
