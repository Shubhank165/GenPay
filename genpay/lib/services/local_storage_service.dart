import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';

  static Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> setPhoneNumber(String phone) async {
    final prefs = await _prefs;
    await prefs.setString(_phoneNumberKey, phone);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs = await _prefs;
    return prefs.getString(_phoneNumberKey);
  }

  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
