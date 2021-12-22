import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Response {
  UserCredential? userCredential;
  String result;
  Response({
    this.userCredential,
    required this.result,
  });

  Response copyWith({
    UserCredential? userCredential,
    String? result,
  }) {
    return Response(
      userCredential: userCredential ?? this.userCredential,
      result: result ?? this.result,
    );
  }

  @override
  String toString() =>
      'Response(userCredential: $userCredential, result: $result)';
}

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
      // debugPrint(
      //     '=================Realoading================= ${user!.emailVerified}');
      // return user!.emailVerified;
      try {
        await user!.reload();
        debugPrint(
            '=================Realoading================= ${auth.currentUser!.emailVerified}');

        user = auth.currentUser;
        return auth.currentUser!.emailVerified;
      } catch (e) {
        return false;
      }
    } else {
      return null;
    }
  }

  void sendEmailVerification() async {
    try {
      User? _user = auth.currentUser;

      if (_user != null && !_user.emailVerified) {
        _user.sendEmailVerification();
      }
    } catch (e) {}
  }

  Future<Response> registration(
      {required String email, required String password}) async {
    try {
      UserCredential _userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return Response(userCredential: _userCredential, result: 'ok');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return Response(
              result:
                  'There already exists an account with the given email address.');
        case 'invalid-email':
          return Response(result: 'The email address is not valid.');

        case 'operation-not-allowed':
          return Response(result: 'email/password accounts are not enabled.');

        case 'weak-password':
          return Response(result: 'The password is not strong enough.');

        default:
          return Response(
              result: 'Failed -> code: ${e.code}; message: ${e.message!}');
      }
    }
  }

  Future<Response> signIn(
      {required String email, required String password}) async {
    try {
      UserCredential _userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return Response(userCredential: _userCredential, result: 'ok');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return Response(result: 'The email address is not valid.');

        case 'user-disabled':
          return Response(
              result:
                  'The user corresponding to the given email has been disabled.');

        case 'user-not-found':
          return Response(
              result: 'There is no user corresponding to the given email.');

        case 'wrong-password':
          return Response(
              result:
                  'The password is invalid for the given email, or the account corresponding to the email does not have a password set.');

        default:
          return Response(
              result: 'Failed -> code: ${e.code}; message: ${e.message!}');
      }
    }
    // changed
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

  Future<Response> sendPasswordResetEmail({required String email}) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return Response(result: 'ok');
    } on FirebaseAuthException catch (e) {
      return Response(
          result: 'Failed -> code: ${e.code}; message: ${e.message!}');
    }
  }

  Future<void> confirmPasswordReset(
      {required String code, required String newPassword}) {
    return auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }
}
