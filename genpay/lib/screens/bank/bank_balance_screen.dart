import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/bank_provider.dart';
import '../../utils/formatters.dart';

class BankBalanceScreen extends StatelessWidget {
  const BankBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final banks = context.watch<BankProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bank Balance'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () => Navigator.pushNamed(context, AppRoutes.linkBank))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppColors.primaryGradient), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text('Total Balance', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 8),
              Text(Formatters.currency(banks.totalBalance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${banks.accounts.length} linked accounts', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          ...banks.accounts.map((account) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
            child: Row(children: [
              Container(width: 48, height: 48,
                decoration: BoxDecoration(color: Color(account.bankColor).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance, color: Color(account.bankColor), size: 24)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(account.bankName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(account.maskedAccountNumber, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                if (account.isDefault) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(4)),
                  child: const Text('Default', style: TextStyle(fontSize: 10, color: AppColors.primaryBlue, fontWeight: FontWeight.w600))),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(Formatters.currency(account.balance), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                const Text('Available', style: TextStyle(fontSize: 11, color: AppColors.successGreen)),
              ]),
            ]),
          )),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, height: 50,
            child: OutlinedButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.linkBank),
              icon: const Icon(Icons.add), label: const Text('Link New Bank Account'),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
        ]),
      ),
    );
  }
}
