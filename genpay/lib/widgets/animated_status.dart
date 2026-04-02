import 'package:flutter/material.dart';
import '../config/constants.dart';

class AnimatedStatus extends StatefulWidget {
  final bool isSuccess;
  final double size;
  final Duration duration;

  const AnimatedStatus({
    super.key,
    required this.isSuccess,
    this.size = 120,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedStatus> createState() => _AnimatedStatusState();
}

class _AnimatedStatusState extends State<AnimatedStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSuccess ? AppColors.successGreen : AppColors.errorRed;
    final icon = widget.isSuccess ? Icons.check_rounded : Icons.close_rounded;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
                border: Border.all(color: color, width: 3),
              ),
              child: Icon(
                icon,
                color: color,
                size: widget.size * 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}
