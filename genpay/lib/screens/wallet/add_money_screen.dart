import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/wallet_provider.dart';
import '../../utils/formatters.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});
  @override State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final _amountController = TextEditingController();

  @override void dispose() { _amountController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Money'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              const Text('Enter Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(controller: _amountController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(prefixText: '₹ ', prefixStyle: TextStyle(fontSize: 40, fontWeight: FontWeight.w300, color: AppColors.textSecondary),
                  hintText: '0', border: InputBorder.none)),
              const SizedBox(height: 16),
              Wrap(spacing: 8, children: [500, 1000, 2000, 5000].map((a) => ActionChip(
                label: Text('₹$a'), onPressed: () => _amountController.text = a.toString(),
                backgroundColor: AppColors.lightBlue, labelStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600))).toList()),
            ]),
          ),
          const Spacer(),
          SizedBox(width: double.infinity, height: 54,
            child: Consumer<WalletProvider>(
              builder: (context, wallet, _) => ElevatedButton(
                onPressed: wallet.isLoading ? null : () async {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    await wallet.addMoney(amount);
                    if (context.mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${Formatters.currency(amount)} added to wallet'), backgroundColor: AppColors.successGreen)); }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: wallet.isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : const Text('Add Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            )),
        ]),
      ),
    );
  }
}
