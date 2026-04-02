import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../services/mock_data_service.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _upiController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _upiController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allContacts = MockDataService.getMockContacts();
    final favorites = allContacts.where((c) => c.isFavorite).toList();
    final filtered = _searchQuery.isEmpty
        ? allContacts
        : allContacts.where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.phone.contains(_searchQuery)
          ).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // UPI ID input
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter UPI ID or Mobile Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _upiController,
                          decoration: InputDecoration(
                            hintText: 'e.g. name@bank or 9876543210',
                            prefixIcon: const Icon(Icons.alternate_email, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final value = _upiController.text.trim();
                          if (value.isNotEmpty) {
                            Navigator.pushNamed(context, AppRoutes.enterAmount, arguments: {
                              'name': value.contains('@') ? value.split('@')[0] : value,
                              'upiId': value,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Go'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Search contacts
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // Favorites
            if (_searchQuery.isEmpty && favorites.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Favorites', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final c = favorites[index];
                    return GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.enterAmount, arguments: {'name': c.name, 'upiId': c.upiId ?? ''}),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: c.avatarColor.withOpacity(0.15),
                              child: Text(c.initials, style: TextStyle(color: c.avatarColor, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(height: 6),
                            Text(c.name.split(' ')[0], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            // All contacts
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                _searchQuery.isEmpty ? 'All Contacts' : 'Search Results',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.avatarColor.withOpacity(0.15),
                    child: Text(c.initials, style: TextStyle(color: c.avatarColor, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(c.phone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.enterAmount, arguments: {'name': c.name, 'upiId': c.upiId ?? ''}),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
