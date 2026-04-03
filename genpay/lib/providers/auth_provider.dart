import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _phoneNumber = '';
  String? _lastError;
  UserModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get phoneNumber => _phoneNumber;
  String? get lastError => _lastError;
  UserModel? get currentUser => _currentUser;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await LocalStorageService.isLoggedIn();
    final guest = await LocalStorageService.isGuest();
    if (_isLoggedIn && guest) {
      _currentUser = null;
      notifyListeners();
      return;
    }
    if (_isLoggedIn) {
      try {
        final token = await LocalStorageService.getAuthToken();
        if (token != null && token.isNotEmpty) {
          final profile = await ApiService.getProfile(token);
          _currentUser = UserModel.fromBackendJson(profile);
          await LocalStorageService.setWalletBalance(_currentUser?.walletBalance ?? 0);
        }
      } catch (_) {
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _phoneNumber = await AuthService.requestOtp(phone);
      _isLoading = false;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final token = await AuthService.verifyOtp(_phoneNumber, otp);
      await LocalStorageService.setAuthToken(token);
      await LocalStorageService.setLoggedIn(true);
      await LocalStorageService.setPhoneNumber(_phoneNumber);
      await LocalStorageService.setGuest(false);

      final profile = await ApiService.getProfile();
      final userId = (profile['id'] ?? '').toString();
      if (userId.isNotEmpty) {
        await LocalStorageService.setUserId(userId);
      }
      _currentUser = UserModel.fromBackendJson(profile);
      await LocalStorageService.setWalletBalance(_currentUser?.walletBalance ?? 0);

      _isLoggedIn = true;
      _isLoading = false;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAsGuest() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await ApiService.guestLogin();
      final token = (response['access_token'] ?? '').toString();
      final userId = (response['user_id'] ?? '').toString();
      if (token.isEmpty) {
        throw Exception('Missing guest token');
      }

      await LocalStorageService.setAuthToken(token);
      await LocalStorageService.setLoggedIn(true);
      await LocalStorageService.setPhoneNumber('Guest');
      await LocalStorageService.setGuest(true);
      if (userId.isNotEmpty) {
        await LocalStorageService.setUserId(userId);
      }

      try {
        final profile = await ApiService.getProfile();
        _currentUser = UserModel.fromBackendJson(profile);
        await LocalStorageService.setWalletBalance(_currentUser?.walletBalance ?? 0);
      } catch (_) {
        _currentUser = null;
      }

      _isLoggedIn = true;
      _isLoading = false;
      _lastError = null;
      notifyListeners();
      return true;
    } catch (e) {
      // Last-resort local guest session so user can still enter the app.
      await LocalStorageService.setLoggedIn(true);
      await LocalStorageService.setGuest(true);
      await LocalStorageService.setPhoneNumber('Guest');
      await LocalStorageService.setUserId('guest-local');
      _currentUser = null;
      _isLoggedIn = true;
      _isLoading = false;
      _lastError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return true;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _phoneNumber = '';
    await LocalStorageService.clearAll();
    notifyListeners();
  }
}
