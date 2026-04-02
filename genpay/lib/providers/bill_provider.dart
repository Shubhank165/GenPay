import 'package:flutter/material.dart';
import '../models/bill.dart';
import '../services/mock_data_service.dart';

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

  void loadBills() {
    _isLoading = true;
    notifyListeners();

    _bills = MockDataService.getMockBills();
    _isLoading = false;
    notifyListeners();
  }

  Future<BillModel?> fetchBill(BillType type, String consumerNumber) async {
    _isFetchingBill = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    // Find matching biller or create a mock one
    final matching = _bills.where((b) =>
        b.type == type && b.consumerNumber == consumerNumber);

    if (matching.isNotEmpty) {
      _currentBill = matching.first;
    } else {
      _currentBill = BillModel(
        id: 'BILL_NEW',
        type: type,
        providerName: 'Provider',
        consumerNumber: consumerNumber,
        amount: 1250.00,
        dueDate: DateTime.now().add(const Duration(days: 15)),
        status: BillStatus.pending,
      );
    }

    _isFetchingBill = false;
    notifyListeners();
    return _currentBill;
  }

  Future<bool> payBill(String billId) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      _bills[index] = BillModel(
        id: _bills[index].id,
        type: _bills[index].type,
        providerName: _bills[index].providerName,
        consumerNumber: _bills[index].consumerNumber,
        amount: _bills[index].amount,
        dueDate: _bills[index].dueDate,
        status: BillStatus.paid,
      );
    }

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void clearCurrentBill() {
    _currentBill = null;
    notifyListeners();
  }
}
