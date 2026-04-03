import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/local_storage_service.dart';
import '../../config/constants.dart';

class MobileRechargeScreen extends StatefulWidget {
  const MobileRechargeScreen({super.key});

  @override
  State<MobileRechargeScreen> createState() => _MobileRechargeScreenState();
}

class _MobileRechargeScreenState extends State<MobileRechargeScreen> {
  final _phoneController = TextEditingController();
  static const String _upiPin = '165165';
  String _selectedOperator = 'Jio';
  final operators = ['Jio', 'Airtel', 'Vi', 'BSNL'];
  final operatorColors = [const Color(0xFF0066FF), const Color(0xFFED1C24), const Color(0xFFFFCC00), const Color(0xFF007F3D)];
  bool _isLoading = true;
  bool _isRecharging = false;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final raw = await ApiService.listRechargePlans(operator: _selectedOperator);
      _plans = raw.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    } catch (_) {
      _plans = [];
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _doRecharge(Map<String, dynamic> plan) async {
    final phone = _phoneController.text.trim();
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
      return;
    }

    final enteredPin = await _askUpiPin();
    if (enteredPin == null) {
      return;
    }

    setState(() => _isRecharging = true);
    try {
      final token = await LocalStorageService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login first');
      }

      await ApiService.createTransaction(
        token,
        type: 'recharge',
        amount: ((plan['price'] ?? 0) as num).toDouble(),
        upiPin: enteredPin,
        recipientName: _selectedOperator,
        recipientIdentifier: phone,
        description: 'Mobile recharge ${plan['plan_type'] ?? ''}',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recharge successful'), backgroundColor: AppColors.successGreen),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recharge failed: $e'), backgroundColor: AppColors.errorRed),
      );
    } finally {
      if (mounted) {
        setState(() => _isRecharging = false);
      }
    }
  }

  Future<String?> _askUpiPin() async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter UPI PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 6,
          decoration: const InputDecoration(hintText: '6-digit UPI PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (pin == null) {
      return null;
    }
    if (pin != _upiPin) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid UPI PIN'), backgroundColor: AppColors.errorRed),
      );
      return null;
    }
    return pin;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mobile Recharge'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16), color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 10,
                  decoration: InputDecoration(hintText: 'Enter mobile number', prefixIcon: const Icon(Icons.phone_android, size: 20),
                    counterText: '', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(operators.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(operators[i]),
                      selected: _selectedOperator == operators[i],
                      selectedColor: operatorColors[i].withOpacity(0.2),
                      labelStyle: TextStyle(color: _selectedOperator == operators[i] ? operatorColors[i] : AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
                      onSelected: (_) {
                        setState(() => _selectedOperator = operators[i]);
                        _loadPlans();
                      },
                    ),
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? const Center(
                        child: Text(
                          'No plans available',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final price = ((plan['price'] ?? 0) as num).toDouble();
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rs ${price.toStringAsFixed(0)}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Validity: ${plan['validity_days']} days  •  Data: ${plan['data_per_day'] ?? '-'}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        (plan['description'] ?? '').toString(),
                                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _isRecharging ? null : () => _doRecharge(plan),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: _isRecharging
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Text('Recharge', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
