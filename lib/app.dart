import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_net/config/palette.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/pages/WalkThroughScreen.dart';
import 'package:global_net/pages/auth/login_page.dart';
import 'package:global_net/pages/home/home.dart';
import 'package:global_net/provider/locale_provider.dart';
import 'package:global_net/share_preference/preferences_key.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  static const route = '/App';

  const App(this.prefs, this.savedThemeMode, {Key? key}) : super(key: key);

  final SharedPreferences prefs;
  final AdaptiveThemeMode? savedThemeMode;

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> with WidgetsBindingObserver {
  static FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configNotification();
  }

  Future<void> _configNotification() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission(
      sound: true,
      alert: true,
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      badge: true,
    );

    firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          showLocalNotificationIOS(message);
        } else {
          showLocalNotification(message);
        }
      }
    });

    //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
      if (message == null) return;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        showLocalNotificationIOS(message);
      } else {
        showLocalNotification(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) async {
      log('+++ onMessageOpenedApp +++ : $event');
    });

    final NotificationAppLaunchDetails? notificationAppLaunchDetail =
        await notificationsPlugin.getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetail?.didNotificationLaunchApp ?? false) {}

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);
    await notificationsPlugin.initialize(initializationSettings);
    //  notificationsPlugin.periodicallyShow(11111, 'hkb', 'HKKKB', INter, notificationDetails)
  }

  showLocalNotificationIOS(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification!.android;
    AppleNotification? apple = message.notification!.apple;
    if (notification != null) {
      await notificationsPlugin.show(
        notification.hashCode,
        notification.body,
        notification.title,
        NotificationDetails(
            android: android != null
                ? AndroidNotificationDetails('1', 'ContestKnowledge',
                    channelDescription: 'Notification',
                    priority: Priority.values[android.priority.index],
                    color: Colors.blue,
                    subText: notification.title,
                    importance: Importance.high,
                    icon: const AndroidInitializationSettings(
                      '@mipmap/ic_launcher',
                    ).defaultIcon)
                : null,
            iOS: apple != null
                ? DarwinNotificationDetails(
                    subtitle: notification.apple!.subtitle,
                  )
                : null),
        payload: message.data.toString(),
      );
    }
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      await notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            '1',
            'ContestKnowledge',
            channelDescription: 'Notification',
            importance: Importance.high,
            icon: const AndroidInitializationSettings(
              '@mipmap/ic_launcher',
            ).defaultIcon,
          ),
        ),
      );
    }
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    log('++++ MESSAGE RECEIVED IN BACKGROUND  +++');
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences = widget.prefs;
    String? languageCode =
        preferences.getString(SharedPreferencesKey.languageCode);
    return ChangeNotifierProvider(
        create: (context) => LocaleProvider.from(languageCode),
        builder: (context, child) {
          final provider = Provider.of<LocaleProvider>(context);
          return AdaptiveTheme(
            light: ThemeData(
                brightness: Brightness.light,
                primarySwatch: Colors.red,
                primaryColor: Palette.primaryColor,
                primaryColorDark: Colors.white,
                canvasColor: Colors.white,
                disabledColor: Palette.menuBackgroundColor,
                backgroundColor: Palette.backgroundColor,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Palette.appbarbackgroundColor,
                  actionsIconTheme: IconThemeData(
                    color: Palette.appbariconcolor,
                  ),
                  iconTheme: IconThemeData(
                    color: Palette.appbariconcolor,
                    size: 24,
                  ),
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  brightness: Brightness.dark,
                ),
                tabBarTheme: const TabBarTheme(
                  labelColor: Palette.tabbarlabelColor,
                  unselectedLabelColor: Palette.tabbarunselectedLabelColor,
                ),
                iconTheme: const IconThemeData(color: Palette.iconThemeColor),
                scaffoldBackgroundColor: Palette.scaffoldBackgroundColor,
                textTheme: TextTheme(
                  headline4: GoogleFonts.portLligatSans(
                    textStyle: Theme.of(context).textTheme.headline4,
                    fontSize: defaultTargetPlatform == TargetPlatform.android
                        ? 30
                        : 25,
                    fontWeight: FontWeight.w700,
                    color: Palette.apptitlecolor,
                  ),
                ),
                cardColor: Palette.cardColor,
                shadowColor: Palette.shadowColor,
                inputDecorationTheme: const InputDecorationTheme(
                  fillColor: Palette.inputfillcolor,
                ),
                secondaryHeaderColor: Palette.secondaryHeaderColor),
            dark: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.red,
              backgroundColor: Palette.backgroundColordark,
              disabledColor: Palette.scaffoldBackgroundColordark,
              secondaryHeaderColor: Palette.secondaryHeaderColorDark,
              appBarTheme: const AppBarTheme(
                actionsIconTheme: IconThemeData(
                  color: Palette.appbariconcolordark,
                ),
                backgroundColor: Palette.appbarbackgroundColordark,
                iconTheme:
                    IconThemeData(color: Palette.appbariconcolordark, size: 24),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                brightness: Brightness.light,
              ),
              tabBarTheme: const TabBarTheme(
                labelColor: Palette.tabbarlabelColordark,
                unselectedLabelColor: Palette.tabbarunselectedLabelColordark,
              ),
              iconTheme: const IconThemeData(color: Palette.iconThemeColordark),
              scaffoldBackgroundColor: Palette.scaffoldBackgroundColordark,
              textTheme: TextTheme(
                headline4: GoogleFonts.portLligatSans(
                  textStyle: Theme.of(context).textTheme.headline4,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Palette.apptitlecolordark,
                ),
              ),
              cardColor: Palette.cardColordark,
              shadowColor: Palette.shadowColordark,
              inputDecorationTheme: const InputDecorationTheme(
                fillColor: Palette.inputfillcolordark,
              ),
            ),
            initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
            builder: (theme, darkTheme) => MaterialApp(
              title: 'Global  net',
              theme: theme,
              darkTheme: darkTheme,
              debugShowCheckedModeBanner: false,
              home: _getScreen(preferences),
              locale: provider.locale,
              supportedLocales: L10n.alls,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            ),
          );
        });
  }

  Widget _getScreen(SharedPreferences prefs) {
    final bool isSeenWalkthrough =
        prefs.getBool(SharedPreferencesKey.isSeenWalkthrough) ?? false;
    if (!isSeenWalkthrough) {
      prefs.setBool(SharedPreferencesKey.isSeenWalkthrough, true);
      return const WalkThroughScreen();
    }

    final String? userId = prefs.getString(SharedPreferencesKey.userId);
    if (userId != null) {
      return Home(userId: userId);
    }
    return const LoginPage();
  }
}
