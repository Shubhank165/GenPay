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

  factory TransactionModel.fromBackendJson(Map<String, dynamic> json) {
    final typeRaw = (json['type'] ?? '').toString();
    final statusRaw = (json['status'] ?? '').toString();

    TransactionType type;
    switch (typeRaw) {
      case 'upi_transfer':
        type = TransactionType.sent;
        break;
      case 'recharge':
        type = TransactionType.recharge;
        break;
      case 'bill_payment':
        type = TransactionType.billPayment;
        break;
      case 'wallet_topup':
      case 'wallet_withdraw':
        type = TransactionType.wallet;
        break;
      case 'refund':
        type = TransactionType.refund;
        break;
      default:
        type = TransactionType.sent;
    }

    TransactionStatus status;
    switch (statusRaw) {
      case 'success':
        status = TransactionStatus.success;
        break;
      case 'failed':
        status = TransactionStatus.failed;
        break;
      default:
        status = TransactionStatus.pending;
    }

    TransactionCategory category;
    switch (typeRaw) {
      case 'recharge':
        category = TransactionCategory.mobileRecharge;
        break;
      case 'bill_payment':
        category = TransactionCategory.electricity;
        break;
      case 'flight_booking':
        category = TransactionCategory.flight;
        break;
      case 'bus_booking':
        category = TransactionCategory.bus;
        break;
      case 'hotel_booking':
        category = TransactionCategory.hotel;
        break;
      case 'wallet_topup':
        category = TransactionCategory.walletTopup;
        break;
      case 'wallet_withdraw':
        category = TransactionCategory.walletWithdraw;
        break;
      default:
        category = TransactionCategory.upiTransfer;
    }

    final timestampRaw = json['created_at'] ?? json['timestamp'];

    return TransactionModel(
      id: (json['id'] ?? '').toString(),
      type: type,
      status: status,
      category: category,
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      recipientName: (json['recipient_name'] ?? json['recipientName'] ?? 'Unknown').toString(),
      recipientUpiId: (json['recipient_identifier'] ?? json['recipientUpiId'] ?? '').toString(),
      note: (json['description'] ?? json['note'])?.toString(),
      timestamp: timestampRaw != null ? DateTime.parse(timestampRaw.toString()) : DateTime.now(),
      bankName: null,
      transactionRef: (json['reference_id'] ?? json['transactionRef'])?.toString(),
    );
  }
}
