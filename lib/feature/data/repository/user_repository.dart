import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:news/core/error/exception.dart';
import 'package:news/feature/data/models/user_model.dart';
import 'package:news/feature/data/repository/authentication_repository.dart';

class UserRepository {
  final AuthenticationRepository _authenticationRepository = AuthenticationRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection('users');

  Stream<UserModel?> get userModel {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final userModel = firebaseUser == null ? null : UserModel.toUser(firebaseUser);
      return userModel;
    });
  }

  Future<Either<ErrorHandler, UserModel>> googleLogin() async {
    try {
      final firebaseUser = await _authenticationRepository.googleSignIn();
      if (firebaseUser == null) return const Left(ErrorHandler(message: 'Неуспешный вход'));
      final snapshot = await userCollection.doc(firebaseUser.uid).get();
      if (!snapshot.exists) {
        final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            phone: firebaseUser.phoneNumber ?? '',
            photoUrl: firebaseUser.photoURL ?? '',
            displayName: firebaseUser.displayName ?? '');
        await userCollection.doc(firebaseUser.uid).set(newUser.toJson());
        final getUser = await getCurrentUser(firebaseUser.uid);
        if (getUser.isRight()) {
          UserModel? userModel = getUser.fold((l) => null, (r) => r);
          return Right(userModel!);
        } else {
          return const Left(ErrorHandler(message: 'Ошибка...'));
        }
      } else {
        final userModel = UserModel.fromJson(snapshot.data() as Map<String, dynamic>);
        return Right(userModel);
      }
    } catch (e) {
      return Left(ErrorHandler(message: e.toString()));
    }
  }

  Future<Either<ErrorHandler, UserModel>> getCurrentUser(String uid) async {
    try {
      final userSnapshot = await userCollection.doc(uid).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        final UserModel userModel = UserModel.fromJson(data);
        return Right(userModel);
      } else {
        return const Left(ErrorHandler(message: "user doesn't exit"));
      }
    } catch (e) {
      return Left(ErrorHandler(message: e.toString()));
    }
  }
}
