import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/waste_controller.dart';
import '../../controllers/pos_controller.dart';
import '../inventory/produce_details_screen.dart';
import '../inventory/add_edit_produce_dialog.dart';
import '../waste/record_waste_dialog.dart';
import 'widgets/kpi_card.dart';
import 'widgets/freshness_gauge_widget.dart';
import 'widgets/weekly_waste_chart.dart';
import 'widgets/low_stock_banner.dart';

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

    return inventoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppColors.citrusGradient,
                          borderRadius: BorderRadius.circular(14),
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
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: inventory.allItems.take(5).length,
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
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(item.emoji, style: const TextStyle(fontSize: 22)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${(item.freshnessScore * 100).toInt()}%',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                item.getName(lang),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
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
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Text(
                                    '${item.currentStock.toInt()} ${item.unit.getLocalized(lang)}',
                                    style: TextStyle(
                                      fontSize: 10,
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
                const SizedBox(height: 24),
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : color,
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
