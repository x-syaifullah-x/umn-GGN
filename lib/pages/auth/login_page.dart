import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:global_net/ads/login_ads.dart';
import 'package:global_net/data/user.dart' as data;
import 'package:global_net/pages/auth/add_credit_to_account.dart';
import 'package:global_net/pages/auth/create_account.dart';
import 'package:global_net/pages/auth/forgotpass.dart';
import 'package:global_net/pages/auth/signup_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:global_net/widgets/language_picker_widget_home.dart';
import 'package:global_net/widgets/progress.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../menu/terms_and_conditions.dart';

const String vApiKey =
    'BIxps5Is9CmqlWy6PpPjZXiM0hTlCcnFIcFtQwos8yvFoumKit1TUpZqpkaU13KEh0n9M5pXGF8W33b1S-TFnZw';

class LoginPage extends StatefulWidget {
  const LoginPage({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final _emailNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final _passwordNode = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      log(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NotificationListener(
        onNotification: ((notification) {
          return true;
        }),
        child: SafeArea(child: _body(context)),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final AdaptiveThemeMode mode = AdaptiveTheme.of(context).mode;
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double a = (width > 750) ? (width / 5) : 20;
    return SizedBox(
      height: height,
      child: Stack(
        alignment: AlignmentDirectional.bottomCenter,
        children: [
          Stack(
            children: <Widget>[
              // Positioned(
              //   top: -height * .15,
              //   right: -MediaQuery.of(context).size.width * .4,
              //   child: const BezierContainer(),
              // ),
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg_login_page.jpg'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(left: a, right: a),
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
                            const LanguagePickerWidgetHome(),
                          ],
                        ),
                      ),
                      SizedBox(height: height * .12),
                      _title(),
                      const SizedBox(height: 50),
                      _emailPasswordWidget(),
                      const SizedBox(height: 20),
                      _loginButton(),
                      _forgotPassword(),
                      _divider(),
                      SignInButton(
                        Buttons.GoogleDark,
                        onPressed: () {
                          _signInWithGoogle();
                        },
                      ),
                      SizedBox(height: height * .055),
                      _createAccount(),
                      terms(),
                      const SizedBox(
                        height: 70,
                      )
                    ],
                  ),
                ),
              ),
              // Container(
              //   // padding: const EdgeInsets.symmetric(horizontal: 20),
              //   padding: EdgeInsets.only(left: a, right: a),
              //   child: ,
              // ),
              _isLoading == true
                  ? Center(child: circularProgress())
                  : Container(),
            ],
          ),
          const LoginAds()
        ],
      ),
    );
  }

  Widget _entryField(
    String title,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
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
              filled: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _loginButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(5),
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.red.shade500, Colors.red.shade900],
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.login,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      if (_emailController.text != '' && _passwordController.text != '') {
        setState(() {
          _emailNode.unfocus();
          _passwordNode.unfocus();
          _isLoading = true;
        });
        _signInWithEmailAndPassword();
      } else {
        setState(() {
          _emailNode.unfocus();
          _passwordNode.unfocus();
        });
        simpleworldtoast('Error', 'Email and password is required', context);
      }
    });
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final User? user = userCredential.user;
      if (user != null) {
        _dataEntry(user.uid, user.email!);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      simpleworldtoast('Error', 'Please try again', context);
    }
  }

  void _dataEntry(String userId, String email) async {
    _saveUserIdToLocal(userId: userId).then((value) async {
      final userDocRef = usersCollection.doc(userId);
      await _setTokenNotification(docRef: userDocRef);
      userDocRef.get().then((userDoc) {
        if (userDoc.exists) {
          setState(() {
            globalUserId = userId;
            _isLoading = false;
          });

          if (userDoc[data.User.fieldNameUsername].length > 0) {
            if (userDoc.data()!.containsKey(data.User.fieldNameCreditPoints)) {
              if ('${userDoc[data.User.fieldNameCreditPoints]}' == '0') {
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => AddCreditToAccount(
                      userId: userId,
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => Home(userId: userId),
                  ),
                );
              }
            } else {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  builder: (context) => Home(userId: userId),
                ),
              );
            }
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateAccount(
                  userId: userId,
                ),
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          simpleworldtoast(
            'Error',
            'Failed to sign in with Google, please try again:',
            context,
          );
        }
      });
      // FirebaseMessaging.onMessage.listen((message) async {
      //   final String recipientId = userId;
      //   final String body = message.notification?.body ?? '';
      //   if (recipientId == userId) {
      //     SnackBar snackbar = SnackBar(
      //         content: Text(
      //       body,
      //       overflow: TextOverflow.ellipsis,
      //     ));
      //     ScaffoldMessenger.of(context).showSnackBar(snackbar);
      //   }
      // });
    });
  }

  Future<bool> _saveUserIdToLocal({required String userId}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.setString(SharedPreferencesKey.userId, userId);
  }

  Future _setTokenNotification({
    required DocumentReference docRef,
  }) async {
    try {
      String? token = await FirebaseMessaging.instance
          .getToken(vapidKey: (kIsWeb ? vApiKey : null));
      log('tokenNotification: $token');
      docRef.update({
        data.User.fieldNameTokenNotfaction: token,
      });
    } catch (e) {
      log(e);
    }
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

  // Future _createAppleUser(
  //   String userId,
  //   String email,
  //   String name,
  // ) async {
  //   DocumentReference docRef = usersCollection.doc(userId);
  //   DocumentSnapshot doc = await docRef.get();

  //   if (!doc.exists) {
  //     final DateTime date = DateTime.now();
  //     final dataUser = data.User(
  //       id: userId,
  //       username: '',
  //       photoUrl: '',
  //       email: email,
  //       displayName: name,
  //       bio: '',
  //       coverUrl: '',
  //       groups: [],
  //       loginType: 'ios',
  //       timestamp: date.millisecondsSinceEpoch,
  //       userIsVerified: false,
  //       creditPoints: "0",
  //       noAds: false,
  //       tokenNotfaction: '',
  //     );
  //     await usersCollection.doc(dataUser.id).set(dataUser.toJson());
  //     await followersCollection
  //         .doc(dataUser.id)
  //         .collection('userFollowers')
  //         .doc(dataUser.id)
  //         .set({'userId': dataUser.id});

  //     doc = await usersCollection.doc(dataUser.id).get();
  //   }

  //   setState(() {
  //     globalUserId = userId;
  //     _isLoading = false;
  //   });

  //   _saveUserIdToLocal(userId: userId);
  //   _saveTokenNotification(docRef: docRef);

  //   if (mounted) {
  //     Navigator.of(context).pushReplacement(
  //       CupertinoPageRoute(builder: (context) => const CreateAccount()),
  //     );
  //   }
  // }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _emailNode.unfocus();
        _passwordNode.unfocus();
        _isLoading = true;
      });
      UserCredential userCredential;

      if (kIsWeb) {
        var googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;
        final googleAuthCredential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(googleAuthCredential);
      }

      final user = userCredential.user;

      if (user != null) {
        checkUserExists(
          user.uid,
          user.email,
          user.displayName ?? '',
          user.photoURL ?? '',
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      log(e);
      simpleworldtoast('Error', 'Failed to sign in with Google', context);
    }
  }

  checkUserExists(userId, email, name, photoUrl) async {
    usersCollection.doc(userId).get().then((docRef) {
      if (docRef.exists) {
        _dataEntry(userId, email);
      } else {
        _createUserInFirestore(
          userId: userId,
          email: email,
          name: name,
          photoUrl: photoUrl,
        );
      }
    });
  }

  Future _createUserInFirestore({
    required String userId,
    required String email,
    required String name,
    required String photoUrl,
  }) async {
    DocumentReference docRef = usersCollection.doc(userId);
    DocumentSnapshot doc = await docRef.get();
    if (!doc.exists) {
      final DateTime date = DateTime.now();
      final dataUser = data.User(
        id: userId,
        username: '',
        photoUrl: photoUrl,
        email: email,
        displayName: name,
        bio: '',
        coverUrl: '',
        groups: [],
        loginType: 'google',
        timestamp: date.millisecondsSinceEpoch,
        userIsVerified: false,
        creditPoints: 0,
        noAds: false,
        tokenNotfaction: '',
        active: true,
      );
      await usersCollection.doc(dataUser.id).set(dataUser.toJson());
      await followersCollection
          .doc(userId)
          .collection('userFollowers')
          .doc(userId)
          .set({'userId': userId});
      doc = await usersCollection.doc(userId).get();
    }

    setState(() {
      globalUserId = userId;
      _isLoading = false;
    });

    _saveUserIdToLocal(userId: userId);
    _setTokenNotification(docRef: docRef);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => CreateAccount(
            userId: userId,
          ),
        ),
      );
    }
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
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.register,
              style: TextStyle(
                color: Colors.red[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget terms() {
    return InkWell(
      onTap: () {
        const url =
            'https://docs.google.com/document/d/e/2PACX-1vSVsg1yyLr-VC9yJ04vB-BtVoo3TGGrL8PRGzXgbb6QOaiZBiV9WLOKRuTlDzSUEgr_xOXVhax-_T2X/pub';
        if (kIsWeb) {
          launchUrl(Uri.parse(url));
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TermsAndConditions(
                url: url,
              ),
            ),
          );
        }
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
          textStyle: Theme.of(context).textTheme.headlineMedium,
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
        _entryField(AppLocalizations.of(context)!.email_id, _emailController),
        _entryField(AppLocalizations.of(context)!.password, _passwordController,
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
              _emailNode.unfocus();
              _passwordNode.unfocus();
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
  // String _generateNonce([int length = 32]) {
  //   const charset =
  //       '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  //   final random = Random.secure();
  //   return List.generate(length, (_) => charset[random.nextInt(charset.length)])
  //       .join();
  // }

  /// Returns the sha256 hash of [input] in hex notation.
  // String _sha256ofString(String input) {
  //   final bytes = utf8.encode(input);
  //   final digest = sha256.convert(bytes);
  //   return digest.toString();
  // }

  // Future<UserCredential> signInWithApple() async {
  //   final rawNonce = generateNonce();
  //   final nonce = _sha256ofString(rawNonce);
  //   UserCredential userCredential;

  //   setState(() {
  //     _isLoading = false;
  //   });
  //   return simpleworldtoast(
  //       "Error", 'Failed to sign in with Apple ID', context);
  // }
}
