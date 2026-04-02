import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/transaction.dart';
import '../models/contact.dart';
import '../models/bank_account.dart';
import '../models/bill.dart';
import '../models/offer.dart';
import 'dart:math';

class MockDataService {
  static final _random = Random(42);

  static UserModel getMockUser() {
    return UserModel(
      id: 'USR001',
      name: 'Rahul Sharma',
      phone: '9876543210',
      email: 'rahul.sharma@email.com',
      upiId: 'rahul@genpay',
      isKycVerified: true,
      walletBalance: 2450.75,
      createdAt: DateTime(2024, 3, 15),
    );
  }

  static List<ContactModel> getMockContacts() {
    final colors = [
      Colors.blue, Colors.purple, Colors.teal, Colors.orange, Colors.pink,
      Colors.indigo, Colors.green, Colors.red, Colors.cyan, Colors.amber,
      Colors.deepPurple, Colors.lightBlue, Colors.lime, Colors.deepOrange,
      Colors.brown, Colors.blueGrey, Colors.lightGreen, Colors.yellow,
      Colors.grey, Colors.redAccent,
    ];

    final names = [
      'Priya Patel', 'Amit Kumar', 'Sneha Gupta', 'Vikram Singh', 'Anita Reddy',
      'Raj Malhotra', 'Kavita Nair', 'Suresh Iyer', 'Deepa Joshi', 'Arjun Menon',
      'Pooja Verma', 'Kiran Rao', 'Manish Tiwari', 'Divya Kapoor', 'Rohit Agarwal',
      'Neha Saxena', 'Sanjay Mishra', 'Meera Pillai', 'Arun Bhatia', 'Ritu Chopra',
    ];

    final phones = [
      '9812345678', '9823456789', '9834567890', '9845678901', '9856789012',
      '9867890123', '9878901234', '9889012345', '9890123456', '9801234567',
      '9912345678', '9923456789', '9934567890', '9945678901', '9956789012',
      '9967890123', '9978901234', '9989012345', '9990123456', '9901234567',
    ];

    return List.generate(20, (i) => ContactModel(
      id: 'CON${i.toString().padLeft(3, '0')}',
      name: names[i],
      phone: phones[i],
      upiId: '${names[i].split(' ')[0].toLowerCase()}@genpay',
      avatarColor: colors[i],
      isFavorite: i < 5,
      lastTransactionDate: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      lastAmount: (100 + _random.nextInt(9900)).toDouble(),
    ));
  }

  static List<BankAccountModel> getMockBankAccounts() {
    return [
      BankAccountModel(
        id: 'BNK001',
        bankName: 'State Bank of India',
        accountNumber: '30925678431',
        balance: 45230.50,
        ifscCode: 'SBIN0001234',
        upiId: 'rahul@sbi',
        isDefault: true,
        bankLogoIcon: 'account_balance',
        bankColor: 0xFF1565C0,
      ),
      BankAccountModel(
        id: 'BNK002',
        bankName: 'HDFC Bank',
        accountNumber: '50100234567',
        balance: 128750.00,
        ifscCode: 'HDFC0001234',
        upiId: 'rahul@hdfcbank',
        isDefault: false,
        bankLogoIcon: 'account_balance',
        bankColor: 0xFF004C8F,
      ),
      BankAccountModel(
        id: 'BNK003',
        bankName: 'ICICI Bank',
        accountNumber: '012345678901',
        balance: 67890.25,
        ifscCode: 'ICIC0001234',
        upiId: 'rahul@icici',
        isDefault: false,
        bankLogoIcon: 'account_balance',
        bankColor: 0xFFB85C1F,
      ),
    ];
  }

  static List<TransactionModel> getMockTransactions() {
    final contacts = getMockContacts();
    final transactions = <TransactionModel>[];
    final categories = TransactionCategory.values;

    for (int i = 0; i < 50; i++) {
      final contact = contacts[_random.nextInt(contacts.length)];
      final isCredit = _random.nextBool();
      final category = categories[_random.nextInt(categories.length)];
      TransactionType type;
      if (category == TransactionCategory.upiTransfer) {
        type = isCredit ? TransactionType.sent : TransactionType.received;
      } else if (category == TransactionCategory.mobileRecharge || category == TransactionCategory.dthRecharge) {
        type = TransactionType.recharge;
      } else if (category == TransactionCategory.walletTopup || category == TransactionCategory.walletWithdraw) {
        type = TransactionType.wallet;
      } else if (category.name.contains('bill') || category == TransactionCategory.electricity ||
                 category == TransactionCategory.gas || category == TransactionCategory.water ||
                 category == TransactionCategory.broadband || category == TransactionCategory.creditCard) {
        type = TransactionType.billPayment;
      } else {
        type = isCredit ? TransactionType.received : TransactionType.sent;
      }

      final statuses = TransactionStatus.values;
      final status = _random.nextInt(10) < 8 ? TransactionStatus.success :
                     (_random.nextInt(10) < 5 ? TransactionStatus.pending : TransactionStatus.failed);

      transactions.add(TransactionModel(
        id: 'TXN${i.toString().padLeft(5, '0')}',
        type: type,
        status: status,
        category: category,
        amount: (50 + _random.nextInt(9950)).toDouble(),
        recipientName: contact.name,
        recipientUpiId: contact.upiId ?? '${contact.name.split(' ')[0].toLowerCase()}@upi',
        note: _random.nextBool() ? 'Payment for services' : null,
        timestamp: DateTime.now().subtract(Duration(
          days: _random.nextInt(60),
          hours: _random.nextInt(24),
          minutes: _random.nextInt(60),
        )),
        bankName: 'State Bank of India',
        transactionRef: 'REF${_random.nextInt(999999999).toString().padLeft(9, '0')}',
      ));
    }

    transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return transactions;
  }

  static List<BillModel> getMockBills() {
    return [
      BillModel(
        id: 'BILL001',
        type: BillType.electricity,
        providerName: 'BSES Rajdhani',
        consumerNumber: 'BR1234567890',
        amount: 2340.00,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: BillStatus.pending,
      ),
      BillModel(
        id: 'BILL002',
        type: BillType.gas,
        providerName: 'Indraprastha Gas Ltd',
        consumerNumber: 'IGL987654321',
        amount: 890.50,
        dueDate: DateTime.now().add(const Duration(days: 12)),
        status: BillStatus.pending,
      ),
      BillModel(
        id: 'BILL003',
        type: BillType.broadband,
        providerName: 'Jio Fiber',
        consumerNumber: 'JF111222333',
        amount: 999.00,
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        status: BillStatus.overdue,
      ),
      BillModel(
        id: 'BILL004',
        type: BillType.water,
        providerName: 'Delhi Jal Board',
        consumerNumber: 'DJB456789012',
        amount: 450.00,
        dueDate: DateTime.now().add(const Duration(days: 20)),
        status: BillStatus.pending,
      ),
      BillModel(
        id: 'BILL005',
        type: BillType.creditCard,
        providerName: 'HDFC Credit Card',
        consumerNumber: 'XXXX-XXXX-XXXX-4532',
        amount: 12500.00,
        dueDate: DateTime.now().add(const Duration(days: 8)),
        status: BillStatus.pending,
      ),
    ];
  }

  static List<OfferModel> getMockOffers() {
    return [
      OfferModel(
        id: 'OFF001',
        title: 'Flat ₹50 Cashback',
        description: 'On mobile recharge of ₹199 or more',
        discountText: '₹50 OFF',
        couponCode: 'RECHARGE50',
        validTill: DateTime.now().add(const Duration(days: 15)),
        category: 'Recharge',
        gradientColors: [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
        icon: Icons.phone_android,
      ),
      OfferModel(
        id: 'OFF002',
        title: '20% Cashback',
        description: 'On electricity bill payment up to ₹100',
        discountText: '20% OFF',
        couponCode: 'ELEC20',
        validTill: DateTime.now().add(const Duration(days: 10)),
        category: 'Bills',
        gradientColors: [const Color(0xFFFFC107), const Color(0xFFFF9800)],
        icon: Icons.bolt,
      ),
      OfferModel(
        id: 'OFF003',
        title: 'Flat ₹200 Off',
        description: 'On flight bookings above ₹3,000',
        discountText: '₹200 OFF',
        couponCode: 'FLY200',
        validTill: DateTime.now().add(const Duration(days: 30)),
        category: 'Travel',
        gradientColors: [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
        icon: Icons.flight,
      ),
      OfferModel(
        id: 'OFF004',
        title: 'Win Gold Coins',
        description: 'Send money via UPI and win up to ₹500 in gold',
        discountText: 'WIN GOLD',
        validTill: DateTime.now().add(const Duration(days: 7)),
        category: 'UPI',
        gradientColors: [const Color(0xFFFF6B35), const Color(0xFFFF9800)],
        icon: Icons.monetization_on,
      ),
      OfferModel(
        id: 'OFF005',
        title: 'Free Insurance',
        description: 'Get ₹2 Lakh accident insurance on ₹1 premium',
        discountText: 'FREE',
        validTill: DateTime.now().add(const Duration(days: 45)),
        category: 'Insurance',
        gradientColors: [const Color(0xFF4CAF50), const Color(0xFF81C784)],
        icon: Icons.shield,
      ),
    ];
  }

  static Map<String, List<Map<String, dynamic>>> getMobileRechargePlans() {
    return {
      'Popular': [
        {'price': 199, 'validity': '24 days', 'data': '1.5 GB/day', 'desc': 'Unlimited Calls + 100 SMS/day'},
        {'price': 299, 'validity': '28 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + 100 SMS/day'},
        {'price': 449, 'validity': '56 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + 100 SMS/day'},
        {'price': 599, 'validity': '84 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + 100 SMS/day'},
      ],
      'Data': [
        {'price': 19, 'validity': '1 day', 'data': '1 GB', 'desc': 'Data Add-on'},
        {'price': 49, 'validity': '3 days', 'data': '6 GB', 'desc': 'Data Add-on'},
        {'price': 98, 'validity': '12 days', 'data': '12 GB', 'desc': 'Data Add-on'},
        {'price': 149, 'validity': '24 days', 'data': '24 GB', 'desc': 'Data Add-on'},
      ],
      'Unlimited': [
        {'price': 239, 'validity': '24 days', 'data': '1.5 GB/day', 'desc': 'Unlimited Calls + Disney+ Hotstar'},
        {'price': 359, 'validity': '28 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + Disney+ Hotstar'},
        {'price': 549, 'validity': '56 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + Disney+ Hotstar'},
        {'price': 799, 'validity': '84 days', 'data': '2 GB/day', 'desc': 'Unlimited Calls + Netflix + Disney+'},
      ],
      'Talktime': [
        {'price': 10, 'validity': 'NA', 'data': 'NA', 'desc': '₹7.47 Talktime'},
        {'price': 20, 'validity': 'NA', 'data': 'NA', 'desc': '₹14.95 Talktime'},
        {'price': 50, 'validity': 'NA', 'data': 'NA', 'desc': '₹39.37 Talktime'},
        {'price': 100, 'validity': 'NA', 'data': 'NA', 'desc': '₹81.75 Talktime'},
      ],
    };
  }

  static List<Map<String, dynamic>> getMockFlights() {
    return [
      {'airline': 'IndiGo', 'code': '6E-2145', 'departure': '06:15', 'arrival': '08:45', 'duration': '2h 30m', 'price': 4299, 'stops': 'Non-stop'},
      {'airline': 'Air India', 'code': 'AI-801', 'departure': '08:30', 'arrival': '11:15', 'duration': '2h 45m', 'price': 5150, 'stops': 'Non-stop'},
      {'airline': 'SpiceJet', 'code': 'SG-437', 'departure': '10:00', 'arrival': '14:30', 'duration': '4h 30m', 'price': 3599, 'stops': '1 Stop'},
      {'airline': 'Vistara', 'code': 'UK-929', 'departure': '12:45', 'arrival': '15:10', 'duration': '2h 25m', 'price': 6200, 'stops': 'Non-stop'},
      {'airline': 'Go First', 'code': 'G8-512', 'departure': '16:20', 'arrival': '20:50', 'duration': '4h 30m', 'price': 3199, 'stops': '1 Stop'},
      {'airline': 'IndiGo', 'code': '6E-5587', 'departure': '19:00', 'arrival': '21:30', 'duration': '2h 30m', 'price': 4750, 'stops': 'Non-stop'},
    ];
  }

  static List<Map<String, dynamic>> getMockBuses() {
    return [
      {'operator': 'VRL Travels', 'type': 'Volvo Multi-Axle A/C Sleeper', 'departure': '20:00', 'arrival': '06:30', 'duration': '10h 30m', 'price': 1200, 'seats': 23, 'rating': 4.3},
      {'operator': 'SRS Travels', 'type': 'Scania A/C Multi-Axle Semi Sleeper', 'departure': '21:00', 'arrival': '07:00', 'duration': '10h 00m', 'price': 999, 'seats': 12, 'rating': 4.1},
      {'operator': 'Orange Tours', 'type': 'Volvo A/C Sleeper', 'departure': '22:00', 'arrival': '08:30', 'duration': '10h 30m', 'price': 1100, 'seats': 8, 'rating': 4.5},
      {'operator': 'KSRTC', 'type': 'Airavat Club Class', 'departure': '22:30', 'arrival': '09:00', 'duration': '10h 30m', 'price': 850, 'seats': 30, 'rating': 4.0},
      {'operator': 'Neeta Travels', 'type': 'Volvo A/C Semi Sleeper', 'departure': '23:00', 'arrival': '09:30', 'duration': '10h 30m', 'price': 750, 'seats': 15, 'rating': 3.8},
    ];
  }
}
