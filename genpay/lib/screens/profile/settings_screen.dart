import 'package:flutter/material.dart';
import '../../config/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  bool _biometric = true;
  bool _txnAlerts = true;
  bool _promoNotifs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings'), backgroundColor: AppColors.darkBlue, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _section('General', [
          ListTile(leading: const Icon(Icons.language, color: AppColors.primaryBlue), title: const Text('Language'),
            trailing: DropdownButton<String>(value: _language, underline: const SizedBox(),
              items: ['English', 'Hindi', 'Tamil', 'Telugu'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) => setState(() => _language = v!))),
          SwitchListTile(secondary: const Icon(Icons.fingerprint, color: AppColors.primaryBlue),
            title: const Text('Biometric Login'), value: _biometric, activeColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => _biometric = v)),
        ]),
        const SizedBox(height: 16),
        _section('Notifications', [
          SwitchListTile(secondary: const Icon(Icons.notifications_active, color: AppColors.primaryBlue),
            title: const Text('Transaction Alerts'), value: _txnAlerts, activeColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => _txnAlerts = v)),
          SwitchListTile(secondary: const Icon(Icons.campaign, color: AppColors.primaryBlue),
            title: const Text('Promotional'), value: _promoNotifs, activeColor: AppColors.primaryBlue,
            onChanged: (v) => setState(() => _promoNotifs = v)),
        ]),
        const SizedBox(height: 16),
        _section('Security', [
          _tile(Icons.lock_reset, 'Change UPI PIN'),
          _tile(Icons.password, 'Change App Lock'),
          _tile(Icons.devices, 'Linked Devices'),
        ]),
        const SizedBox(height: 16),
        _section('Data & Privacy', [
          _tile(Icons.download, 'Download Data'),
          ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.errorRed),
            title: const Text('Delete Account', style: TextStyle(color: AppColors.errorRed)),
            trailing: const Icon(Icons.chevron_right), onTap: () {}),
        ]),
        const SizedBox(height: 16),
        Center(child: Text('GenPay v1.0.0', style: TextStyle(fontSize: 12, color: AppColors.textTertiary))),
      ]),
    );
  }

  Widget _section(String t, List<Widget> c) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(t, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
    const SizedBox(height: 8),
    Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: c)),
  ]);

  Widget _tile(IconData i, String t) => ListTile(leading: Icon(i, color: AppColors.primaryBlue), title: Text(t),
    trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary), onTap: () {});
}
