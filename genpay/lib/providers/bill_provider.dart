import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class BillProvider extends ChangeNotifier {
  List<BillModel> _bills = [];
  bool _isLoading = false;
  bool _isFetchingBill = false;
  BillModel? _currentBill;

  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  bool get isFetchingBill => _isFetchingBill;
  BillModel? get currentBill => _currentBill;

  List<BillModel> get pendingBills =>
      _bills.where((b) => b.status == BillStatus.pending).toList();

  List<BillModel> get overdueBills =>
      _bills.where((b) => b.status == BillStatus.overdue || b.isOverdue).toList();

  Future<void> loadBills() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        _bills = [];
      } else {
        final raw = await ApiService.listBills(token, unpaidOnly: false);
        _bills = raw
            .whereType<Map>()
            .map((item) => BillModel.fromBackendJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {
      _bills = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BillModel?> fetchBill(BillType type, String consumerNumber) async {
    _isFetchingBill = true;
    notifyListeners();

    if (_bills.isEmpty) {
      await loadBills();
    }

    final matching = _bills.where((b) => b.type == type && b.consumerNumber == consumerNumber);
    if (matching.isNotEmpty) {
      _currentBill = matching.first;
    } else {
      _currentBill = _bills.where((b) => b.type == type).cast<BillModel?>().firstWhere(
            (b) => b != null,
            orElse: () => null,
          );
    }

    _isFetchingBill = false;
    notifyListeners();
    return _currentBill;
  }

  Future<bool> payBill(String billId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('No auth token');
      }

      await ApiService.payBill(token, billId);

      final index = _bills.indexWhere((b) => b.id == billId);
      if (index != -1) {
        _bills[index] = _bills[index].copyWith(status: BillStatus.paid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }
}
