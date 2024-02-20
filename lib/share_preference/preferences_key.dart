import 'package:nb_utils/nb_utils.dart';

class SharedPreferencesKey {
  static const String isSeenWalkthrough = "is_seen_walkthrough";
  static const String userId = "user_id";
  static const String languageCode = "language_code";
}

class HelperFunctions {
  static const String _sharedPreferenceUserNameKey = "USERNAMEKEY";

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_sharedPreferenceUserNameKey);
  }
}
