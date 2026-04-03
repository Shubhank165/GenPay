import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class LocalStorageService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userNameKey = 'user_name';
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _isGuestKey = 'is_guest';
  static const String _walletBalanceKey = 'wallet_balance';

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

  static Future<void> setAuthToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(_authTokenKey, token);
    await AuthService.setToken(token);
  }

  static Future<String?> getAuthToken() async {
    final secureToken = await AuthService.getToken();
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }
    final prefs = await _prefs;
    return prefs.getString(_authTokenKey);
  }

  static Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(_userIdKey, userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  static Future<void> setGuest(bool isGuest) async {
    final prefs = await _prefs;
    await prefs.setBool(_isGuestKey, isGuest);
  }

  static Future<bool> isGuest() async {
    final prefs = await _prefs;
    return prefs.getBool(_isGuestKey) ?? false;
  }

  static Future<void> setWalletBalance(double balance) async {
    final prefs = await _prefs;
    await prefs.setDouble(_walletBalanceKey, balance);
  }

  static Future<double?> getWalletBalance() async {
    final prefs = await _prefs;
    return prefs.getDouble(_walletBalanceKey);
  }

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
    await AuthService.clearToken();
  }
}
