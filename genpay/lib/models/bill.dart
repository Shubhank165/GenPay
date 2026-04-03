enum BillType { electricity, gas, water, broadband, dth, creditCard, insurance, rent, education, municipalTax, fastag }
enum BillStatus { paid, pending, overdue }

class BillModel {
  final String id;
  final BillType type;
  final String providerName;
  final String consumerNumber;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final String? providerLogoIcon;

  BillModel({
    required this.id,
    required this.type,
    required this.providerName,
    required this.consumerNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.providerLogoIcon,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != BillStatus.paid;

  String get typeLabel {
    switch (type) {
      case BillType.electricity:
        return 'Electricity';
      case BillType.gas:
        return 'Piped Gas';
      case BillType.water:
        return 'Water';
      case BillType.broadband:
        return 'Broadband';
      case BillType.dth:
        return 'DTH';
      case BillType.creditCard:
        return 'Credit Card';
      case BillType.insurance:
        return 'Insurance';
      case BillType.rent:
        return 'Rent';
      case BillType.education:
        return 'Education';
      case BillType.municipalTax:
        return 'Municipal Tax';
      case BillType.fastag:
        return 'FASTag';
    }
  }

  BillModel copyWith({
    String? id,
    BillType? type,
    String? providerName,
    String? consumerNumber,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    String? providerLogoIcon,
  }) {
    return BillModel(
      id: id ?? this.id,
      type: type ?? this.type,
      providerName: providerName ?? this.providerName,
      consumerNumber: consumerNumber ?? this.consumerNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      providerLogoIcon: providerLogoIcon ?? this.providerLogoIcon,
    );
  }

  factory BillModel.fromBackendJson(Map<String, dynamic> json) {
    final category = (json['category'] ?? '').toString();
    final status = json['is_paid'] == true ? BillStatus.paid : BillStatus.pending;

    BillType type;
    switch (category) {
      case 'gas':
        type = BillType.gas;
        break;
      case 'water':
        type = BillType.water;
        break;
      case 'broadband':
        type = BillType.broadband;
        break;
      case 'dth':
        type = BillType.dth;
        break;
      case 'credit_card':
        type = BillType.creditCard;
        break;
      case 'insurance':
        type = BillType.insurance;
        break;
      case 'rent':
        type = BillType.rent;
        break;
      case 'education':
        type = BillType.education;
        break;
      case 'municipal_tax':
        type = BillType.municipalTax;
        break;
      case 'fastag':
        type = BillType.fastag;
        break;
      default:
        type = BillType.electricity;
    }

    final dueRaw = json['due_date'];
    return BillModel(
      id: (json['id'] ?? '').toString(),
      type: type,
      providerName: (json['provider_name'] ?? '').toString(),
      consumerNumber: (json['consumer_number'] ?? '').toString(),
      amount: ((json['amount'] ?? 0) as num).toDouble(),
      dueDate: dueRaw != null ? DateTime.parse(dueRaw.toString()) : DateTime.now(),
      status: status,
    );
  }
}
