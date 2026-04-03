import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';

class RecentContacts extends StatelessWidget {
  const RecentContacts({super.key});

  @override
  Widget build(BuildContext context) {
    final txns = context.watch<TransactionProvider>().getRecentTransactions(limit: 10);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transfers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.sendMoney),
                  child: const Text(
                    'See All',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 90,
            child: txns.isEmpty
                ? const Center(
                    child: Text(
                      'No recent transfers yet',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: txns.length,
                    itemBuilder: (context, index) {
                      final txn = txns[index];
                      final name = txn.recipientName.isEmpty ? 'User' : txn.recipientName;
                      final initials = name
                          .split(' ')
                          .where((w) => w.isNotEmpty)
                          .take(2)
                          .map((w) => w[0].toUpperCase())
                          .join();

                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.enterAmount,
                            arguments: {
                              'name': name,
                              'upiId': txn.recipientUpiId,
                            },
                          );
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    initials.isEmpty ? 'U' : initials,
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                name.split(' ').first,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
