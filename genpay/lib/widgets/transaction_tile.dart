import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(),
                color: _getCategoryColor(),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.recipientName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.categoryLabel} • ${Formatters.relativeDate(transaction.timestamp)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: transaction.isCredit
                        ? AppColors.successGreen
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                _buildStatusChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String text;

    switch (transaction.status) {
      case TransactionStatus.success:
        color = AppColors.successGreen;
        text = 'Success';
      case TransactionStatus.failed:
        color = AppColors.errorRed;
        text = 'Failed';
      case TransactionStatus.pending:
        color = AppColors.pendingOrange;
        text = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (transaction.category) {
      case TransactionCategory.upiTransfer:
        return transaction.isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
      case TransactionCategory.mobileRecharge:
        return Icons.phone_android;
      case TransactionCategory.dthRecharge:
        return Icons.tv;
      case TransactionCategory.electricity:
        return Icons.bolt;
      case TransactionCategory.gas:
        return Icons.local_fire_department;
      case TransactionCategory.water:
        return Icons.water_drop;
      case TransactionCategory.broadband:
        return Icons.wifi;
      case TransactionCategory.creditCard:
        return Icons.credit_card;
      case TransactionCategory.walletTopup:
        return Icons.account_balance_wallet;
      case TransactionCategory.walletWithdraw:
        return Icons.account_balance_wallet;
      case TransactionCategory.flight:
        return Icons.flight;
      case TransactionCategory.bus:
        return Icons.directions_bus;
      case TransactionCategory.train:
        return Icons.train;
      case TransactionCategory.hotel:
        return Icons.hotel;
      case TransactionCategory.gold:
        return Icons.monetization_on;
      case TransactionCategory.insurance:
        return Icons.shield;
      case TransactionCategory.loan:
        return Icons.account_balance;
      case TransactionCategory.other:
        return Icons.receipt;
    }
  }

  Color _getCategoryColor() {
    switch (transaction.category) {
      case TransactionCategory.upiTransfer:
        return transaction.isCredit ? AppColors.successGreen : AppColors.primaryBlue;
      case TransactionCategory.mobileRecharge:
        return AppColors.rechargeColor;
      case TransactionCategory.dthRecharge:
        return AppColors.dthColor;
      case TransactionCategory.electricity:
        return AppColors.electricityColor;
      case TransactionCategory.gas:
        return AppColors.gasColor;
      case TransactionCategory.water:
        return AppColors.waterColor;
      case TransactionCategory.broadband:
        return AppColors.broadbandColor;
      case TransactionCategory.creditCard:
        return AppColors.creditCardColor;
      case TransactionCategory.walletTopup:
      case TransactionCategory.walletWithdraw:
        return AppColors.primaryBlue;
      case TransactionCategory.flight:
      case TransactionCategory.bus:
      case TransactionCategory.train:
      case TransactionCategory.hotel:
        return AppColors.broadbandColor;
      case TransactionCategory.gold:
        return AppColors.goldColor;
      case TransactionCategory.insurance:
        return AppColors.insuranceColor;
      case TransactionCategory.loan:
        return AppColors.loanColor;
      case TransactionCategory.other:
        return AppColors.textSecondary;
    }
  }
}
