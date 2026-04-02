import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../widgets/service_icon_tile.dart';

class BillCategoriesScreen extends StatelessWidget {
  const BillCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      _Cat(Icons.bolt, 'Electricity', AppColors.electricityColor),
      _Cat(Icons.local_fire_department, 'Piped Gas', AppColors.gasColor),
      _Cat(Icons.water_drop, 'Water', AppColors.waterColor),
      _Cat(Icons.wifi, 'Broadband / Landline', AppColors.broadbandColor),
      _Cat(Icons.tv, 'DTH', AppColors.dthColor),
      _Cat(Icons.credit_card, 'Credit Card', AppColors.creditCardColor),
      _Cat(Icons.shield, 'Insurance Premium', AppColors.insuranceColor),
      _Cat(Icons.home, 'Rent', AppColors.loanColor),
      _Cat(Icons.school, 'Education Fees', AppColors.primaryBlue),
      _Cat(Icons.apartment, 'Municipal Tax', AppColors.textSecondary),
      _Cat(Icons.directions_car, 'FASTag', AppColors.fastagColor),
      _Cat(Icons.local_hospital, 'Hospital / Pathology', AppColors.errorRed),
      _Cat(Icons.subscriptions, 'Subscription', AppColors.broadbandColor),
      _Cat(Icons.local_post_office, 'LPG Gas Cylinder', AppColors.orangeCTA),
      _Cat(Icons.cable, 'Cable TV', AppColors.dthColor),
      _Cat(Icons.business, 'Housing Society', AppColors.successGreen),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bill Payments'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            decoration: InputDecoration(hintText: 'Search bill categories...', prefixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 16),
          const Text('All Categories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: GridView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.8, mainAxisSpacing: 12, crossAxisSpacing: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return ServiceIconTile(icon: cat.icon, label: cat.label, color: cat.color,
                  onTap: () => Navigator.pushNamed(context, AppRoutes.payBill, arguments: {'category': cat.label}));
              },
            ),
          ),
        ]),
      ),
    );
  }
}

class _Cat { final IconData icon; final String label; final Color color; const _Cat(this.icon, this.label, this.color); }
