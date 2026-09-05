import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../widgets/frosted_glass_container.dart';

class FreshnessGaugeWidget extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final String lang;

  const FreshnessGaugeWidget({
    super.key,
    required this.score,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (score * 100).toInt();

    final Color statusColor = score >= 0.8
        ? AppColors.primary
        : score >= 0.6
            ? AppColors.secondary
            : AppColors.spoilageRed;

    final String statusTitle = score >= 0.8
        ? (lang == 'ar' ? 'حالة المخزون ممتازة' : 'Excellent Freshness')
        : score >= 0.6
            ? (lang == 'ar' ? 'يحتاج متابعة وتصريف' : 'Moderate - Needs Attention')
            : (lang == 'ar' ? 'تنبيه: بضائع تقترب من التلف' : 'Critical Spoilage Alert');

    final String statusDesc = score >= 0.8
        ? (lang == 'ar' ? 'أغلب الخضار والفواكه طازجة وفي ذروة جودتها' : 'Most produce is fresh and at peak shelf life')
        : score >= 0.6
            ? (lang == 'ar' ? 'بادر بعمل عروض تخفيض على الأصناف سريعة الذبول' : 'Promote discount sales for wilting items')
            : (lang == 'ar' ? 'قم بفرز البضاعة التالفة فوراً لتجنب إتلاف باقي الصناديق' : 'Segregate decaying items to protect adjacent crates');

    return FrostedGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          // Circular Progress Indicator
          SizedBox(
            width: 76,
            height: 76,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score,
                  strokeWidth: 8,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.borderLight,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  strokeCap: StrokeCap.round,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$percentage%',
                        style: AppTypography.numberMedium(isDark: isDark).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'INDEX',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusTitle,
                      style: AppTypography.headlineSmall(isDark: isDark).copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusDesc,
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
