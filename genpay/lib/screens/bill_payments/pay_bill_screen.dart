import 'package:flutter/material.dart';
import '../../config/constants.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});
  @override State<PayBillScreen> createState() => _PayBillScreenState();
}

class _PayBillScreenState extends State<PayBillScreen> {
  final _consumerController = TextEditingController();
  bool _billFetched = false;
  bool _isFetching = false;

  void _fetchBill() async {
    setState(() => _isFetching = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() { _isFetching = false; _billFetched = true; });
  }

  @override void dispose() { _consumerController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final category = args?['category'] ?? 'Bill Payment';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(category), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select Provider', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                hint: const Text('Choose provider'),
                items: ['BSES Rajdhani', 'BSES Yamuna', 'Tata Power', 'Adani Electricity', 'MSEDCL']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (_) {},
              ),
              const SizedBox(height: 16),
              const Text('Consumer Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(controller: _consumerController, keyboardType: TextInputType.text,
                decoration: InputDecoration(hintText: 'Enter consumer/account number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _isFetching ? null : _fetchBill,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isFetching
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Fetch Bill', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                )),
            ]),
          ),
          if (_billFetched) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Bill Amount', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const Text('₹2,340.00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ]),
                const Divider(height: 24),
                _buildRow('Bill Date', '15 Mar 2026'),
                const SizedBox(height: 8),
                _buildRow('Due Date', '05 Apr 2026'),
                const SizedBox(height: 8),
                _buildRow('Consumer No.', _consumerController.text.isEmpty ? 'N/A' : _consumerController.text),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: const Text('Pay ₹2,340.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  Widget _buildRow(String l, String v) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(l, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
    Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  ]);
}
