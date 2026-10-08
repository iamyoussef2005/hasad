import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../data/models/produce_category.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/waste_controller.dart';
import '../../controllers/pos_controller.dart';
import '../../widgets/animated_counting_number.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

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

        final estRevenue = posState.todaySalesTotal * 7; // Weekly projection
        final estCost = inventory.totalStockValue * 0.7;
        final netProfit = (estRevenue - estCost - wasteState.totalFinancialLoss).clamp(0.0, 999999.0);
        final wastePercent = estRevenue > 0 ? (wasteState.totalFinancialLoss / estRevenue) * 100 : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Export Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'ar' ? 'التحليلات والأداء المالي' : 'Financial & Store Analytics',
                    style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 16),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      AppHaptics.success();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            lang == 'ar'
                                ? 'جاري تجهيز تقرير المخزون بصيغة PDF وتصديره...'
                                : 'Generating PDF inventory report...',
                          ),
                          backgroundColor: AppColors.primaryDark,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.primary),
                    label: Text(
                      lang == 'ar' ? 'تصدير PDF' : 'Export PDF',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Executive Financial Health Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          lang == 'ar' ? 'صافي الأرباح المتوقعة (أسبوعي)' : 'Est. Weekly Net Profit',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${(100 - wastePercent).toStringAsFixed(1)}% ${lang == 'ar' ? 'كفاءة' : 'Efficiency'}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: AnimatedCountingNumber(
                        value: netProfit,
                        decimalDigits: 2,
                        suffix: ' ${AppStrings.get('currency', lang)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSubStat(
                          lang == 'ar' ? 'المبيعات' : 'Revenue',
                          '${estRevenue.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                        ),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildSubStat(
                          lang == 'ar' ? 'خسائر الهدر' : 'Spoilage',
                          '-${wasteState.totalFinancialLoss.toStringAsFixed(0)} ${AppStrings.get('currency', lang)}',
                        ),
                        Container(width: 1, height: 24, color: Colors.white24),
                        _buildSubStat(
                          AppStrings.get('spoilage_rate', lang),
                          '${wastePercent.toStringAsFixed(1)}%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Share Pie Chart
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'ar' ? 'توزيع قيمة المخزون حسب التصنيف' : 'Stock Value by Category',
                      style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 3,
                                centerSpaceRadius: 36,
                                sections: [
                                  PieChartSectionData(value: 38, color: AppColors.primary, title: '38%', radius: 42, titleStyle: _chartTextStyle),
                                  PieChartSectionData(value: 26, color: AppColors.secondary, title: '26%', radius: 42, titleStyle: _chartTextStyle),
                                  PieChartSectionData(value: 18, color: const Color(0xFF3B82F6), title: '18%', radius: 42, titleStyle: _chartTextStyle),
                                  PieChartSectionData(value: 12, color: const Color(0xFF8B5CF6), title: '12%', radius: 42, titleStyle: _chartTextStyle),
                                  PieChartSectionData(value: 6, color: AppColors.spoilageRed, title: '6%', radius: 42, titleStyle: _chartTextStyle),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPieLegend(AppColors.primary, ProduceCategory.vegetables.getLocalizedName(lang), isDark),
                              const SizedBox(height: 6),
                              _buildPieLegend(AppColors.secondary, ProduceCategory.fruits.getLocalizedName(lang), isDark),
                              const SizedBox(height: 6),
                              _buildPieLegend(const Color(0xFF3B82F6), ProduceCategory.citrus.getLocalizedName(lang), isDark),
                              const SizedBox(height: 6),
                              _buildPieLegend(const Color(0xFF8B5CF6), ProduceCategory.leafyGreens.getLocalizedName(lang), isDark),
                              const SizedBox(height: 6),
                              _buildPieLegend(AppColors.spoilageRed, ProduceCategory.herbs.getLocalizedName(lang), isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recommendations for Vegetable Store Owner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF132E24) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryDark, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          lang == 'ar' ? 'توصيات ذكية لتفادي الهدر' : 'Smart Waste-Prevention Insights',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInsightRow(
                      icon: Icons.percent_rounded,
                      color: AppColors.secondary,
                      text: lang == 'ar'
                          ? 'الفراولة والخس الروماني يقتربان من الذبول: ينصح بتطبيق خصم 20% لتصريفهما خلال 24 ساعة.'
                          : 'Strawberries & Romaine wilting soon: apply 20% rescue markdown to liquidate within 24h.',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildInsightRow(
                      icon: Icons.add_shopping_cart_rounded,
                      color: AppColors.primary,
                      text: lang == 'ar'
                          ? 'صنف الخيار وصل للحد الأدنى للمخزون: ينصح بطلب دفعة توريد جديدة قبل الغد لتغطية الطلب.'
                          : 'Greenhouse Cucumbers hit low threshold: place supplier purchase order before tomorrow.',
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  static const TextStyle _chartTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  Widget _buildSubStat(String title, String val) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
      ],
    );
  }

  Widget _buildPieLegend(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color color,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 12),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
