import 'package:flutter/material.dart';

class AppColors {
  // Primary Paytm Colors
  static const Color primaryBlue = Color(0xFF00BAF2);
  static const Color darkBlue = Color(0xFF002970);
  static const Color midBlue = Color(0xFF0070BA);
  static const Color lightBlue = Color(0xFFE3F6FD);

  // Action Colors
  static const Color orangeCTA = Color(0xFFFF6B35);
  static const Color orangeLight = Color(0xFFFFF3EE);

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color successGreenLight = Color(0xFFE8F5E9);
  static const Color errorRed = Color(0xFFF44336);
  static const Color errorRedLight = Color(0xFFFFEBEE);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color warningYellowLight = Color(0xFFFFF8E1);
  static const Color pendingOrange = Color(0xFFFF9800);

  // Neutral Colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF002970),
    Color(0xFF00BAF2),
  ];

  static const List<Color> orangeGradient = [
    Color(0xFFFF6B35),
    Color(0xFFFF9800),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  // Category Colors (for service icons)
  static const Color rechargeColor = Color(0xFF2196F3);
  static const Color electricityColor = Color(0xFFFFC107);
  static const Color gasColor = Color(0xFFFF5722);
  static const Color waterColor = Color(0xFF00BCD4);
  static const Color broadbandColor = Color(0xFF9C27B0);
  static const Color dthColor = Color(0xFF3F51B5);
  static const Color fastagColor = Color(0xFF009688);
  static const Color creditCardColor = Color(0xFFE91E63);
  static const Color loanColor = Color(0xFF795548);
  static const Color insuranceColor = Color(0xFF607D8B);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color stocksColor = Color(0xFF4CAF50);
}

class AppStrings {
  static const String appName = 'GenPay';
  static const String tagline = 'India\'s Most-loved Payments App';

  // Auth
  static const String loginTitle = 'Welcome to GenPay';
  static const String loginSubtitle = 'Enter your mobile number to get started';
  static const String enterPhone = 'Enter Mobile Number';
  static const String enterOTP = 'Enter OTP';
  static const String otpSent = 'We\'ve sent an OTP to';
  static const String resendOTP = 'Resend OTP';
  static const String continueBtn = 'Continue';
  static const String verifyBtn = 'Verify & Proceed';

  // Home
  static const String scanPay = 'Scan & Pay';
  static const String sendMoney = 'Send Money';
  static const String receiveMoney = 'Receive Money';
  static const String bankBalance = 'Bank Balance';
  static const String walletBalance = 'Wallet Balance';
  static const String recentTransfers = 'Recent Transfers';
  static const String allServices = 'All Services';
  static const String offersForYou = 'Offers For You';
  static const String travelBookings = 'Travel Bookings';

  // Services
  static const String mobileRecharge = 'Mobile\nRecharge';
  static const String dthRecharge = 'DTH\nRecharge';
  static const String electricity = 'Electricity';
  static const String gas = 'Piped Gas';
  static const String water = 'Water';
  static const String broadband = 'Broadband';
  static const String fastag = 'FASTag';
  static const String creditCard = 'Credit Card\nBill';
  static const String loans = 'Loans';
  static const String insurance = 'Insurance';
  static const String gold = 'Gold';
  static const String stocks = 'Stocks &\nMutual Funds';

  // Travel
  static const String flights = 'Flights';
  static const String trains = 'Trains';
  static const String buses = 'Buses';
  static const String hotels = 'Hotels';

  // Payment
  static const String enterAmount = 'Enter Amount';
  static const String enterUpiId = 'Enter UPI ID';
  static const String paymentSuccess = 'Payment Successful!';
  static const String paymentFailed = 'Payment Failed';
  static const String tryAgain = 'Try Again';

  // Bottom Nav
  static const String home = 'Home';
  static const String scanAndPay = 'Scan & Pay';
  static const String offers = 'Offers';
  static const String passbook = 'Passbook';
  static const String profile = 'Profile';
}

class AppDimensions {
  static const double paddingXS = 4;
  static const double paddingSM = 8;
  static const double paddingMD = 12;
  static const double paddingLG = 16;
  static const double paddingXL = 20;
  static const double paddingXXL = 24;
  static const double paddingHuge = 32;

  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusRound = 100;

  static const double iconSM = 20;
  static const double iconMD = 24;
  static const double iconLG = 32;
  static const double iconXL = 40;
  static const double iconXXL = 48;

  static const double avatarSM = 36;
  static const double avatarMD = 48;
  static const double avatarLG = 64;
  static const double avatarXL = 80;

  static const double bottomNavHeight = 65;
  static const double appBarHeight = 56;
}
