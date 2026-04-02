import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';

class ServicesHomeScreen extends StatelessWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      _Svc('Personal Loan', 'Get instant loan up to ₹10 Lakh', Icons.account_balance, AppColors.loanColor, [Color(0xFF795548), Color(0xFFA1887F)]),
      _Svc('Credit Score', 'Check your CIBIL score for free', Icons.speed, AppColors.orangeCTA, [Color(0xFFFF6B35), Color(0xFFFF9800)]),
      _Svc('Mutual Funds', 'Start SIP from ₹100/month', Icons.show_chart, AppColors.successGreen, [Color(0xFF4CAF50), Color(0xFF81C784)]),
      _Svc('Insurance', 'Life, health & vehicle insurance', Icons.shield, AppColors.primaryBlue, [Color(0xFF2196F3), Color(0xFF00BCD4)]),
      _Svc('Digital Gold', 'Buy 24K pure gold from ₹1', Icons.monetization_on, AppColors.goldColor, [Color(0xFFFFD700), Color(0xFFFFC107)]),
      _Svc('Fixed Deposit', 'Earn up to 8.5% p.a.', Icons.savings, AppColors.broadbandColor, [Color(0xFF9C27B0), Color(0xFFE040FB)]),
      _Svc('Stocks', 'Invest in top companies', Icons.candlestick_chart, AppColors.stocksColor, [Color(0xFF4CAF50), Color(0xFF2E7D32)]),
      _Svc('Credit Card', 'Apply for premium cards', Icons.credit_card, AppColors.creditCardColor, [Color(0xFFE91E63), Color(0xFFFF5722)]),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Financial Services'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final s = services[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () {
                if (s.title == 'Digital Gold') Navigator.pushNamed(context, AppRoutes.gold);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
                child: Row(children: [
                  Container(width: 54, height: 54,
                    decoration: BoxDecoration(gradient: LinearGradient(colors: s.gradient), borderRadius: BorderRadius.circular(14)),
                    child: Icon(s.icon, color: Colors.white, size: 26)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(s.subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  ])),
                  const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Svc { final String title, subtitle; final IconData icon; final Color color; final List<Color> gradient;
  const _Svc(this.title, this.subtitle, this.icon, this.color, this.gradient); }
