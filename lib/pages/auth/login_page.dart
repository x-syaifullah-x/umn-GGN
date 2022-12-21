// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/pages/auth/add_credit_to_account.dart';
import 'package:simpleworld/pages/auth/create_account.dart';
import 'package:simpleworld/pages/auth/forgotpass.dart';
import 'package:simpleworld/pages/home.dart';
import 'package:simpleworld/pages/auth/signup_page.dart';
import 'package:simpleworld/pages/menu/term_of_use.dart';
import 'package:simpleworld/share_preference/preferences_key.dart';
import 'package:simpleworld/widgets/bezier_container.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:simpleworld/widgets/language_picker_widget_home.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

GloabalUser? currentUser;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final emailNode = FocusNode();
  final passwordNode = FocusNode();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool isAuth = false;

  @override
  void initState() {
    super.initState();
    getUserData();
    FirebaseMessaging.instance.getInitialMessage().then((message) {});
  }

  getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      usersRef.doc(user.uid).get().then((peerData) {
        if (peerData.exists) {
          if (mounted) {
            setState(() {
              globalID = user.uid;
              globalName = peerData['username'];
              globalImage = peerData['photoUrl'];
              globalBio = peerData['bio'];
              globalCover = peerData['coverUrl'];
              globalDisplayName = peerData['displayName'];
              globalCredits = peerData['credit_points'];
            });
          }
        }
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
              controller: controller,
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.red.shade500, Colors.red.shade900])),
      child: Text(
        AppLocalizations.of(context)!.login,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      if (emailController.text != '' && passwordController.text != '') {
        setState(() {
          emailNode.unfocus();
          passwordNode.unfocus();
          isLoading = true;
        });

        _signInWithEmailAndPassword();
      } else {
        setState(() {
          emailNode.unfocus();
          passwordNode.unfocus();
        });
        simpleworldtoast("Error", "Email and password is required", context);
      }
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      final User? user = (await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      ))
          .user;
      if (user != null) {
        dataEntry(user.uid, user.email);
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      simpleworldtoast("Error", "Please try again", context);
    }
  }

  dataEntry(userId, email) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences
        .setString(SharedPreferencesKey.LOGGED_IN_USERRDATA, userId)
        .then((value) {
      FirebaseMessaging.instance.getToken().then((token) {
        usersRef.doc(userId).update({
          "androidNotificationToken": token,
        }).then((value) {
          usersRef.doc(userId).get().then((peerData) {
            if (peerData.exists) {
              setState(() {
                globalID = userId;
                isLoading = false;
              });
              if (peerData['username'].length > 0) {
                if (peerData.data()!.containsKey('credit_points') ) {
                  if (peerData['credit_points']== 0 ) {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (context) => AddCreditToAccount(
                        userId: globalID,
                      ),
                    ),
                  );
                }  else {
                    Navigator.of(context).pushReplacement(
                        CupertinoPageRoute(
                        builder: (context) => Home(userId: globalID)));
                  }

                } else {
                  Navigator.of(context).pushReplacement(
                    CupertinoPageRoute(
                      builder: (context) => Home(userId: globalID),
                    ),
                  );
                }
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateAccount()));
              }
            } else {
              setState(() {
                isLoading = false;
              });
              simpleworldtoast("Error",
                  'Failed to sign in with Google, please try again:', context);
            }
          });
        });
      });
      FirebaseMessaging.onMessage.listen(
        (message) async {
          final String recipientId = userId;
          final String body = message.notification?.body ?? '';

          if (recipientId == userId) {
            print("Notification shown!");
            SnackBar snackbar = SnackBar(
                content: Text(
              body,
              overflow: TextOverflow.ellipsis,
            ));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          }
        },
      );
    });
  }

  Widget _divider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 20,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.or,
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _googleButton() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xff1959a9),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    topLeft: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: const Text('G',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w400)),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              alignment: Alignment.center,
              child: const Text('Log in with Google',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    ).onTap(() {
      _signInWithGoogle();
    });
  }

  checkappleUserExists(userId, email, name) async {
    usersRef.doc(userId).get().then((peerData) {
      if (peerData.exists) {
        dataEntry(userId, email);
      } else {
        createappleUserInFirestore(userId, email, name);
        print('user does not exist');
      }
    });
  }

  createappleUserInFirestore(userId, email, name) async {
    DocumentSnapshot doc = await usersRef.doc(userId).get();

    if (!doc.exists) {
      usersRef.doc(userId).set({
        "id": userId,
        "username": '',
        "photoUrl": '',
        "email": email,
        "displayName": name,
        "bio": "",
        "coverUrl": "",
        "groups": [],
        "loginType": 'ios',
        "timestamp": timestamp,
        "userIsVerified": false,
        "credit_points": 0,
        "no_ads": false,
      });
      await followersRef
          .doc(userId)
          .collection('userFollowers')
          .doc(userId)
          .set({'userId': userId});

      doc = await usersRef.doc(userId).get();
    }

    currentUser = GloabalUser.fromDocument(doc);

    setState(() {
      globalID = userId;
      isLoading = false;
      isAuth = true;
    });

    configurePushNotifications(userId);
    if (isAuth = true) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const CreateAccount()),
      );
    }
  }

  Widget _iosButton() {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        emailNode.unfocus();
        passwordNode.unfocus();
        isLoading = true;
      });
      UserCredential userCredential;

      if (kIsWeb) {
        var googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      }
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final googleAuthCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(googleAuthCredential);

      final user = userCredential.user;

      if (user!.uid != null) {
        checkUserExists(user.uid, user.email, user.displayName, user.photoURL);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(e);
      simpleworldtoast("Error", 'Failed to sign in with Google', context);
    }
  }

  checkUserExists(userId, email, name, image) async {
    usersRef.doc(userId).get().then((peerData) {
      if (peerData.exists) {
        dataEntry(userId, email);
      } else {
        createUserInFirestore(userId, email, name, image);
      }
    });
  }

  createUserInFirestore(userId, email, name, image) async {
    DocumentSnapshot doc = await usersRef.doc(userId).get();

    if (!doc.exists) {
      usersRef.doc(userId).set({
        "id": userId,
        "username": '',
        "photoUrl": image,
        "email": email,
        "displayName": name,
        "bio": "",
        "coverUrl": "",
        "groups": [],
        "loginType": 'google',
        "timestamp": timestamp,
        "userIsVerified": false,
        "credit_points": 0,
        "no_ads": false,
      });
      await followersRef
          .doc(userId)
          .collection('userFollowers')
          .doc(userId)
          .set({'userId': userId});

      doc = await usersRef.doc(userId).get();
    }

    currentUser = GloabalUser.fromDocument(doc);

    setState(() {
      globalID = userId;
      isLoading = false;
      isAuth = true;
    });

    configurePushNotifications(userId);
    if (isAuth = true) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => const CreateAccount()),
      );
    }
  }

  configurePushNotifications(userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final prefs = await SharedPreferences.getInstance();

    preferences
        .setString(SharedPreferencesKey.LOGGED_IN_USERRDATA, userId)
        .then((value) {
      _firebaseMessaging.getToken().then((token) {
        print("Firebase Messaging Token: $token\n");
        usersRef.doc(userId).update({"androidNotificationToken": token});
      });
    });
    FirebaseMessaging.onMessage.listen(
      (message) async {
        final String recipientId = userId;
        final String body = message.notification?.body ?? '';

        if (recipientId == userId) {
          print("Notification shown!");
          SnackBar snackbar = SnackBar(
              content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      },
    );
  }

  Widget _createAccount() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const SignUpPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.not_account,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.register,
              style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget terms() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const TermofUsePage()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.terms_and_conditions,
              style: TextStyle(
                  color: Colors.red[800],
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Global Net',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _emailPasswordWidget() {
    return Column(
      children: <Widget>[
        _entryField(AppLocalizations.of(context)!.email_id, emailController),
        _entryField(AppLocalizations.of(context)!.password, passwordController,
            isPassword: true),
      ],
    );
  }

  Widget _forgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: Align(
        alignment: Alignment.topRight,
        child: InkWell(
          onTap: () {
            setState(() {
              emailNode.unfocus();
              passwordNode.unfocus();
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ForgetPass()),
            );
          },
          child: Text.rich(
            TextSpan(
              text: AppLocalizations.of(context)!.forgot_password,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    UserCredential userCredential;








    setState(() {
      isLoading = false;
    });
    print(e);
    return simpleworldtoast(
        "Error", 'Failed to sign in with Apple ID', context);
  }

  @override
  Widget build(BuildContext context) {
    final mode = AdaptiveTheme.of(context).mode;

    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SizedBox(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: const BezierContainer()),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        alignment: Alignment.bottomLeft,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (mode == AdaptiveThemeMode.light) {
                                  AdaptiveTheme.of(context).setDark();
                                } else {
                                  AdaptiveTheme.of(context).setLight();
                                }
                              },
                              icon: mode == AdaptiveThemeMode.light
                                  ? const Icon(Icons.light_mode)
                                  : const Icon(Icons.dark_mode),
                            ),
                            LanguagePickerWidgetHome(),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .12),
                      _title(),
                      const SizedBox(height: 50),
                      _emailPasswordWidget(),
                      const SizedBox(height: 20),
                      _submitButton(),
                      _forgotPassword(),
                      _divider(),

                      isApple ? _iosButton() : Container(),
                      SizedBox(height: height * .055),
                      _createAccount(),
                      terms(),
                    ],
                  ),
                ),
              ),
              isLoading == true
                  ? Center(child: circularProgress())
                  : Container(),
            ],
          ),
        ));
  }
}
