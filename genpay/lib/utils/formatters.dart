import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  static String currencyShort(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String currencyCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  static String dateTime(DateTime dt) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  static String date(DateTime dt) {
    return DateFormat('dd MMM yyyy').format(dt);
  }

  static String dateShort(DateTime dt) {
    return DateFormat('dd MMM').format(dt);
  }

  static String time(DateTime dt) {
    return DateFormat('hh:mm a').format(dt);
  }

  static String relativeDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 1) return 'Today';
    if (diff.inDays < 2) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM').format(dt);
  }

  static String maskPhone(String phone) {
    if (phone.length >= 10) {
      return '${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}';
    }
    return phone;
  }

  static String maskAccount(String account) {
    if (account.length >= 4) {
      return 'XXXX ${account.substring(account.length - 4)}';
    }
    return account;
  }

  static String transactionId(String id) {
    if (id.length > 12) {
      return '${id.substring(0, 4)}...${id.substring(id.length - 4)}';
    }
    return id;
  }
}
