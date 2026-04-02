import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../utils/formatters.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifs = [
      _Notif('Payment Received', 'Priya Patel sent you ₹1,500', Icons.arrow_downward, AppColors.successGreen, DateTime.now().subtract(const Duration(minutes: 15)), false),
      _Notif('Recharge Successful', 'Mobile recharge of ₹299 done', Icons.phone_android, AppColors.primaryBlue, DateTime.now().subtract(const Duration(hours: 2)), false),
      _Notif('Cashback Credited', '₹50 cashback on electricity bill', Icons.card_giftcard, AppColors.orangeCTA, DateTime.now().subtract(const Duration(hours: 5)), true),
      _Notif('Bill Reminder', 'Electricity bill of ₹2,340 due in 3 days', Icons.bolt, AppColors.warningYellow, DateTime.now().subtract(const Duration(days: 1)), true),
      _Notif('Payment Sent', '₹3,200 sent to Amit Kumar', Icons.arrow_upward, AppColors.primaryBlue, DateTime.now().subtract(const Duration(days: 1)), true),
      _Notif('Gold Price Alert', 'Gold prices dropped 1.5% today', Icons.monetization_on, AppColors.goldColor, DateTime.now().subtract(const Duration(days: 2)), true),
      _Notif('New Offer', '20% cashback on flight bookings', Icons.local_offer, AppColors.broadbandColor, DateTime.now().subtract(const Duration(days: 3)), true),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white,
        actions: [TextButton(onPressed: () {}, child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 13)))]),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notifs.length,
        itemBuilder: (context, index) {
          final n = notifs[index];
          return Container(
            color: n.isRead ? Colors.transparent : AppColors.lightBlue.withOpacity(0.3),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(width: 44, height: 44,
                decoration: BoxDecoration(color: n.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(n.icon, color: n.color, size: 22)),
              title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700, fontSize: 14)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 2),
                Text(n.desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(Formatters.relativeDate(n.time), style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              ]),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

class _Notif {
  final String title, desc;
  final IconData icon;
  final Color color;
  final DateTime time;
  final bool isRead;
  const _Notif(this.title, this.desc, this.icon, this.color, this.time, this.isRead);
}
