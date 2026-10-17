import 'package:flutter/material.dart';

class AppColors {
  // Primary Emerald Greens
  static const Color primary = Color(0xFF38745B); // Emerald 500
  static const Color primaryDark = Color(0xFF28543F); // Emerald 600
  static const Color primaryLight = Color(0xFFE8EFE9); // Emerald 100
  static const Color primaryAccent = Color(0xFF8FC7A3); // Emerald 400

  // Secondary Citrus & Golden
  static const Color secondary = Color(0xFFAB8046); // Amber 500
  static const Color secondaryDark = Color(0xFF8A622D); // Amber 600
  static const Color secondaryLight = Color(0xFFF4EEE3); // Amber 100
  static const Color citrusYellow = Color(0xFFFBBF24); // Amber 400

  // Alert & Spoilage Colors
  static const Color spoilageRed = Color(0xFFB65043); // Red 500
  static const Color spoilageLight = Color(0xFFF7ECE9); // Red 100
  static const Color warningOrange = Color(0xFFAB753C); // Orange 500
  static const Color warningLight = Color(0xFFFFEDD5); // Orange 100
  static const Color successGreen = Color(0xFF467653); // Green 500
  static const Color successLight = Color(0xFFE9F0E8); // Green 100

  // Light Theme Surfaces
  static const Color bgLight = Color(0xFFF6F5F1); // Soft botanical background
  static const Color surfaceLight = Colors.white;
  static const Color cardLight = Colors.white;
  static const Color borderLight = Color(0xFFE4E5DF); // Slate 200
  static const Color textPrimaryLight = Color(0xFF242C28); // Slate 900
  static const Color textSecondaryLight = Color(0xFF707871); // Slate 500

  // Dark Theme Surfaces
  static const Color bgDark = Color(0xFF242C28); // Slate 900
  static const Color surfaceDark = Color(0xFF2D3630); // Slate 800
  static const Color cardDark = Color(0xFF2D3630); // Slate 800
  static const Color borderDark = Color(0xFF414B43); // Slate 700
  static const Color textPrimaryDark = Color(
    0xFFF6F5F1,
  ); // Soft botanical background
  static const Color textSecondaryDark = Color(0xFFA9B4AB); // Slate 400

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF38745B), Color(0xFF28543F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient citrusGradient = LinearGradient(
    colors: [Color(0xFFAB8046), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardDarkGradient = LinearGradient(
    colors: [Color(0xFF2D3630), Color(0xFF242C28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
