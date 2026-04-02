import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/mock_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getMockUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight)),
              child: Column(children: [
                Row(children: [
                  Container(width: 68, height: 68, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)),
                    child: const Center(child: Text('RS', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('+91 ${user.phone}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    const SizedBox(height: 4),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.verified, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('KYC Verified', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ])),
                  ])),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.edit, color: Colors.white)),
                ]),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildSection('Account', [
                  _MenuItem(Icons.fingerprint, 'My UPI ID', 'rahul@genpay', () {}),
                  _MenuItem(Icons.credit_card, 'Payment Methods', null, () {}),
                  _MenuItem(Icons.account_balance, 'Bank Accounts', null, () => Navigator.pushNamed(context, AppRoutes.bankBalance)),
                  _MenuItem(Icons.account_balance_wallet, 'Wallet', null, () => Navigator.pushNamed(context, AppRoutes.wallet)),
                ]),
                const SizedBox(height: 16),
                _buildSection('Security', [
                  _MenuItem(Icons.lock, 'Change UPI PIN', null, () {}),
                  _MenuItem(Icons.verified_user, 'KYC Details', null, () => Navigator.pushNamed(context, AppRoutes.kyc)),
                  _MenuItem(Icons.privacy_tip, 'Privacy & Permissions', null, () {}),
                ]),
                const SizedBox(height: 16),
                _buildSection('Rewards & More', [
                  _MenuItem(Icons.stars, 'Reward Points', '2,450 pts', () {}),
                  _MenuItem(Icons.card_giftcard, 'Refer & Earn', null, () {}),
                  _MenuItem(Icons.local_offer, 'My Coupons', null, () {}),
                ]),
                const SizedBox(height: 16),
                _buildSection('Settings', [
                  _MenuItem(Icons.settings, 'App Settings', null, () => Navigator.pushNamed(context, AppRoutes.settings)),
                  _MenuItem(Icons.help_outline, 'Help & Support', null, () {}),
                  _MenuItem(Icons.info_outline, 'About GenPay', null, () {}),
                ]),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().logout();
                      if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    },
                    icon: const Icon(Icons.logout, color: AppColors.errorRed),
                    label: const Text('Logout', style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.errorRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
                const SizedBox(height: 12),
                Text('GenPay v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary))),
        ...items.map((item) => ListTile(
          leading: Container(width: 38, height: 38, decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, color: AppColors.primaryBlue, size: 20)),
          title: Text(item.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (item.value != null) Text(item.value!, style: const TextStyle(fontSize: 13, color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
          ]),
          onTap: item.onTap,
        )),
        const SizedBox(height: 8),
      ]),
    );
  }
}

class _MenuItem { final IconData icon; final String label; final String? value; final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.value, this.onTap); }
