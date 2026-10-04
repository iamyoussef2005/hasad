import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../data/models/produce_item.dart';
import '../../../widgets/frosted_glass_container.dart';
import 'freshness_badge.dart';

class ProduceListItem extends StatelessWidget {
  final ProduceItem item;
  final String lang;
  final VoidCallback onTap;

  const ProduceListItem({
    super.key,
    required this.item,
    required this.lang,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FrostedGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 16,
      onTap: onTap,
      child: Row(
        children: [
          // Emoji avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.getName(lang),
                        style: AppTypography.headlineSmall(isDark: isDark).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    FreshnessBadge(
                      score: item.freshnessScore,
                      lang: lang,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.category.getLocalizedName(lang),
                      style: AppTypography.bodySmall(isDark: isDark),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${lang == 'ar' ? 'المخزون:' : 'Stock:'} ${item.currentStock.toStringAsFixed(item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1)} ${item.unit.getLocalized(lang)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.isLowStock
                            ? AppColors.spoilageRed
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.hasRescueDiscount) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.spoilageRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${item.discountPercentage.toInt()}%',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (item.originalPrice != null)
                      Text(
                        item.originalPrice!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 10,
                          decoration: TextDecoration.lineThrough,
                          color: isDark ? AppColors.textSecondaryDark : Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
              ],
              Text(
                '${item.sellingPrice.toStringAsFixed(2)} ${lang == 'ar' ? 'ر.س' : 'SAR'}',
                style: AppTypography.numberSmall(isDark: isDark).copyWith(
                  color: item.hasRescueDiscount ? AppColors.spoilageRed : AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${lang == 'ar' ? 'ربح' : 'Margin'} ${item.profitMargin.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(width: 6),
          Icon(
            lang == 'ar' ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ],
      ),
    );
  }
}
