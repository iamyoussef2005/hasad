import 'package:flutter/services.dart';

/// Provides sensory haptic feedback across touchpoints in the application.
class AppHaptics {
  AppHaptics._();

  /// Very light tick, perfect for tab switches, segmented selectors, or typing digits.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Subtle light impact, great for button clicks, card taps, or filter toggles.
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium tactile bump, suited for adding items to cart or activating toggles.
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact, suited for critical actions like applying discounts or confirming checkout.
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Celebratory double pulse on successful completion.
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }

  /// Alert vibrate pattern on warnings or errors.
  static Future<void> warning() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
