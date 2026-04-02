import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';

class TravelHomeScreen extends StatelessWidget {
  const TravelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Travel & Entertainment'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Category cards
          Row(children: [
            _buildCategoryCard(context, Icons.flight, 'Flights', 'Domestic & International', AppColors.primaryBlue, () => Navigator.pushNamed(context, AppRoutes.flightBooking)),
            const SizedBox(width: 12),
            _buildCategoryCard(context, Icons.train, 'Trains', 'IRCTC Booking', AppColors.successGreen, () {}),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _buildCategoryCard(context, Icons.directions_bus, 'Buses', 'AC, Sleeper & More', AppColors.orangeCTA, () => Navigator.pushNamed(context, AppRoutes.busBooking)),
            const SizedBox(width: 12),
            _buildCategoryCard(context, Icons.hotel, 'Hotels', 'Best Deals', AppColors.broadbandColor, () {}),
          ]),
          const SizedBox(height: 24),
          // Deals
          const Text('Featured Deals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildDealCard('Delhi → Mumbai', 'Flights starting at ₹2,999', [Color(0xFF2196F3), Color(0xFF00BCD4)], Icons.flight),
          const SizedBox(height: 12),
          _buildDealCard('Goa Getaway', 'Hotels from ₹1,499/night', [Color(0xFF9C27B0), Color(0xFFE040FB)], Icons.hotel),
          const SizedBox(height: 12),
          _buildDealCard('Weekend Buses', 'Flat ₹100 off on AC buses', [Color(0xFFFF6B35), Color(0xFFFF9800)], Icons.directions_bus),
          const SizedBox(height: 24),
          const Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _buildRecentSearch('Delhi → Goa', '15 Apr, 1 Adult', Icons.flight),
          _buildRecentSearch('Mumbai → Pune', '20 Apr, 2 Adults', Icons.directions_bus),
          _buildRecentSearch('Bangalore → Chennai', '22 Apr, 1 Adult', Icons.train),
        ]),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ),
      ),
    );
  }

  Widget _buildDealCard(String title, String desc, List<Color> colors, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
        ])),
        Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: Colors.white, size: 22)),
      ]),
    );
  }

  Widget _buildRecentSearch(String route, String details, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(route, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(details, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
