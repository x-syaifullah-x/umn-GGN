import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_net/l10n/language_model.dart';

class L10n {
  static final List<Locale> alls =
      _languageModels.map((e) => Locale(e.code)).toList();

  static final List<LanguageModel> _languageModels = [
    LanguageModel(languageFlagArabic, 'Arabic', languageCodeArabic),
    LanguageModel(languageFlagChinese, 'Chinese', languageCodeChinese),
    LanguageModel(languageFlagEnglish, 'English', languageCodeEnglish),
    LanguageModel(languageFlagHindhi, 'Hindhi', languageCodeHindhi),
    LanguageModel(languageFlagSpanish, 'Spanish', languageCodeSpanish),
  ];

  static const String languageFlagArabic = '🇸🇦';
  static const String languageFlagChinese = '🇨🇳';
  static const String languageFlagEnglish = '🇺🇸';
  static const String languageFlagHindhi = '🇮🇳';
  static const String languageFlagSpanish = '🇪🇸';

  static const String languageNameArabic = 'Arabic';
  static const String languageNameChinese = 'Chinese';
  static const String languageNameEnglish = 'English';
  static const String languageNameHindhi = 'Hindhi';
  static const String languageNameSpanish = 'Spanish';

  static const String languageCodeArabic = 'ar';
  static const String languageCodeChinese = 'zh';
  static const String languageCodeEnglish = 'en';
  static const String languageCodeHindhi = 'hi';
  static const String languageCodeSpanish = 'es';

  static const defaultLanguageCode =
      (kIsWeb ? languageCodeChinese : languageCodeEnglish);

  static String getFlag(String languageCode) {
    String flage = languageFlagEnglish;
    for (var element in _languageModels) {
      if (element.code == languageCode) {
        flage = element.flag;
      }
    }
    return flage;
  }

  static String getFlagnName(String languageCode) {
    String flageName = '$languageFlagEnglish $languageNameEnglish';
    for (var element in _languageModels) {
      if (element.code == languageCode) {
        flageName = '${element.flag} ${element.name}';
      }
    }
    return flageName;
  }
}
