import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../services/mock_data_service.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});
  @override State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final tabs = ['All', 'UPI', 'Recharge', 'Bills', 'Travel', 'Shopping'];

  @override void initState() { super.initState(); _tabController = TabController(length: tabs.length, vsync: this); }
  @override void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final offers = MockDataService.getMockOffers();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Offers & Cashback'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(controller: _tabController, isScrollable: true, indicatorColor: Colors.white, indicatorWeight: 3,
          labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          tabs: tabs.map((t) => Tab(text: t)).toList())),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((tab) {
          final filtered = tab == 'All' ? offers : offers.where((o) => o.category == tab).toList();
          if (filtered.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.local_offer_outlined, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text('No offers in $tab', style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            ]));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: filtered.length,
            itemBuilder: (context, index) {
              final offer = filtered[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: offer.gradientColors[0].withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))]),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(gradient: LinearGradient(colors: offer.gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                        child: Icon(offer.icon, color: Colors.white, size: 24)),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        if (offer.discountText != null) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(6)),
                          child: Text(offer.discountText!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                        const SizedBox(height: 4),
                        Text(offer.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      ])),
                    ]),
                    const SizedBox(height: 12),
                    Text(offer.description, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                    if (offer.couponCode != null) ...[
                      const SizedBox(height: 12),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.3), style: BorderStyle.solid)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('Code: ${offer.couponCode}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1)),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy, color: Colors.white, size: 16),
                        ])),
                    ],
                  ]),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
