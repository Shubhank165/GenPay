import 'package:flutter/material.dart';
import '../../config/constants.dart';

class KycScreen extends StatelessWidget {
  const KycScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('KYC Verification'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Status card
          Container(
            padding: const EdgeInsets.all(20), width: double.infinity,
            decoration: BoxDecoration(color: AppColors.successGreenLight, borderRadius: BorderRadius.circular(18)),
            child: const Row(children: [
              Icon(Icons.verified, color: AppColors.successGreen, size: 32),
              SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('KYC Verified', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.successGreen)),
                SizedBox(height: 2),
                Text('Your identity has been verified successfully', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              ])),
            ])),
          const SizedBox(height: 24),
          const Text('Verification Steps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildStep(1, 'Aadhaar Verification', 'XXXX-XXXX-3456', true),
          _buildStep(2, 'PAN Verification', 'ABCDE1234F', true),
          _buildStep(3, 'Video KYC', 'Completed on 15 Mar 2026', true),
          const SizedBox(height: 24),
          const Text('Benefits of Full KYC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildBenefit(Icons.account_balance_wallet, 'Wallet limit up to ₹1,00,000'),
          _buildBenefit(Icons.swap_horiz, 'UPI transaction limit ₹1,00,000/day'),
          _buildBenefit(Icons.monetization_on, 'Access to all financial services'),
          _buildBenefit(Icons.shield, 'Enhanced account security'),
        ]),
      ),
    );
  }

  Widget _buildStep(int num, String title, String detail, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: completed ? AppColors.successGreen : AppColors.textTertiary),
          child: Center(child: completed ? const Icon(Icons.check, color: Colors.white, size: 18) : Text('$num', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        if (completed) const Icon(Icons.check_circle, color: AppColors.successGreen, size: 22),
      ]),
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, color: AppColors.primaryBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary))),
      ]),
    );
  }
}
