import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class OTPVerifyScreen extends StatefulWidget {
  const OTPVerifyScreen({super.key});

  @override
  State<OTPVerifyScreen> createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  final _otpController = TextEditingController();
  int _secondsLeft = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || _secondsLeft <= 0) return false;
      setState(() {
        _secondsLeft -= 1;
        _canResend = _secondsLeft == 0;
      });
      return _secondsLeft > 0;
    });
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.sendOtp(auth.phoneNumber);
    if (!mounted) return;

    if (ok) {
      setState(() {
        _secondsLeft = 30;
        _canResend = false;
      });
      _startTimer();
    }
  }

  Future<void> _verify(String otp) async {
    if (otp.length != 6) return;

    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(otp);
    if (!mounted) return;

    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invalid OTP'), backgroundColor: AppColors.errorRed),
    );
    _otpController.clear();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter OTP you heard on call',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Sent to ${auth.phoneNumber}',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _otpController,
              autoDismissKeyboard: true,
              keyboardType: TextInputType.number,
              autoFocus: true,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 50,
                fieldWidth: 44,
                activeFillColor: Colors.white,
                inactiveFillColor: Colors.white,
                selectedFillColor: Colors.white,
                activeColor: AppColors.primaryBlue,
                selectedColor: AppColors.darkBlue,
                inactiveColor: AppColors.border,
              ),
              enableActiveFill: true,
              onChanged: (_) {},
              onCompleted: _verify,
            ),
            const SizedBox(height: 16),
            Center(
              child: _canResend
                  ? TextButton(onPressed: _resend, child: const Text('Resend OTP'))
                  : Text('Resend in ${_secondsLeft}s', style: const TextStyle(color: AppColors.textSecondary)),
            ),
            if (AuthService.debugOtp != null) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Debug OTP: ${AuthService.debugOtp}',
                  style: const TextStyle(color: AppColors.warningYellow, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: auth.isLoading ? null : () => _verify(_otpController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: auth.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Verify', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
