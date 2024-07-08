import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:global_net/domain/result.dart';
import 'package:global_net/pages/auth/data/models/auth_result.dart';
import 'package:global_net/pages/auth/data/models/sign_type.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

import 'models/exeptions/sign_up_param_exception.dart';

class AuthRepository {
  AuthRepository._internal();

  static AuthRepository? _instance;

  factory AuthRepository.getInstance() {
    _instance ??= AuthRepository._internal();
    return _instance!;
  }

  Future<Result> sign(SignType type) async {
    try {
      final auth = FirebaseAuth.instance;
      final firebaseFirestore = FirebaseFirestore.instance;
      final userCollectionRef = firebaseFirestore.collection('users');
      late UserCredential userCredential;
      bool isNewUser = true;
      Map<String, dynamic> data = {
        'id': '',
        'username': '',
        'photoUrl': '',
        'email': '',
        'displayName': '',
        'bio': '',
        'coverUrl': '',
        'groups': [],
        'loginType': '',
        'timestamp': DateTime.now(),
        'userIsVerified': false,
        'credit_points': 0,
        'no_ads': false,
        'active': true
      };
      if (type is SignTypeGoogle) {
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
          userCredential =
              await auth.signInWithCredential(googleAuthCredential);
        }

        final user = userCredential.user;
        final userDocumentSnapshot =
            await userCollectionRef.doc(user?.uid).get();
        final isRegister = userDocumentSnapshot.exists;
        if (isRegister) {
          final userData = userDocumentSnapshot.data();
          if (userData != null) {
            data = userData;
            isNewUser = false;
          }
        }
        if (isNewUser) {
          data['id'] = '${user?.uid}';
          data['username'] = '${user?.displayName}';
          data['email'] = '${user?.email}';
          data['displayName'] = '${user?.displayName}';
          data['loginType'] = 'google';
        }
      } else if (type is SignTypeEmail) {
        final username = type.username;
        if (username.isEmptyOrNull) {
          return ResultError(
            SignUpParamException(
              message: 'Please enter your username.',
            ),
          );
        }

        RegExp regex = RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
        );
        final email = type.email;

        if (!regex.hasMatch(email)) {
          return ResultError(
            SignUpParamException(
              message: 'Please enter the correct email.',
            ),
          );
        }

        final password = type.password;
        if (password.length < 6) {
          return ResultError(
            SignUpParamException(
              message: 'Password must be 6 characters or more.',
            ),
          );
        }

        if (!type.termsAndPrivacyPolicy) {
          return ResultError(
            SignUpParamException(
              message: 'Accept term & condition to continue',
            ),
          );
        }

        final usernameQuerySnapshot = await userCollectionRef
            .where('username', isEqualTo: username)
            .get();
        final isExist = usernameQuerySnapshot.docs.isNotEmpty;
        if (isExist) {
          return ResultError({'message': 'Username is taken '});
        }

        final auth = FirebaseAuth.instance;
        userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final user = userCredential.user;
        data['id'] = '${user?.uid}';
        data['username'] = username;
        data['email'] = email;
        data['displayName'] = username;
        data['loginType'] = 'app';
      } else {
        return ResultError({
          'message': 'not implemented',
        });
      }
      final userId = data['id'] as String;
      final userDocumentRef = userCollectionRef.doc(userId);
      if (isNewUser) {
        await userDocumentRef.set(data);
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setString(SharedPreferencesKey.userId, userId);
      return ResultSuccess(AuthResult(uid: userId, isNewUser: isNewUser));
    } catch (e) {
      return ResultError({
        'message': '$e',
      });
    }
  }
}
