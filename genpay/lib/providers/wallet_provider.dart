import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 0.0;
  bool _isLoading = false;
  bool _isBalanceVisible = true;

  double get balance => _balance;
  bool get isLoading => _isLoading;
  bool get isBalanceVisible => _isBalanceVisible;

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  Future<bool> addMoney(double amount) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));
    _balance += amount;
    await LocalStorageService.setWalletBalance(_balance);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> deductMoney(double amount) async {
    if (amount > _balance) return false;

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));
    _balance -= amount;
    await LocalStorageService.setWalletBalance(_balance);
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void refreshBalance() {
    notifyListeners();
  }

  Future<void> loadBalanceFromBackend() async {
    final cachedBalance = await LocalStorageService.getWalletBalance();
    if (cachedBalance != null) {
      _balance = cachedBalance;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token != null && token.isNotEmpty) {
        final profile = await ApiService.getProfile(token);
        _balance = ((profile['wallet_balance'] ?? 0) as num).toDouble();
        await LocalStorageService.setWalletBalance(_balance);
      }
    } catch (_) {
      // Keep cached balance if API fails.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
