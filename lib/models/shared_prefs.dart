import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;
  static const _keyUserId = 'UserId';
  static const _keyLoggedIn = 'Login';
  static const _keyUserName = 'UserName';
  static const _keyProfileUrl = 'ProfileUrl';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setUserId(String userId) async {
    await _prefs.setString(_keyUserId, userId);
  }

  static Future<void> setUserName(String userName) async {
    await _prefs.setString(_keyUserName, userName);
  }

  static Future<void> setLogin(bool login) async {
    await _prefs.setBool(_keyLoggedIn, login);
  }

  static String? getUserId() {
    return _prefs.getString(_keyUserId);
  }

  static String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  static String? getLogin() {
    return _prefs.getString(_keyLoggedIn);
  }

  static Future<void> setProfileUrl(String url) async {
    await _prefs.setString(_keyProfileUrl, url);
  }

  static String? getProfileUrl() {
    return _prefs.getString(_keyProfileUrl);
  }

  static Future<void> deletePrefs() async {
    await _prefs.clear();
  }
}
