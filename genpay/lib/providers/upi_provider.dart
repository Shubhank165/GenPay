import 'package:flutter/material.dart';
import 'dart:math';

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

  Future<bool> processPayment() async {
    _isProcessing = true;
    notifyListeners();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // 90% success rate simulation
    _paymentSuccess = Random().nextInt(10) < 9;
    _transactionRef = 'TXN${Random().nextInt(999999999).toString().padLeft(12, '0')}';

    _isProcessing = false;
    notifyListeners();
    return _paymentSuccess;
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
