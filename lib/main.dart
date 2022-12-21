// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/constant/constant.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/splashscreen.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await Firebase.initializeApp();
  MobileAds.instance.initialize();


  await initialize();

  SharedPreferences.getInstance().then(
    (prefs) async {
      runApp(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Global Net",
          home: SplashScreen(
            userId: globalID,
          ),
          routes: <String, WidgetBuilder>{
            APP_SCREEN: (BuildContext context) => App(prefs, savedThemeMode),
          },
        ),
      );
    },
  );
}

