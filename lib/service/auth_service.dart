import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService() {
    FirebaseAuth.instance.authStateChanges().listen(authStateChangeStream);
  }
  User? _user;

// getter to get the _user
  User? get user => _user;
  Future<bool> Login(String email, String password) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    try {
      final crediential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (crediential.user != null) {
        _user = crediential.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  void authStateChangeStream(User? user) {
    if (user != null) {
      _user = user;
    } else {
      _user = null;
    }
  }

  //function to logout
  Future<bool> logOut() async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    try {
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  // function to signup
  Future<bool> signUp(String email, String password) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    try {
      final crediential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (crediential.user != null) {
        _user = crediential.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }
}
