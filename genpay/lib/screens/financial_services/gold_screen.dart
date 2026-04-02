import 'package:flutter/material.dart';
import '../../config/constants.dart';

class GoldScreen extends StatefulWidget {
  const GoldScreen({super.key});
  @override State<GoldScreen> createState() => _GoldScreenState();
}

class _GoldScreenState extends State<GoldScreen> {
  bool _isBuy = true;
  final _amountController = TextEditingController();
  final double _goldPrice = 7245.50; // per gram mock

  @override void dispose() { _amountController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Digital Gold'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Price card
          Container(
            width: double.infinity, padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text('Live Gold Price', style: TextStyle(color: Colors.brown.shade900.withOpacity(0.7), fontSize: 13)),
              const SizedBox(height: 4),
              Text('₹${_goldPrice.toStringAsFixed(2)}/gram', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.brown.shade900)),
              const SizedBox(height: 4),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.trending_up, color: AppColors.successGreen, size: 16),
                  SizedBox(width: 4),
                  Text('+1.2% today', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                ])),
              const SizedBox(height: 12),
              Text('24K Pure Gold • 99.9% Purity', style: TextStyle(color: Colors.brown.shade900.withOpacity(0.6), fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),
          // Gold balance
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Gold', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                SizedBox(height: 4),
                Text('0.5432 grams', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Value', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('₹${(0.5432 * _goldPrice).toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.successGreen)),
              ]),
            ])),
          const SizedBox(height: 16),
          // Buy/Sell toggle
          Container(
            padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _isBuy = true),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(
                  color: _isBuy ? AppColors.primaryBlue : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Buy Gold', style: TextStyle(fontWeight: FontWeight.w600, color: _isBuy ? Colors.white : AppColors.textSecondary)))))),
              Expanded(child: GestureDetector(onTap: () => setState(() => _isBuy = false),
                child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(
                  color: !_isBuy ? AppColors.orangeCTA : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Sell Gold', style: TextStyle(fontWeight: FontWeight.w600, color: !_isBuy ? Colors.white : AppColors.textSecondary)))))),
            ])),
          const SizedBox(height: 16),
          // Amount input
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text(_isBuy ? 'Enter amount to invest' : 'Enter amount to sell', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              TextField(controller: _amountController, keyboardType: TextInputType.number, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(prefixText: '₹ ', prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w300), hintText: '0', border: InputBorder.none)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [100, 500, 1000, 5000].map((a) => ActionChip(label: Text('₹$a'),
                onPressed: () => _amountController.text = a.toString(),
                backgroundColor: AppColors.lightBlue, labelStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600))).toList()),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isBuy ? 'Gold purchase simulated!' : 'Gold sell simulated!'),
                    backgroundColor: AppColors.successGreen));
                }, style: ElevatedButton.styleFrom(backgroundColor: _isBuy ? AppColors.primaryBlue : AppColors.orangeCTA,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(_isBuy ? 'Buy Gold' : 'Sell Gold', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
            ])),
        ]),
      ),
    );
  }
}
