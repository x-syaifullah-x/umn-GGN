import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/constant/constant.dart';
import 'package:simpleworld/models/user.dart';
import 'package:simpleworld/widgets/progress.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';

class SplashScreen extends StatefulWidget {
  final String? userId;

  const SplashScreen({Key? key, this.userId}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  var _visible = true;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late AnimationController animationController;
  late Animation<double> animation;

  startTime() async {
    var duration = const Duration(seconds: 1);
    return Timer(duration, navigationPage);
  }

  void navigationPage() {
    Navigator.of(context).pushReplacementNamed(APP_SCREEN);
  }

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => setState(() {}));
    animationController.forward();
    if (mounted) {
      setState(() {
        _visible = !_visible;
      });
      startTime();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _welcomeNote() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Global Girls Net',
        style: GoogleFonts.portLligatSans(
          textStyle: Theme.of(context).textTheme.headline4,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: Colors.red[800],
        ),
      ),
    );
  }

  userName() {
    return FutureBuilder<GloabalUser?>(
      future: GloabalUser.fetchUser(widget.userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        final user = snapshot.data;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _welcomeNote(),
            Text(
              user!.username.capitalize(),
              style: boldTextStyle(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Image.asset(
            "assets/images/Splash1.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
