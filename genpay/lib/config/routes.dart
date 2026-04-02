import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/scan/scan_pay_screen.dart';
import '../screens/scan/qr_result_screen.dart';
import '../screens/send_money/send_money_screen.dart';
import '../screens/send_money/enter_amount_screen.dart';
import '../screens/send_money/payment_status_screen.dart';
import '../screens/receive_money/receive_money_screen.dart';
import '../screens/wallet/wallet_screen.dart';
import '../screens/wallet/add_money_screen.dart';
import '../screens/passbook/passbook_screen.dart';
import '../screens/recharge/mobile_recharge_screen.dart';
import '../screens/recharge/dth_recharge_screen.dart';
import '../screens/bill_payments/bill_categories_screen.dart';
import '../screens/bill_payments/pay_bill_screen.dart';
import '../screens/bank/bank_balance_screen.dart';
import '../screens/bank/link_bank_screen.dart';
import '../screens/travel/travel_home_screen.dart';
import '../screens/travel/flight_booking_screen.dart';
import '../screens/travel/bus_booking_screen.dart';
import '../screens/financial_services/services_home_screen.dart';
import '../screens/financial_services/gold_screen.dart';
import '../screens/offers/offers_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/kyc_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String home = '/home';
  static const String scanPay = '/scan-pay';
  static const String qrResult = '/qr-result';
  static const String sendMoney = '/send-money';
  static const String enterAmount = '/enter-amount';
  static const String paymentStatus = '/payment-status';
  static const String receiveMoney = '/receive-money';
  static const String wallet = '/wallet';
  static const String addMoney = '/add-money';
  static const String passbook = '/passbook';
  static const String mobileRecharge = '/mobile-recharge';
  static const String dthRecharge = '/dth-recharge';
  static const String billCategories = '/bill-categories';
  static const String payBill = '/pay-bill';
  static const String bankBalance = '/bank-balance';
  static const String linkBank = '/link-bank';
  static const String travelHome = '/travel';
  static const String flightBooking = '/flight-booking';
  static const String busBooking = '/bus-booking';
  static const String financialServices = '/financial-services';
  static const String gold = '/gold';
  static const String offers = '/offers';
  static const String profile = '/profile';
  static const String kyc = '/kyc';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const LoginScreen(),
        otp: (context) => const OtpScreen(),
        home: (context) => const HomeScreen(),
        scanPay: (context) => const ScanPayScreen(),
        qrResult: (context) => const QrResultScreen(),
        sendMoney: (context) => const SendMoneyScreen(),
        enterAmount: (context) => const EnterAmountScreen(),
        paymentStatus: (context) => const PaymentStatusScreen(),
        receiveMoney: (context) => const ReceiveMoneyScreen(),
        wallet: (context) => const WalletScreen(),
        addMoney: (context) => const AddMoneyScreen(),
        passbook: (context) => const PassbookScreen(),
        mobileRecharge: (context) => const MobileRechargeScreen(),
        dthRecharge: (context) => const DthRechargeScreen(),
        billCategories: (context) => const BillCategoriesScreen(),
        payBill: (context) => const PayBillScreen(),
        bankBalance: (context) => const BankBalanceScreen(),
        linkBank: (context) => const LinkBankScreen(),
        travelHome: (context) => const TravelHomeScreen(),
        flightBooking: (context) => const FlightBookingScreen(),
        busBooking: (context) => const BusBookingScreen(),
        financialServices: (context) => const ServicesHomeScreen(),
        gold: (context) => const GoldScreen(),
        offers: (context) => const OffersScreen(),
        profile: (context) => const ProfileScreen(),
        kyc: (context) => const KycScreen(),
        settings: (context) => const SettingsScreen(),
        notifications: (context) => const NotificationsScreen(),
      };
}
