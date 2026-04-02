import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../services/mock_data_service.dart';

class MobileRechargeScreen extends StatefulWidget {
  const MobileRechargeScreen({super.key});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String _selectedOperator = 'Jio';
  late TabController _tabController;
  final operators = ['Jio', 'Airtel', 'Vi', 'BSNL'];
  final operatorColors = [Color(0xFF0066FF), Color(0xFFED1C24), Color(0xFFFFCC00), Color(0xFF007F3D)];

  @override void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); }
  @override void dispose() { _phoneController.dispose(); _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final plans = MockDataService.getMobileRechargePlans();
    final tabs = plans.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mobile Recharge'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16), color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 10,
                  decoration: InputDecoration(hintText: 'Enter mobile number', prefixIcon: const Icon(Icons.phone_android, size: 20),
                    counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(operators.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(operators[i]),
                      selected: _selectedOperator == operators[i],
                      selectedColor: operatorColors[i].withOpacity(0.2),
                      labelStyle: TextStyle(color: _selectedOperator == operators[i] ? operatorColors[i] : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                      onSelected: (_) => setState(() => _selectedOperator = operators[i]),
                    ),
                  )),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController, labelColor: AppColors.primaryBlue, unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue, indicatorWeight: 3,
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: tabs.map((tab) {
                final tabPlans = plans[tab]!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16), itemCount: tabPlans.length,
                  itemBuilder: (context, index) {
                    final plan = tabPlans[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('₹${plan['price']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                              const SizedBox(height: 4),
                              Text('Validity: ${plan['validity']}  •  Data: ${plan['data']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(plan['desc'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                            ]),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.paymentStatus),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                            child: const Text('Recharge', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
