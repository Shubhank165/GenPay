import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/upi_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/animated_status.dart';

class PaymentStatusScreen extends StatelessWidget {
  const PaymentStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final upi = context.watch<UpiProvider>();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                AnimatedStatus(isSuccess: upi.paymentSuccess),
                const SizedBox(height: 32),
                Text(
                  upi.paymentSuccess ? 'Payment Successful!' : 'Payment Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: upi.paymentSuccess ? AppColors.successGreen : AppColors.errorRed,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  Formatters.currency(upi.amount),
                  style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'To ${upi.recipientName}',
                  style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  upi.recipientUpiId,
                  style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 24),
                // Transaction details
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Transaction ID', upi.transactionRef),
                      const SizedBox(height: 8),
                      _buildDetailRow('Date & Time', Formatters.dateTime(DateTime.now())),
                      if (upi.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Note', upi.note),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                // Action buttons
                Row(
                  children: [
                    if (!upi.paymentSuccess)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Retry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (!upi.paymentSuccess) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          upi.reset();
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
