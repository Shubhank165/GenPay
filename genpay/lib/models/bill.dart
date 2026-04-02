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
}
