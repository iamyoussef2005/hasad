import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle headlineLarge({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle headlineMedium({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        height: 1.3,
      );

  static TextStyle headlineSmall({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle titleMedium({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyLarge({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle bodyMedium({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle bodySmall({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );

  static TextStyle numberLarge({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle numberMedium({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      );

  static TextStyle numberSmall({required bool isDark}) => GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
      );
}
