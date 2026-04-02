enum TransactionType { sent, received, recharge, billPayment, wallet, refund }
enum TransactionStatus { success, failed, pending }
enum TransactionCategory {
  upiTransfer,
  mobileRecharge,
  dthRecharge,
  electricity,
  gas,
  water,
  broadband,
  creditCard,
  walletTopup,
  walletWithdraw,
  flight,
  bus,
  train,
  hotel,
  gold,
  insurance,
  loan,
  other,
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final TransactionStatus status;
  final TransactionCategory category;
  final double amount;
  final String recipientName;
  final String recipientUpiId;
  final String? note;
  final DateTime timestamp;
  final String? bankName;
  final String? transactionRef;

  TransactionModel({
    required this.id,
    required this.type,
    required this.status,
    required this.category,
    required this.amount,
    required this.recipientName,
    required this.recipientUpiId,
    this.note,
    required this.timestamp,
    this.bankName,
    this.transactionRef,
  });

  bool get isCredit => type == TransactionType.received || type == TransactionType.refund;
  bool get isDebit => !isCredit;

  String get formattedAmount {
    final prefix = isCredit ? '+ ' : '- ';
    return '$prefix₹${amount.toStringAsFixed(2)}';
  }

  String get statusText {
    switch (status) {
      case TransactionStatus.success:
        return 'Success';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.pending:
        return 'Pending';
    }
  }

  String get categoryLabel {
    switch (category) {
      case TransactionCategory.upiTransfer:
        return 'UPI Transfer';
      case TransactionCategory.mobileRecharge:
        return 'Mobile Recharge';
      case TransactionCategory.dthRecharge:
        return 'DTH Recharge';
      case TransactionCategory.electricity:
        return 'Electricity Bill';
      case TransactionCategory.gas:
        return 'Gas Bill';
      case TransactionCategory.water:
        return 'Water Bill';
      case TransactionCategory.broadband:
        return 'Broadband Bill';
      case TransactionCategory.creditCard:
        return 'Credit Card Payment';
      case TransactionCategory.walletTopup:
        return 'Wallet Top Up';
      case TransactionCategory.walletWithdraw:
        return 'Wallet Withdrawal';
      case TransactionCategory.flight:
        return 'Flight Booking';
      case TransactionCategory.bus:
        return 'Bus Booking';
      case TransactionCategory.train:
        return 'Train Booking';
      case TransactionCategory.hotel:
        return 'Hotel Booking';
      case TransactionCategory.gold:
        return 'Gold Purchase';
      case TransactionCategory.insurance:
        return 'Insurance Payment';
      case TransactionCategory.loan:
        return 'Loan EMI';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'category': category.name,
      'amount': amount,
      'recipientName': recipientName,
      'recipientUpiId': recipientUpiId,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'bankName': bankName,
      'transactionRef': transactionRef,
    };
  }
}
