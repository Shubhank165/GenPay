import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/bank_provider.dart';
import '../../providers/bill_provider.dart';
import '../../widgets/app_bottom_nav.dart';
import '../../widgets/search_bar.dart';
import 'widgets/balance_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_contacts.dart';
import 'widgets/services_grid.dart';
import 'widgets/offers_carousel.dart';
import 'widgets/promo_banner.dart';
import '../../screens/scan/scan_pay_screen.dart';
import '../../screens/offers/offers_screen.dart';
import '../../screens/passbook/passbook_screen.dart';
import '../../screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<TransactionProvider>().loadTransactions();
    context.read<BankProvider>().loadAccounts();
    context.read<BillProvider>().loadBills();
  }

  Widget _getBody() {
    switch (_currentNavIndex) {
      case 0:
        return _buildHomeBody();
      case 1:
        return const ScanPayScreen();
      case 2:
        return const OffersScreen();
      case 3:
        return const PassbookScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeBody();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) => setState(() => _currentNavIndex = index),
      ),
    );
  }

  Widget _buildHomeBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await Future.delayed(const Duration(seconds: 1));
      },
      color: AppColors.primaryBlue,
      child: CustomScrollView(
        slivers: [
          // App Bar with search
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      // Top row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'GenPay',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          _buildAppBarIcon(Icons.qr_code_scanner_rounded, () {
                            setState(() => _currentNavIndex = 1);
                          }),
                          const SizedBox(width: 8),
                          _buildAppBarIcon(Icons.notifications_outlined, () {
                            Navigator.pushNamed(context, AppRoutes.notifications);
                          }),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => setState(() => _currentNavIndex = 4),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Search bar
                      AppSearchBar(
                        readOnly: true,
                        onTap: () {
                          // TODO: navigate to search
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Balance Card
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: BalanceCard(),
            ),
          ),

          // Quick Actions
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: QuickActions(),
            ),
          ),

          // Recent Contacts
          const SliverToBoxAdapter(
            child: RecentContacts(),
          ),

          // Promo Banner
          const SliverToBoxAdapter(
            child: PromoBanner(),
          ),

          // Services Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recharge & Pay Bills',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.billCategories),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const ServicesGrid(),
                ],
              ),
            ),
          ),

          // Offers Carousel
          const SliverToBoxAdapter(
            child: OffersCarousel(),
          ),

          // Travel Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Travel & Entertainment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTravelCard(Icons.flight, 'Flights', AppColors.primaryBlue, () {
                        Navigator.pushNamed(context, AppRoutes.flightBooking);
                      }),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.train, 'Trains', AppColors.successGreen, () {}),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.directions_bus, 'Buses', AppColors.orangeCTA, () {
                        Navigator.pushNamed(context, AppRoutes.busBooking);
                      }),
                      const SizedBox(width: 12),
                      _buildTravelCard(Icons.hotel, 'Hotels', AppColors.broadbandColor, () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Financial Services
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Financial Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFinanceRow(),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTravelCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFinanceCard('Digital\nGold', Icons.monetization_on, AppColors.goldColor, () {
            Navigator.pushNamed(context, AppRoutes.gold);
          }),
          _buildFinanceCard('Mutual\nFunds', Icons.show_chart, AppColors.successGreen, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Insurance', Icons.shield, AppColors.primaryBlue, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Loans', Icons.account_balance, AppColors.loanColor, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
          _buildFinanceCard('Credit\nScore', Icons.speed, AppColors.orangeCTA, () {
            Navigator.pushNamed(context, AppRoutes.financialServices);
          }),
        ],
      ),
    );
  }

  Widget _buildFinanceCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
