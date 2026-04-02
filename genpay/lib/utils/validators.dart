class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your mobile number';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length != 10) {
      return 'Please enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6) {
      return 'OTP must be 6 digits';
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    return null;
  }

  static String? upiId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter UPI ID';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]+$').hasMatch(value)) {
      return 'Please enter a valid UPI ID (e.g., name@bank)';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > 100000) {
      return 'Amount cannot exceed ₹1,00,000';
    }
    return null;
  }

  static String? pin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter UPI PIN';
    }
    if (value.length < 4 || value.length > 6) {
      return 'UPI PIN must be 4 or 6 digits';
    }
    return null;
  }

  static String? ifsc(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter IFSC code';
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(value.toUpperCase())) {
      return 'Please enter a valid IFSC code';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter account number';
    }
    if (value.length < 9 || value.length > 18) {
      return 'Account number must be 9-18 digits';
    }
    return null;
  }
}
