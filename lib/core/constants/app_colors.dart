import 'package:flutter/material.dart';

class AppColors {
  // Primary Emerald Greens
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color primaryAccent = Color(0xFF34D399); // Emerald 400

  // Secondary Citrus & Golden
  static const Color secondary = Color(0xFFF59E0B); // Amber 500
  static const Color secondaryDark = Color(0xFFD97706); // Amber 600
  static const Color secondaryLight = Color(0xFFFEF3C7); // Amber 100
  static const Color citrusYellow = Color(0xFFFBBF24); // Amber 400

  // Alert & Spoilage Colors
  static const Color spoilageRed = Color(0xFFEF4444); // Red 500
  static const Color spoilageLight = Color(0xFFFEE2E2); // Red 100
  static const Color warningOrange = Color(0xFFF97316); // Orange 500
  static const Color warningLight = Color(0xFFFFEDD5); // Orange 100
  static const Color successGreen = Color(0xFF22C55E); // Green 500
  static const Color successLight = Color(0xFFDCFCE7); // Green 100

  // Light Theme Surfaces
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  // Dark Theme Surfaces
  static const Color bgDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient citrusGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
