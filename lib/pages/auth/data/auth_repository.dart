import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:global_net/domain/resources.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/pages/auth/data/auth_a.dart';
import 'package:global_net/pages/auth/data/auth_result.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

class AuthRepository {
  AuthRepository._internal();

  static AuthRepository? _instance;

  factory AuthRepository.getInstance() {
    _instance ??= AuthRepository._internal();
    return _instance!;
  }

  Future<Result> sign(Type arg) async {
    if (arg is TypeGoogle) {
      final auth = FirebaseAuth.instance;
      late UserCredential userCredential;
      if (kIsWeb) {
        var googleProvider = GoogleAuthProvider();
        userCredential = await auth.signInWithPopup(googleProvider);
      } else {
        final googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        final googleSignInAccount = await googleSignIn.signIn();
        final googleSignInAuthentication =
            await googleSignInAccount?.authentication;
        if (googleSignInAuthentication == null) {
          return ResultError({
            'message': 'sign with google is cancel',
          });
        }
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        userCredential = await auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;
      final uid = user?.uid;
      if (uid == null) {
        return ResultError({
          'message': 'uid null',
        });
      }
      final userCollectionReference =
          FirebaseFirestore.instance.collection('users');
      final userDocumentSnapshot = await userCollectionReference.doc(uid).get();
      final isRegister = userDocumentSnapshot.exists;
      return ResultSuccess(AuthResult(uid: uid, isNewUser: isRegister));
    }
    return ResultError({
      'message': 'not implemented',
    });
  }
}
