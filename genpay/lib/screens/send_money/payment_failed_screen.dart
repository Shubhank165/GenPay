import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';

class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: AppColors.errorRed, size: 52),
              ),
              const SizedBox(height: 18),
              const Text(
                'Payment Failed',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'You are now authenticated. Continue to retry payment securely.',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go To Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
