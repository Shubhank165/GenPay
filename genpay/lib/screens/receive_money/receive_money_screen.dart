import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/constants.dart';
import '../../services/mock_data_service.dart';

class ReceiveMoneyScreen extends StatelessWidget {
  const ReceiveMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDataService.getMockUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Receive Money'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Scan to Pay Me',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue, width: 3),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: 'upi://pay?pa=${user.upiId}&pn=${user.name}&cu=INR',
                        version: QrVersions.auto,
                        size: 200,
                        eyeStyle: const QrEyeStyle(color: AppColors.darkBlue, eyeShape: QrEyeShape.square),
                        dataModuleStyle: const QrDataModuleStyle(color: AppColors.darkBlue, dataModuleShape: QrDataModuleShape.square),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.upiId,
                        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAction(Icons.share_rounded, 'Share QR', () {}),
                  const SizedBox(width: 24),
                  _buildAction(Icons.download_rounded, 'Save QR', () {}),
                  const SizedBox(width: 24),
                  _buildAction(Icons.attach_money_rounded, 'Set Amount', () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: Icon(icon, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
