import 'package:flutter/material.dart';
import '../../config/constants.dart';

class LinkBankScreen extends StatelessWidget {
  const LinkBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final banks = [
      {'name': 'State Bank of India', 'color': 0xFF1565C0},
      {'name': 'HDFC Bank', 'color': 0xFF004C8F},
      {'name': 'ICICI Bank', 'color': 0xFFB85C1F},
      {'name': 'Axis Bank', 'color': 0xFF800020},
      {'name': 'Punjab National Bank', 'color': 0xFF003F87},
      {'name': 'Bank of Baroda', 'color': 0xFFE8611A},
      {'name': 'Kotak Mahindra Bank', 'color': 0xFFED1C24},
      {'name': 'Yes Bank', 'color': 0xFF0060A8},
      {'name': 'IndusInd Bank', 'color': 0xFF004E8C},
      {'name': 'Canara Bank', 'color': 0xFFF5A623},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Link Bank Account'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            decoration: InputDecoration(hintText: 'Search banks...', prefixIcon: const Icon(Icons.search, size: 20),
              filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
          const SizedBox(height: 16),
          const Text('Popular Banks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...banks.map((bank) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(
                color: Color(bank['color'] as int).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.account_balance, color: Color(bank['color'] as int), size: 22)),
              title: Text(bank['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                showDialog(context: context, builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Bank Linked!'),
                  content: Text('${bank['name']} has been linked successfully.'),
                  actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('Done'))],
                ));
              },
            ),
          )),
        ]),
      ),
    );
  }
}
