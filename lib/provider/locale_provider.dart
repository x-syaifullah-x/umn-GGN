import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simpleworld/l10n/l10n.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale {
    return _locale;
  }

  void setLocale(Locale locale) async {
    if (!L10n.all.contains(locale)) return;

    if(_locale == locale) return;

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("locale", locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
