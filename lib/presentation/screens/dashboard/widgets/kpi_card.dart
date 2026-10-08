import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../widgets/animated_counting_number.dart';
import '../../../widgets/frosted_glass_container.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final double? numericValue;
  final String? currencySuffix;
  final int decimalDigits;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String? trendText;
  final bool isTrendPositive;
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    this.numericValue,
    this.currencySuffix,
    this.decimalDigits = 0,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    this.trendText,
    this.isTrendPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FrostedGlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      onTap: () {
        AppHaptics.light();
        onTap?.call();
      },
      child: Stack(
        children: [
          // Ambient soft glow in the corner
          Positioned(
            top: -15,
            right: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    iconColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    iconColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  if (trendText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isTrendPositive ? AppColors.successLight : AppColors.spoilageLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTrendPositive
                              ? AppColors.successGreen.withValues(alpha: 0.3)
                              : AppColors.spoilageRed.withValues(alpha: 0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                            size: 13,
                            color: isTrendPositive ? AppColors.successGreen : AppColors.spoilageRed,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            trendText!,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isTrendPositive ? AppColors.successGreen : AppColors.spoilageRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppTypography.bodySmall(isDark: isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: numericValue != null
                    ? AnimatedCountingNumber(
                        value: numericValue!,
                        decimalDigits: decimalDigits,
                        suffix: currencySuffix != null ? ' $currencySuffix' : '',
                        style: AppTypography.numberMedium(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.2,
                        ),
                      )
                    : Text(
                        value,
                        style: AppTypography.numberMedium(isDark: isDark).copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.2,
                        ),
                      ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTypography.bodySmall(isDark: isDark).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
