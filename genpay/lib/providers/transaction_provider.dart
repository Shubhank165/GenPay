import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TransactionType? _filterType;

  List<TransactionModel> get transactions => _filteredTransactions.isEmpty && _searchQuery.isEmpty && _filterType == null
      ? _transactions
      : _filteredTransactions;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        _transactions = [];
      } else {
        final raw = await ApiService.listTransactions(token);
        _transactions = raw
            .whereType<Map>()
            .map((item) => TransactionModel.fromBackendJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      _applyFilters();
    } catch (_) {
      _transactions = [];
      _filteredTransactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.insert(0, transaction);
    _applyFilters();
    notifyListeners();
  }

  void filterByType(TransactionType? type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTransactions = List.from(_transactions);

    if (_filterType != null) {
      _filteredTransactions = _filteredTransactions
          .where((t) => t.type == _filterType)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      _filteredTransactions = _filteredTransactions.where((t) =>
          t.recipientName.toLowerCase().contains(q) ||
          t.recipientUpiId.toLowerCase().contains(q) ||
          t.amount.toString().contains(q) ||
          t.categoryLabel.toLowerCase().contains(q)
      ).toList();
    }
  }

  void clearFilters() {
    _filterType = null;
    _searchQuery = '';
    _filteredTransactions = List.from(_transactions);
    notifyListeners();
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    return _transactions.take(limit).toList();
  }

  double get totalSent => _transactions
      .where((t) => t.type == TransactionType.sent && t.status == TransactionStatus.success)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalReceived => _transactions
      .where((t) => t.type == TransactionType.received && t.status == TransactionStatus.success)
      .fold(0.0, (sum, t) => sum + t.amount);

  Map<TransactionCategory, double> get spendByCategory {
    final map = <TransactionCategory, double>{};
    for (final t in _transactions.where((t) => t.isDebit && t.status == TransactionStatus.success)) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }
}
