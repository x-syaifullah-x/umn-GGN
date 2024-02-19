import 'package:nb_utils/nb_utils.dart';

class SharedPreferencesKey {
  static const String isSeenWalkthrough = "is_seen_walkthrough";
  static const String userId = "user_id";
  static const String userType = "USERR_TYPE";
  static const String languageCode = "language_code";
}

class HelperFunctions {
  static const String _sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static const String _sharedPreferenceUserNameKey = "USERNAMEKEY";
  static const String _sharedPreferenceUserEmailKey = "USEREMAILKEY";

  // saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(
    bool isUserLoggedIn,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(
      _sharedPreferenceUserLoggedInKey,
      isUserLoggedIn,
    );
  }

  static Future<bool> saveUserNameSharedPreference(String userName) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(_sharedPreferenceUserNameKey, userName);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(
        _sharedPreferenceUserEmailKey, userEmail);
  }

  // fetching data from sharedpreference
  static Future<bool?> getUserLoggedInSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_sharedPreferenceUserLoggedInKey);
  }

  static Future<String?> getUserNameSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_sharedPreferenceUserNameKey);
  }

  static Future<String?> getUserEmailSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(_sharedPreferenceUserEmailKey);
  }
}
