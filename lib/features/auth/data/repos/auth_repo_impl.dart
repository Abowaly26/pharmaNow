import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:pharma_now/core/errors/failures.dart';
import 'package:pharma_now/features/auth/data/models/user_model.dart';
import 'package:pharma_now/features/auth/domain/repo/auth_repo.dart';
import 'package:pharma_now/features/auth/domain/repo/entities/user_entity.dart';

import '../../../../core/services/firebase_auth_service.dart';

class AuthRepoImpl extends AuthRepo {
  final FirebaseAuthService firebaseAuthService;

  AuthRepoImpl({required this.firebaseAuthService});

  @override
  Future<Either<Failures, UserEntity>> createUserWithEmailAndPassword(
      String email, String password, String name) async {
    try {
      var user = await firebaseAuthService.createUserWithEmailAndPassword(
          email: email, password: password);

      return right(UserModel.fromFirebaseUser(user));
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.createUserWithEmailAndPassword: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      var user = await firebaseAuthService.signInWithEmailAndPassword(
          email: email, password: password);

      return right(UserModel.fromFirebaseUser(user));
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.signInWithEmailAndPassword: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signinWithGoogle() async {
    try {
      var user = await firebaseAuthService.signInWithGoogle();

      return right(UserModel.fromFirebaseUser(user));
    } catch (e) {
      log('Exception in AuthRepoImpl.singinWithGoogle: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

  @override
  Future<Either<Failures, UserEntity>> signinWithFacebook() async {
    try {
      var user = await firebaseAuthService.signInWithFacebook();

      return right(UserModel.fromFirebaseUser(user));
    } on CustomException catch (e) {
      return left(ServerFailure(e.message));
    } catch (e) {
      log('Exception in AuthRepoImpl.signinWithFacebook: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }
}
