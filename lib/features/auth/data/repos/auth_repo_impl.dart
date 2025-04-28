import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pharma_now/constants.dart';
import 'package:pharma_now/core/errors/exceptions.dart';
import 'package:pharma_now/core/errors/failures.dart';
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

  @override
  Future<Either<Failures, UserEntity>> signinWithFacebook() async {
    User? user;
    try {
      var user = await firebaseAuthService.signInWithFacebook();

      var userEntity = UserModel.fromFirebaseUser(user);
      await addUserData(user: userEntity);
      return right(userEntity);
    } on CustomException catch (e) {
      await deleteUser(user);
      return left(ServerFailure(e.message));
    } catch (e) {
      await deleteUser(user);
      log('Exception in AuthRepoImpl.signinWithFacebook: ${e.toString()}');
      return left(ServerFailure(
          'An error occurred on the server. Please try again later.'));
    }
  }

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
  Future saveUserData({required UserEntity user}) async {
    var jsonData = jsonEncode(UserModel.fromEntity(user).toMap());
    await prefs.setString(kUserData, jsonData);
  }
}
