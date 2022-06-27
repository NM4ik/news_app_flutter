import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news/core/debug.dart';
import 'package:news/feature/data/models/user_model.dart';

class AuthenticationRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleAuth = GoogleSignIn();
  final GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();

  Stream<UserModel?> get streamUser => _firebaseAuth.authStateChanges().map((user) => user != null ? UserModel.toUser(user) : null);

  Future<UserCredential?> _singInWithCredential() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      errorPrint(e);
      return null;
    }
  }

  Future<User?> googleSignIn() async {
    try {
      final userCredential = await _singInWithCredential();
      if (userCredential?.user != null) {
        return userCredential!.user;
      }
    } catch (e) {
      errorPrint(e);
    }
    return null;
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleAuth.signOut(),
      ]);
    } catch (e) {
      errorPrint(e);
    }
  }
}
