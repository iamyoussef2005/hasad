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
import '../../../domain/services/stock_attention_service.dart';
import 'widgets/store_overview_header.dart';
import 'widgets/stock_attention_panel.dart';
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
        final attention = const StockAttentionService().evaluate(
          inventory.allItems,
        );

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
                StoreOverviewHeader(
                  name:
                      authState.currentUser?.name ??
                      (lang == 'ar' ? 'المدير' : 'Manager'),
                  lang: lang,
                  attentionCount: attention.length,
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: () => onNavigateToTab?.call(2),
                      icon: const Icon(Icons.point_of_sale_outlined, size: 18),
                      label: Text(AppStrings.get('quick_pos', lang)),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const AddEditProduceDialog(),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(AppStrings.get('add_produce', lang)),
                    ),
                    TextButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) => const RecordWasteDialog(),
                      ),
                      icon: const Icon(Icons.remove_circle_outline, size: 18),
                      label: Text(AppStrings.get('record_waste', lang)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) => GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: constraints.maxWidth >= 900
                          ? 4
                          : (constraints.maxWidth < 280 ? 1 : 2),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent:
                          148 *
                          MediaQuery.textScalerOf(
                            context,
                          ).scale(1).clamp(1.0, 2.0),
                    ),
                    children: [
                      KpiCard(
                        title: AppStrings.get('total_inventory_value', lang),
                        value:
                            '${inventory.totalStockValue.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                        onTap: () => onNavigateToTab?.call(1),
                        numericValue: inventory.totalStockValue,
                        currencySuffix: AppStrings.get('currency', lang),
                        decimalDigits: 0,
                        subtitle:
                            '${inventory.allItems.length} ${lang == 'ar' ? 'صنف مسجل' : 'items'}',
                        icon: Icons.inventory_2_rounded,
                        iconColor: AppColors.primary,
                        iconBgColor: AppColors.primaryLight,
                        isTrendPositive: true,
                      ),
                      KpiCard(
                        title: AppStrings.get('todays_sales', lang),
                        value:
                            '${posState.todaySalesTotal.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                        onTap: () => onNavigateToTab?.call(2),
                        numericValue: posState.todaySalesTotal,
                        currencySuffix: AppStrings.get('currency', lang),
                        decimalDigits: 0,
                        subtitle: lang == 'ar'
                            ? 'إجمالي المبيعات المسجلة'
                            : 'Recorded sales total',
                        icon: Icons.trending_up_rounded,
                        iconColor: AppColors.secondaryDark,
                        iconBgColor: AppColors.secondaryLight,
                        isTrendPositive: true,
                      ),
                      KpiCard(
                        title: AppStrings.get('spoilage_loss', lang),
                        value:
                            '${wasteState.totalFinancialLoss.toStringAsFixed(1)} ${AppStrings.get('currency', lang)}',
                        onTap: () => onNavigateToTab?.call(3),
                        numericValue: wasteState.totalFinancialLoss,
                        currencySuffix: AppStrings.get('currency', lang),
                        decimalDigits: 1,
                        subtitle:
                            '${wasteState.records.length} ${lang == 'ar' ? 'عمليات إتلاف' : 'logs'}',
                        icon: Icons.delete_outline_rounded,
                        iconColor: AppColors.spoilageRed,
                        iconBgColor: AppColors.spoilageLight,
                        isTrendPositive: true, // Decreasing waste is good!
                      ),
                      KpiCard(
                        title: AppStrings.get('low_stock_items', lang),
                        value: '${inventory.lowStockCount}',
                        onTap: () => onNavigateToTab?.call(1),
                        numericValue: inventory.lowStockCount.toDouble(),
                        decimalDigits: 0,
                        subtitle: lang == 'ar'
                            ? 'يحتاج إعادة شراء'
                            : 'Need reordering',
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.warningOrange,
                        iconBgColor: AppColors.warningLight,
                        isTrendPositive: inventory.lowStockCount == 0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                StockAttentionPanel(items: inventory.allItems, lang: lang),
                const AiMarkdownInsightsCard(),

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
                      lang == 'ar' ? 'من المخزون' : 'From your inventory',
                      style: AppTypography.headlineSmall(
                        isDark: isDark,
                      ).copyWith(fontSize: 15),
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
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = inventory.allItems[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProduceDetailsScreen(produceId: item.id),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: 148,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.06)
                                          : AppColors.primaryLight.withValues(
                                              alpha: 0.6,
                                            ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.freshnessScore >= 0.8
                                          ? AppColors.successLight
                                          : (item.freshnessScore >= 0.5
                                                ? AppColors.secondaryLight
                                                : AppColors.spoilageLight),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${(item.freshnessScore * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: item.freshnessScore >= 0.8
                                            ? AppColors.successGreen
                                            : (item.freshnessScore >= 0.5
                                                  ? AppColors.secondaryDark
                                                  : AppColors.spoilageRed),
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
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondaryLight,
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
}
