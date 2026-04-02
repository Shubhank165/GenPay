import 'package:flutter/material.dart';
import '../models/bank_account.dart';
import '../services/mock_data_service.dart';

class BankProvider extends ChangeNotifier {
  List<BankAccountModel> _accounts = [];
  bool _isLoading = false;

  List<BankAccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  BankAccountModel? get defaultAccount =>
      _accounts.isEmpty ? null : _accounts.firstWhere(
        (a) => a.isDefault,
        orElse: () => _accounts.first,
      );

  double get totalBalance =>
      _accounts.fold(0.0, (sum, a) => sum + a.balance);

  void loadAccounts() {
    _isLoading = true;
    notifyListeners();

    _accounts = MockDataService.getMockBankAccounts();
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> checkBalance(String accountId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  void addAccount(BankAccountModel account) {
    _accounts.add(account);
    notifyListeners();
  }

  void removeAccount(String accountId) {
    _accounts.removeWhere((a) => a.id == accountId);
    notifyListeners();
  }

  void setDefaultAccount(String accountId) {
    _accounts = _accounts.map((a) =>
      a.copyWith(isDefault: a.id == accountId)
    ).toList();
    notifyListeners();
  }
}
