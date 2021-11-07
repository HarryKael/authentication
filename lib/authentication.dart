import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? user;

  Authentication() {
    auth.authStateChanges().listen((User? user2) {
      user = user2;
      if (user != null) {
        debugPrint(
            '============= Change =============== EmailVerified ${user!.emailVerified}');
      }
    });
  }

  String isLogged() {
    User? _user = auth.currentUser;
    if (_user != null) {
      return _user.uid;
    } else {
      return 'false';
    }
  }

  Future<bool?> checkEmailVerificaton() async {
    if (user != null) {
      return user!.reload().then((_) {
        debugPrint(
            '=================Realoading================= ${user!.emailVerified}');
        return user!.emailVerified;
      }).onError((error, stackTrace) {
        return false;
      });
    } else {
      return null;
    }
  }

  void sendEmailVerification() async {
    User? _user = auth.currentUser;

    if (_user != null && !_user.emailVerified) {
      _user.sendEmailVerification();
    }
  }

  Future<String> registration(
      {required String email, required String password}) {
    return auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      return value.user!.uid;
    });
  }

  // if (e.code == 'weak-password') {
  //       print('The password provided is too weak.');
  //     } else if (e.code == 'email-already-in-use') {
  //       print('The account already exists for that email.');
  //     }

  Future<UserCredential?> signIn(
      {required String email, required String password}) {
    return auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser != null) {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await auth.signInWithCredential(credential);
    }
    return null;
  }

  // if (e.code == 'user-not-found') {
  //       print('No user found for that email.');
  //     } else if (e.code == 'wrong-password') {
  //       print('Wrong password provided for that user.');
  //     }

  Future<void> signOut() async {
    bool value = await _googleSignIn.isSignedIn();
    if (value) {
      await _googleSignIn.signOut();
      await auth.signOut();
    } else {
      await auth.signOut();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(
      {required String code, required String newPassword}) {
    return auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }
}
