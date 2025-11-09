import '../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  AuthService(this._auth, this._db);
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String> signUp({
    required String email,
    required String displayName,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user != null) {
        await user.sendEmailVerification();

        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          displayName: displayName,
        );

        await _db.collection('users').doc(user.uid).set(newUser.toMap());

        return "Success";
      }
      return "An unknown error occurred.";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else {
        return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      } else {
        return e.message ?? 'An error occurred.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<String> resendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return "Success";
      }
      return "No user to verify.";
    } catch (e) {
      return e.toString();
    }
  }
}
