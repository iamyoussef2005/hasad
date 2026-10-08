import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../widgets/frosted_glass_container.dart';

import '../../ai_scanner/ai_freshness_scanner_screen.dart';

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
      borderRadius: 22,
      child: Column(
        children: [
          Row(
            children: [
              // Circular Progress Indicator with glowing shadow
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: score),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, animScore, child) {
                    final animPercentage = (animScore * 100).toInt();
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: animScore,
                          strokeWidth: 8.5,
                          backgroundColor: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.borderLight,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                          strokeCap: StrokeCap.round,
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$animPercentage%',
                                style: AppTypography.numberMedium(isDark: isDark).copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 19,
                                ),
                              ),
                              Text(
                                lang == 'ar' ? 'مؤشر الجودة' : 'QUALITY',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            statusTitle,
                            style: AppTypography.headlineSmall(isDark: isDark).copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      statusDesc,
                      style: AppTypography.bodySmall(isDark: isDark).copyWith(
                        height: 1.35,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Action Bar footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      lang == 'ar' ? 'فحص جودة المحاصيل بالذكاء الاصطناعي' : 'AI Crop Quality Inspection',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiFreshnessScannerScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.document_scanner_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          lang == 'ar' ? 'فحص بالكاميرا' : 'Scan',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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
