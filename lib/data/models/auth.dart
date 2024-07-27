import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthInterface {
  void signIn();
  void signOut();
}

class Auth implements AuthInterface {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<String> signIn() async {
    try {
      await _firebaseAuth.signInAnonymously();
      return 'You have successfully signed in !';
    } on FirebaseAuthException catch (exception){
      return exception.message!;
    } catch (exception) {
      return 'An unknown error occurred !';
    }
  }

  @override
  Future<String?> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return 'user signed out';
    } catch (e) {
      return 'an error occurred while signing out';
    }
  }
}
