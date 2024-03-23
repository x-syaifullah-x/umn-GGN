import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/auth/signup_page2.dart';
import 'package:global_net/pages/webview/webview.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:global_net/widgets/simple_world_widgets.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late String userId;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isAuth = false;

  bool _isCheckTermsAndPrivacyPolicy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener(
        child: _body(context),
        onNotification: (notification) => true,
      ),
    );
  }

  Widget _body(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    final double a = (width > 750) ? (width / 5) : 20;
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Positioned(
          //   top: -MediaQuery.of(context).size.height * .15,
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
                  SizedBox(height: height * .2),
                  _title(),
                  const SizedBox(
                    height: 50,
                  ),
                  _fieldInput(),
                  const SizedBox(
                    height: 20,
                  ),
                  _termsCondition(context),
                  const SizedBox(
                    height: 20,
                  ),
                  _registerButton(context),
                  SizedBox(height: height * .14),
                  _loginAccount(),
                ],
              ),
            ),
          ),
          Positioned(top: 40, left: 0, child: _backButton()),
        ],
      ),
    );
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left,
                  color: Theme.of(context).iconTheme.color),
            ),
            Text(AppLocalizations.of(context)!.back,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, TextEditingController controller,
      TextInputAction textInputAction,
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
              textInputAction: textInputAction,
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

  _termsCondition(BuildContext context) {
    void handleURLButtonPress(BuildContext context, String url) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => WebViewContainer(url)));
    }

    return CheckboxListTile(
      title: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget>[
          Text(AppLocalizations.of(context)!.consent,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                // color: appColorBlack,
              )),
          InkWell(
            onTap: () {
              handleURLButtonPress(context,
                  'https://sites.google.com/view/simple-worlds-help-center/privacy-policy');
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => const TermofUsePage()));
            },
            child: Text(AppLocalizations.of(context)!.terms_and_conditions,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          Text(AppLocalizations.of(context)!.and,
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                // color: appColorBlack,
              )),
          InkWell(
            onTap: () {
              handleURLButtonPress(
                context,
                'https://sites.google.com/view/simple-worlds-help-center/privacy-policy',
              );
            },
            child: Text(
              AppLocalizations.of(context)!.privacy_policy,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.normal,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      value: _isCheckTermsAndPrivacyPolicy,
      onChanged: (newValue) {
        setState(() {
          _isCheckTermsAndPrivacyPolicy = newValue!;
        });
      },
      controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
    );
  }

  Widget _registerButton(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.red.shade500, Colors.red.shade900],
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.register_now,
        style: const TextStyle(fontSize: 20, color: Colors.white),
      ),
    ).onTap(() {
      RegExp regex = RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

      if (_usernameController.text.isEmptyOrNull) {
        simpleAlertBox(
          context: context,
          content: const Text('Please enter your username.'),
        );
        return;
      }

      if (!regex.hasMatch(_emailController.text.trim())) {
        simpleAlertBox(
          context: context,
          content: const Text('Please enter the correct email.'),
        );
        return;
      }

      if (_passwordController.text.length < 6) {
        simpleAlertBox(
          context: context,
          content: const Text('Password must be 6 characters or more.'),
        );
        return;
      }

      if (!_isCheckTermsAndPrivacyPolicy) {
        simpleAlertBox(
          context: context,
          content: Text(AppLocalizations.of(context)!.consent_error),
        );
        return;
      }

      _register(context);
    });
  }

  Future<void> _register(BuildContext context) async {
    try {
      final valid = await _usernameCheck(_usernameController.text);
      if (!valid) {
        setState(() {
          if (mounted) {
            simpleworldtoast('Error', 'Username is taken ', context);
          }
        });
      } else {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        final User? user = userCredential.user;
        if (user != null) {
          _createUserInFirestore(user.uid, user.email);
        } else {
          setState(() {
            isAuth = false;
          });

          if (mounted) {
            simpleworldtoast(
              'Error',
              'Something went wrong please try again ',
              context,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isAuth = false;
      });
      simpleworldtoast(
        'Error',
        'The email address is already in use by anoter account',
        context,
      );
    }
  }

  Future<bool> _usernameCheck(String username) async {
    try {
      final result =
          await usersCollection.where('username', isEqualTo: username).get();
      return result.docs.isEmpty;
    } catch (e) {
      return Future.value(false);
    }
  }

  _createUserInFirestore(userId, email) async {
    User? user = firebaseAuth.currentUser;
    DocumentSnapshot doc = await usersCollection.doc(user!.uid).get();

    if (!doc.exists) {
      usersCollection.doc(userId).set({
        'id': userId,
        'username': _usernameController.text,
        'photoUrl': '',
        'email': email,
        'displayName': _usernameController.text,
        'bio': '',
        'coverUrl': '',
        'groups': [],
        'loginType': 'app',
        'timestamp': timestamp,
        'userIsVerified': false,
        'credit_points': 0,
        'no_ads': false,
        'active': true
      });
      await followersCollection
          .doc(userId)
          .collection('userFollowers')
          .doc(userId)
          .set({'userId': userId});

      doc = await usersCollection.doc(userId).get();
    }

    setState(() {
      globalUserId = userId;
      isAuth = true;
    });

    configurePushNotifications(userId);
    if (isAuth) {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => GetAvatar(currentUserId: userId),
        ),
      );
    }
  }

  configurePushNotifications(userId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences
        .setString(SharedPreferencesKey.userId, userId)
        .then((value) async {
      try {
        String? token = await FirebaseMessaging.instance
            .getToken(vapidKey: (kIsWeb ? vApiKey : null));
        await usersCollection.doc(userId).update({
          'tokenNotification': token,
        });
      } catch (e) {
        debugPrint('$e');
      }
    });

    FirebaseMessaging.onMessage.listen((message) async {
      final String recipientId = userId;
      final String body = message.notification?.body ?? '';

      if (recipientId == userId) {
        SnackBar snackbar = SnackBar(
          content: Text(
            body,
            overflow: TextOverflow.ellipsis,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    });
  }

  Widget _loginAccount() {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.have_account,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              AppLocalizations.of(context)!.login,
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
        text: 'Global  Net',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headlineMedium,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  Widget _fieldInput() {
    return Column(
      children: <Widget>[
        _entryField(
          AppLocalizations.of(context)!.username,
          _usernameController,
          TextInputAction.next,
        ),
        _entryField(
          AppLocalizations.of(context)!.email_id,
          _emailController,
          TextInputAction.next,
        ),
        _entryField(
          AppLocalizations.of(context)!.password,
          _passwordController,
          TextInputAction.next,
          isPassword: true,
        ),
      ],
    );
  }
}
