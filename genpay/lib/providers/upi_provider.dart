import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class UpiProvider extends ChangeNotifier {
  bool _isProcessing = false;
  String _recipientName = '';
  String _recipientUpiId = '';
  double _amount = 0;
  String _note = '';
  String? _selectedBankId;
  bool _paymentSuccess = false;
  String _transactionRef = '';

  bool get isProcessing => _isProcessing;
  String get recipientName => _recipientName;
  String get recipientUpiId => _recipientUpiId;
  double get amount => _amount;
  String get note => _note;
  String? get selectedBankId => _selectedBankId;
  bool get paymentSuccess => _paymentSuccess;
  String get transactionRef => _transactionRef;

  void setRecipient(String name, String upiId) {
    _recipientName = name;
    _recipientUpiId = upiId;
    notifyListeners();
  }

  void setAmount(double amount) {
    _amount = amount;
    notifyListeners();
  }

  void setNote(String note) {
    _note = note;
    notifyListeners();
  }

  void setSelectedBank(String bankId) {
    _selectedBankId = bankId;
    notifyListeners();
  }

  Future<bool> processPayment(String upiPin) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated');
      }

      final response = await ApiService.createTransaction(
        token,
        type: 'upi_transfer',
        amount: _amount,
        upiPin: upiPin,
        recipientName: _recipientName,
        recipientIdentifier: _recipientUpiId,
        description: _note,
      );

      _paymentSuccess = true;
      _transactionRef = (response['id'] ?? response['reference_id'] ?? '').toString();
      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (_) {
      _paymentSuccess = false;
      _transactionRef = '';
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _recipientName = '';
    _recipientUpiId = '';
    _amount = 0;
    _note = '';
    _selectedBankId = null;
    _paymentSuccess = false;
    _transactionRef = '';
    _isProcessing = false;
    notifyListeners();
  }
}
