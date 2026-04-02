import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_tile.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final txns = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Wallet'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(children: [
              Text('Wallet Balance', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              const SizedBox(height: 8),
              Text(Formatters.currency(wallet.balance), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.addMoney),
                  icon: const Icon(Icons.add, size: 18), label: const Text('Add Money'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.darkBlue, padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(onPressed: () {},
                  icon: const Icon(Icons.send, size: 18), label: const Text('Send to Bank'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: const Text('See All')),
            ])),
          ...txns.getRecentTransactions(limit: 8).map((t) => TransactionTile(transaction: t)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
