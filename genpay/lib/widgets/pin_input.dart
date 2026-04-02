import 'package:flutter/material.dart';
import '../config/constants.dart';

class PinInput extends StatefulWidget {
  final String title;
  final int pinLength;
  final Function(String) onCompleted;
  final VoidCallback? onCancel;

  const PinInput({
    super.key,
    this.title = 'Enter UPI PIN',
    this.pinLength = 4,
    required this.onCompleted,
    this.onCancel,
  });

  @override
  State<PinInput> createState() => _PinInputState();
}

class _PinInputState extends State<PinInput> with SingleTickerProviderStateMixin {
  String _pin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (_pin.length < widget.pinLength) {
      setState(() => _pin += digit);
      if (_pin.length == widget.pinLength) {
        widget.onCompleted(_pin);
      }
    }
  }

  void _removeDigit() {
    if (_pin.isNotEmpty) {
      setState(() => _pin = _pin.substring(0, _pin.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded, color: AppColors.darkBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // PIN dots
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.pinLength, (i) {
                    final isFilled = i < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? AppColors.darkBlue : Colors.transparent,
                        border: Border.all(
                          color: isFilled ? AppColors.darkBlue : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Numpad
          _buildNumpad(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumRow(['1', '2', '3']),
          _buildNumRow(['4', '5', '6']),
          _buildNumRow(['7', '8', '9']),
          _buildNumRow(['', '0', 'DEL']),
        ],
      ),
    );
  }

  Widget _buildNumRow(List<String> digits) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: digits.map((digit) {
          if (digit.isEmpty) {
            return const SizedBox(width: 72, height: 56);
          }
          if (digit == 'DEL') {
            return GestureDetector(
              onTap: _removeDigit,
              child: const SizedBox(
                width: 72,
                height: 56,
                child: Center(
                  child: Icon(Icons.backspace_outlined, color: AppColors.textPrimary, size: 24),
                ),
              ),
            );
          }
          return GestureDetector(
            onTap: () => _addDigit(digit),
            child: Container(
              width: 72,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
