import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _statusMessage = '';
  Color _statusColor = AppColors.textSecondary;
  bool _showGuestOption = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _statusMessage = '';
      _showGuestOption = false;
    });

    final auth = context.read<AuthProvider>();
    final ok = await auth.sendOtp(_phoneController.text.trim());
    if (!mounted) return;

    if (ok) {
      Navigator.pushNamed(context, AppRoutes.otp);
      return;
    }

    setState(() {
      _statusMessage = auth.lastError ?? 'OTP call failed. Please try again.';
      _statusColor = AppColors.errorRed;
      _showGuestOption = true;
    });
  }

  Future<void> _continueAsGuest() async {
    final auth = context.read<AuthProvider>();
    final guestOk = await auth.loginAsGuest();
    if (!mounted) return;
    if (guestOk) {
      setState(() {
        _statusMessage = 'Logged in as guest.';
        _statusColor = AppColors.successGreen;
      });
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      return;
    }

    setState(() {
      _statusMessage = auth.lastError ?? 'Failed to start guest login';
      _statusColor = AppColors.errorRed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 36),
              const Text(
                'Login with Mobile Number',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              const Text(
                'We will place an OTP call to verify your number',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('IN +91', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          validator: Validators.phone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '',
                            hintText: 'Enter mobile number',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BAF2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'Send OTP via Call',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              if (_statusMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _statusColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(color: _statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              if (_showGuestOption) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _continueAsGuest(),
                    child: const Text('Continue as Guest'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
