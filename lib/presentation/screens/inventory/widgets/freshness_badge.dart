import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FreshnessBadge extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String lang;
  final bool compact;

  const FreshnessBadge({
    super.key,
    required this.score,
    required this.lang,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeColor;
    final Color textColor;
    final String label;
    final IconData icon;

    if (score >= 0.85) {
      badgeColor = AppColors.successLight;
      textColor = AppColors.primaryDark;
      label = lang == 'ar' ? 'طازج ممتاز' : 'Peak Fresh';
      icon = Icons.verified_rounded;
    } else if (score >= 0.70) {
      badgeColor = AppColors.primaryLight;
      textColor = AppColors.primaryDark;
      label = lang == 'ar' ? 'جيد جداً' : 'Good';
      icon = Icons.check_circle_outline_rounded;
    } else if (score >= 0.50) {
      badgeColor = AppColors.warningLight;
      textColor = AppColors.warningOrange;
      label = lang == 'ar' ? 'تصريف سريع' : 'Fast Sell';
      icon = Icons.access_time_filled_rounded;
    } else {
      badgeColor = AppColors.spoilageLight;
      textColor = AppColors.spoilageRed;
      label = lang == 'ar' ? 'خطر تلف' : 'Wilting';
      icon = Icons.warning_amber_rounded;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 3),
            Text(
              '${(score * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
