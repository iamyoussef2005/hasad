import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../data/models/produce_item.dart';
import '../../../widgets/frosted_glass_container.dart';
import 'freshness_badge.dart';

class ProduceGridCard extends StatelessWidget {
  final ProduceItem item;
  final String lang;
  final VoidCallback onTap;
  final VoidCallback? onQuickAction;

  const ProduceGridCard({
    super.key,
    required this.item,
    required this.lang,
    required this.onTap,
    this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FrostedGlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Emoji / Icon & Freshness Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.primaryLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              FreshnessBadge(
                score: item.freshnessScore,
                lang: lang,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Produce Name
          Text(
            item.getName(lang),
            style: AppTypography.headlineSmall(isDark: isDark).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Category tag
          Text(
            item.category.getLocalizedName(lang),
            style: AppTypography.bodySmall(isDark: isDark).copyWith(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          // Stock Qty Bar & Health Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.isLowStock
                  ? (isDark ? const Color(0xFF3B1D1D) : AppColors.spoilageLight)
                  : (isDark ? AppColors.surfaceDark : AppColors.bgLight),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item.isLowStock
                    ? AppColors.spoilageRed.withValues(alpha: 0.4)
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                      size: 11,
                      color: item.isLowStock ? AppColors.spoilageRed : AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      lang == 'ar' ? 'المخزون:' : 'Stock:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: item.isLowStock ? AppColors.spoilageRed : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${item.currentStock.toStringAsFixed(item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1)} ${item.unit.getLocalized(lang)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: item.isLowStock ? AppColors.spoilageRed : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Price and Currency with rescue discount support
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        lang == 'ar' ? 'سعر البيع' : 'Sell Price',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (item.hasRescueDiscount) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.spoilageRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${item.discountPercentage.toInt()}%',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.sellingPrice.toStringAsFixed(2),
                        style: AppTypography.numberMedium(isDark: isDark).copyWith(
                          color: item.hasRescueDiscount ? AppColors.spoilageRed : AppColors.primary,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        lang == 'ar' ? 'ر.س' : 'SAR',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: item.hasRescueDiscount ? AppColors.spoilageRed : AppColors.primary,
                        ),
                      ),
                      if (item.hasRescueDiscount && item.originalPrice != null) ...[
                        const SizedBox(width: 5),
                        Text(
                          item.originalPrice!.toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: isDark ? AppColors.textSecondaryDark : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              // Quick action button
              if (onQuickAction != null)
                InkWell(
                  onTap: onQuickAction,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
