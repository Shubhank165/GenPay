import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/transaction_tile.dart';
import '../../utils/formatters.dart';

class PassbookScreen extends StatefulWidget {
  const PassbookScreen({super.key});

  @override
  State<PassbookScreen> createState() => _PassbookScreenState();
}

class _PassbookScreenState extends State<PassbookScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChange);
  }

  void _onTabChange() {
    final provider = context.read<TransactionProvider>();
    switch (_tabController.index) {
      case 0:
        provider.filterByType(null);
      case 1:
        provider.filterByType(TransactionType.sent);
      case 2:
        provider.filterByType(TransactionType.received);
      case 3:
        provider.filterByType(TransactionType.recharge);
      case 4:
        provider.filterByType(TransactionType.billPayment);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Passbook'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
            Tab(text: 'Recharge'),
            Tab(text: 'Bills'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary card
          Consumer<TransactionProvider>(
            builder: (context, txnProvider, _) {
              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Sent', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currencyCompact(txnProvider.totalSent),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.errorRed),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Received', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.currencyCompact(txnProvider.totalReceived),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.successGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => context.read<TransactionProvider>().search(v),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Transaction list
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, txnProvider, _) {
                final transactions = txnProvider.transactions;
                if (transactions.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: AppColors.textTertiary),
                        SizedBox(height: 16),
                        Text('No transactions found', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: transactions.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade100, indent: 74),
                  itemBuilder: (context, index) => TransactionTile(transaction: transactions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
