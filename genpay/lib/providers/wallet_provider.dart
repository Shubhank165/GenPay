import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  double _balance = 2450.75;
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
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void refreshBalance() {
    notifyListeners();
  }
}
