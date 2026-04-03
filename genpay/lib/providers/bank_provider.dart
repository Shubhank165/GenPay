import 'package:flutter/material.dart';
import '../models/bank_account.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

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

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        _accounts = [];
      } else {
        final raw = await ApiService.listBankAccounts(token);
        _accounts = raw
            .whereType<Map>()
            .map((item) => BankAccountModel.fromBackendJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      _accounts = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkBalance(String accountId) async {
    await loadAccounts();
    return _accounts.any((a) => a.id == accountId);
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
