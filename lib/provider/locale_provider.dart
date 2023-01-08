import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:global_net/l10n/l10n.dart';
import 'package:global_net/share_preference/preferences_key.dart';

class LocaleProvider extends ChangeNotifier {
  late Locale? _locale;

  LocaleProvider();

  LocaleProvider.from(String? languageCode) {
    _locale = Locale(languageCode ?? L10n.languageCodeEnglish);
  }

  Locale? get locale {
    return _locale;
  }

  void setLocale(Locale locale) async {
    if (!L10n.alls.contains(locale)) return;

    if (_locale == locale) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString(
        SharedPreferencesKey.languageCode, locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
