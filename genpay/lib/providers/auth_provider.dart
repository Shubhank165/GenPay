import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _phoneNumber = '';
  String _otp = '';
  UserModel? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get phoneNumber => _phoneNumber;
  UserModel? get currentUser => _currentUser;

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await LocalStorageService.isLoggedIn();
    if (_isLoggedIn) {
      _currentUser = MockDataService.getMockUser();
    }
    notifyListeners();
  }

  void setPhoneNumber(String phone) {
    _phoneNumber = phone;
    notifyListeners();
  }

  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    _phoneNumber = phone;
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    _isLoading = true;
    notifyListeners();

    // Simulate verification (accept any 6-digit OTP)
    await Future.delayed(const Duration(milliseconds: 1500));
    _otp = otp;

    if (otp.length == 6) {
      _isLoggedIn = true;
      _currentUser = MockDataService.getMockUser();
      await LocalStorageService.setLoggedIn(true);
      await LocalStorageService.setPhoneNumber(_phoneNumber);
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    _phoneNumber = '';
    _otp = '';
    await LocalStorageService.clearAll();
    notifyListeners();
  }
}
