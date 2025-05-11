import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_now/core/errors/exceptions.dart';

class FirebaseAuthService {
  Future deleteUser() async {
    await FirebaseAuth.instance.currentUser!.delete();
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
          throw CustomException(
              message: 'Incorrect password. Please try again.');
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
}
