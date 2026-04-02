import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAction(
            context,
            Icons.qr_code_scanner_rounded,
            'Scan &\nPay',
            AppColors.primaryBlue,
            () => Navigator.pushNamed(context, AppRoutes.scanPay),
          ),
          _buildAction(
            context,
            Icons.send_rounded,
            'Send\nMoney',
            AppColors.orangeCTA,
            () => Navigator.pushNamed(context, AppRoutes.sendMoney),
          ),
          _buildAction(
            context,
            Icons.qr_code_rounded,
            'Receive\nMoney',
            AppColors.successGreen,
            () => Navigator.pushNamed(context, AppRoutes.receiveMoney),
          ),
          _buildAction(
            context,
            Icons.account_balance_rounded,
            'Bank\nBalance',
            AppColors.broadbandColor,
            () => Navigator.pushNamed(context, AppRoutes.bankBalance),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
