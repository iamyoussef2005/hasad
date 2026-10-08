import 'package:flutter/material.dart';

/// Smoothly counts up from an old number to a new number using TweenAnimationBuilder.
class AnimatedCountingNumber extends StatelessWidget {
  final double value;
  final TextStyle? style;
  final int decimalDigits;
  final Duration duration;
  final Curve curve;
  final String? prefix;
  final String? suffix;

  const AnimatedCountingNumber({
    super.key,
    required this.value,
    this.style,
    this.decimalDigits = 0,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final formattedNumber = decimalDigits > 0
            ? animatedValue.toStringAsFixed(decimalDigits)
            : animatedValue.toInt().toString();

        return Text(
          '${prefix ?? ''}$formattedNumber${suffix ?? ''}',
          style: style,
        );
      },
    );
  }
}
