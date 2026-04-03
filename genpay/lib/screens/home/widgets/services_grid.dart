import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../config/routes.dart';
import '../../../widgets/service_icon_tile.dart';

class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      _ServiceItem(Icons.phone_android, 'Mobile\nRecharge', AppColors.rechargeColor, AppRoutes.mobileRecharge),
      _ServiceItem(Icons.tv, 'DTH\nRecharge', AppColors.dthColor, AppRoutes.dthRecharge),
      _ServiceItem(Icons.bolt, 'Electricity', AppColors.electricityColor, AppRoutes.billCategories),
      _ServiceItem(Icons.local_fire_department, 'Piped Gas', AppColors.gasColor, AppRoutes.billCategories),
      _ServiceItem(Icons.water_drop, 'Water', AppColors.waterColor, AppRoutes.billCategories),
      _ServiceItem(Icons.wifi, 'Broadband', AppColors.broadbandColor, AppRoutes.billCategories),
      _ServiceItem(Icons.directions_car, 'FASTag', AppColors.fastagColor, AppRoutes.billCategories),
      _ServiceItem(Icons.credit_card, 'Credit Card\nBill', AppColors.creditCardColor, AppRoutes.billCategories),
      _ServiceItem(Icons.account_balance, 'Loans', AppColors.loanColor, AppRoutes.financialServices),
      _ServiceItem(Icons.shield, 'Insurance', AppColors.insuranceColor, AppRoutes.financialServices),
      _ServiceItem(Icons.monetization_on, 'Gold', AppColors.goldColor, AppRoutes.gold),
      _ServiceItem(Icons.show_chart, 'Stocks &\nMF', AppColors.stocksColor, AppRoutes.financialServices),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
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
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.78,
          crossAxisSpacing: 4,
          mainAxisSpacing: 8,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return ServiceIconTile(
            icon: service.icon,
            label: service.label,
            color: service.color,
            onTap: () => Navigator.pushNamed(context, service.route),
          );
        },
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _ServiceItem(this.icon, this.label, this.color, this.route);
}
