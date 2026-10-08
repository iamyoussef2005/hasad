import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/waste_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../controllers/auth_controller.dart';
import '../inventory/produce_details_screen.dart';
import '../inventory/add_edit_produce_dialog.dart';
import '../waste/record_waste_dialog.dart';
import 'widgets/kpi_card.dart';
import 'widgets/freshness_gauge_widget.dart';
import 'widgets/weekly_waste_chart.dart';
import 'widgets/low_stock_banner.dart';
import 'widgets/ai_markdown_insights_card.dart';
import '../../widgets/app_shimmer_skeleton.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final wasteAsync = ref.watch(wasteNotifierProvider);
    final posState = ref.watch(posNotifierProvider);
    final authState = ref.watch(authNotifierProvider);

    return inventoryAsync.when(
      loading: () => const DashboardSkeleton(),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (inventory) {
        final wasteState = wasteAsync.value ?? const WasteState(records: []);
        final lowStockList = inventory.allItems.where((i) => i.isLowStock).toList();

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(inventoryNotifierProvider);
            ref.invalidate(wasteNotifierProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Executive Store & Staff Greeting Card
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              const Color(0xFF1E293B),
                              const Color(0xFF0F172A),
                            ]
                          : [
                              Colors.white,
                              const Color(0xFFF0FDF4),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            authState.currentUser?.avatarEmoji ?? '🌿',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lang == 'ar' ? 'مرحباً،' : 'Welcome,'} ${authState.currentUser?.name ?? (lang == 'ar' ? 'أبو صالح' : 'Manager')}',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == 'ar'
                                  ? 'سوق الخضار والتموين • العمليات النشطة'
                                  : 'Fresh Produce ERP • Live Terminal',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.successGreen.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.successGreen,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              lang == 'ar' ? 'نشط' : 'Active',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Quick Action Bar
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.add_circle_outline_rounded,
                        label: AppStrings.get('add_produce', lang),
                        color: AppColors.primary,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const AddEditProduceDialog(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.delete_sweep_outlined,
                        label: AppStrings.get('record_waste', lang),
                        color: AppColors.spoilageRed,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => const RecordWasteDialog(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => onNavigateToTab?.call(2), // POS tab
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          gradient: AppColors.citrusGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.point_of_sale_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Low stock warning banner if any
                LowStockBanner(
                  lowStockItems: lowStockList,
                  lang: lang,
                  onItemTap: (item) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProduceDetailsScreen(produceId: item.id),
                      ),
                    );
                  },
                ),

                // AI Dynamic Rescue Pricing & Spoilage Prevention Card
                const AiMarkdownInsightsCard(),
                const SizedBox(height: 4),

                // KPI Grid (2x2)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.25,
                  children: [
                    KpiCard(
                      title: AppStrings.get('total_inventory_value', lang),
                      value: '${inventory.totalStockValue.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                      numericValue: inventory.totalStockValue,
                      currencySuffix: AppStrings.get('currency', lang),
                      decimalDigits: 0,
                      subtitle: '${inventory.allItems.length} ${lang == 'ar' ? 'صنف مسجل' : 'items'}',
                      icon: Icons.inventory_2_rounded,
                      iconColor: AppColors.primary,
                      iconBgColor: AppColors.primaryLight,
                      trendText: '+8.4%',
                      isTrendPositive: true,
                    ),
                    KpiCard(
                      title: AppStrings.get('todays_sales', lang),
                      value: '${posState.todaySalesTotal.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                      numericValue: posState.todaySalesTotal,
                      currencySuffix: AppStrings.get('currency', lang),
                      decimalDigits: 0,
                      subtitle: lang == 'ar' ? 'أداء ممتاز اليوم' : 'Target achieved',
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.secondaryDark,
                      iconBgColor: AppColors.secondaryLight,
                      trendText: '+12.1%',
                      isTrendPositive: true,
                    ),
                    KpiCard(
                      title: AppStrings.get('spoilage_loss', lang),
                      value: '${wasteState.totalFinancialLoss.toStringAsFixed(1)} ${AppStrings.get('currency', lang)}',
                      numericValue: wasteState.totalFinancialLoss,
                      currencySuffix: AppStrings.get('currency', lang),
                      decimalDigits: 1,
                      subtitle: '${wasteState.records.length} ${lang == 'ar' ? 'عمليات إتلاف' : 'logs'}',
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.spoilageRed,
                      iconBgColor: AppColors.spoilageLight,
                      trendText: '-4.2%',
                      isTrendPositive: true, // Decreasing waste is good!
                    ),
                    KpiCard(
                      title: AppStrings.get('low_stock_items', lang),
                      value: '${inventory.lowStockCount}',
                      numericValue: inventory.lowStockCount.toDouble(),
                      decimalDigits: 0,
                      subtitle: lang == 'ar' ? 'يحتاج إعادة شراء' : 'Need reordering',
                      icon: Icons.warning_amber_rounded,
                      iconColor: AppColors.warningOrange,
                      iconBgColor: AppColors.warningLight,
                      trendText: '${inventory.lowStockCount}',
                      isTrendPositive: inventory.lowStockCount == 0,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Freshness Index Gauge
                FreshnessGaugeWidget(
                  score: inventory.averageFreshness,
                  lang: lang,
                ),
                const SizedBox(height: 16),

                // Weekly Sales vs Spoilage Chart
                WeeklyWasteChart(lang: lang),
                const SizedBox(height: 20),

                // Featured / Fast Moving Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang == 'ar' ? 'الأصناف الأكثر رواجاً بالمحل' : 'Fast Moving Produce',
                      style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                    ),
                    TextButton(
                      onPressed: () => onNavigateToTab?.call(1),
                      child: Text(
                        lang == 'ar' ? 'عرض الكل' : 'View All',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                SizedBox(
                  height: 122,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: inventory.allItems.take(6).length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = inventory.allItems[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProduceDetailsScreen(produceId: item.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 148,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.primaryLight.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: item.freshnessScore >= 0.8
                                          ? AppColors.successLight
                                          : (item.freshnessScore >= 0.5 ? AppColors.secondaryLight : AppColors.spoilageLight),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(item.freshnessScore * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: item.freshnessScore >= 0.8
                                            ? AppColors.successGreen
                                            : (item.freshnessScore >= 0.5 ? AppColors.secondaryDark : AppColors.spoilageRed),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item.getName(lang),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item.sellingPrice.toStringAsFixed(1)} ${AppStrings.get('currency', lang)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    '${item.currentStock.toInt()} ${item.unit.getLocalized(lang)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDark ? 0.35 : 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
