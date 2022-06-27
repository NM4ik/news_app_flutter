import 'dart:async';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:news/core/debug.dart';
import 'package:news/feature/data/models/user_model.dart';
import 'package:news/feature/data/repository/user_repository.dart';
import 'package:news/locator_service.dart';

class AuthenticationState extends ChangeNotifier {
  final UserRepository _userRepository = sl.get<UserRepository>();
  late StreamSubscription<UserModel?> _userSubscription;

  AuthenticationState() {
    _userSubscription = _userRepository.userModel.listen((event) {
      setCurrentUser(event);
    });
  }

  UserModel? _currentUser = FirebaseAuth.instance.currentUser == null ? null : UserModel.toUser(FirebaseAuth.instance.currentUser!);
  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  UserModel? get currentUser {
    return _currentUser;
  }

  void setCurrentUser(UserModel? value) {
    _currentUser = value;
    notifyListeners();
  }

  Future<void> googleSignIn() async {
    if (isLoading == false) {
      setLoading(true);
      final register = await _userRepository.googleLogin();
      setLoading(false);
      return register.fold((l) => l, (r) => r);
    }
  }
}
