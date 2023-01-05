import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/constant/constant.dart';
import 'package:simpleworld/firebase_options.dart';
import 'package:simpleworld/widgets/simple_world_widgets.dart';
import 'package:simpleworld/widgets/splashscreen.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const host = "192.168.0.1";
  FirebaseAuth.instance.useAuthEmulator(host, 9099);
  FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
  FirebaseStorage.instance.useStorageEmulator(host, 9199);

  MobileAds.instance.initialize();
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: ['5DF3DDDAEA78FE6D718E9FF8B6259412']),
  // );

  await initialize();

  SharedPreferences.getInstance().then((prefs) async {
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
  });
}
