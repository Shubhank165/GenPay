import 'package:flutter/material.dart';
import '../../config/constants.dart';

class DthRechargeScreen extends StatefulWidget {
  const DthRechargeScreen({super.key});
  @override State<DthRechargeScreen> createState() => _DthRechargeScreenState();
}

class _DthRechargeScreenState extends State<DthRechargeScreen> {
  String _selectedOperator = '';
  final _subscriberController = TextEditingController();
  final _amountController = TextEditingController();
  final operators = [
    {'name': 'Tata Play', 'color': 0xFF1A237E},
    {'name': 'Airtel Digital TV', 'color': 0xFFED1C24},
    {'name': 'Dish TV', 'color': 0xFF6A1B9A},
    {'name': 'Sun Direct', 'color': 0xFFFF6F00},
    {'name': 'Videocon d2h', 'color': 0xFF0077C2},
  ];

  @override void dispose() { _subscriberController.dispose(); _amountController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('DTH Recharge'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select Operator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...operators.map((op) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              title: Text(op['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
              value: op['name'] as String, groupValue: _selectedOperator,
              activeColor: AppColors.primaryBlue,
              onChanged: (v) => setState(() => _selectedOperator = v!),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )),
          const SizedBox(height: 16),
          const Text('Subscriber ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(controller: _subscriberController, keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter Subscriber ID', prefixIcon: const Icon(Icons.tv, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(controller: _amountController, keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Enter Amount', prefixText: '₹ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: [200, 300, 500, 1000].map((a) => ActionChip(
            label: Text('₹$a'), onPressed: () => _amountController.text = a.toString(),
            backgroundColor: AppColors.lightBlue, labelStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
          )).toList()),
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(onPressed: () { Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Recharge Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))),
        ]),
      ),
    );
  }
}
