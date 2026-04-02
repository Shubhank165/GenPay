class BankAccountModel {
  final String id;
  final String bankName;
  final String accountNumber;
  final double balance;
  final String ifscCode;
  final String upiId;
  final bool isDefault;
  final String bankLogoIcon;
  final int bankColor;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.balance,
    required this.ifscCode,
    required this.upiId,
    this.isDefault = false,
    required this.bankLogoIcon,
    required this.bankColor,
  });

  String get maskedAccountNumber {
    if (accountNumber.length >= 4) {
      return 'XXXX${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }

  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? accountNumber,
    double? balance,
    String? ifscCode,
    String? upiId,
    bool? isDefault,
    String? bankLogoIcon,
    int? bankColor,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
      isDefault: isDefault ?? this.isDefault,
      bankLogoIcon: bankLogoIcon ?? this.bankLogoIcon,
      bankColor: bankColor ?? this.bankColor,
    );
  }
}
