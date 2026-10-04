import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../widgets/frosted_glass_container.dart';

class WeeklyWasteChart extends StatelessWidget {
  final String lang;

  const WeeklyWasteChart({
    super.key,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final daysAr = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
    final daysEn = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    final days = lang == 'ar' ? daysAr : daysEn;

    // Sales vs Loss mock data (in hundreds of SAR)
    final salesData = [18.0, 22.0, 19.5, 26.0, 24.0, 31.0, 35.0];
    final wasteData = [1.8, 2.1, 3.4, 1.2, 2.5, 1.9, 2.2];

    return FrostedGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'المبيعات مقارنة بالهدر هذا الأسبوع' : 'Weekly Sales vs Spoilage',
                    style: AppTypography.headlineSmall(isDark: isDark).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    lang == 'ar' ? 'مقارنة يومية بالريال السعودي (مئات)' : 'Daily comparison in SAR (x100)',
                    style: AppTypography.bodySmall(isDark: isDark),
                  ),
                ],
              ),
              // Legend
              Row(
                children: [
                  _buildLegendItem(
                    color: AppColors.primary,
                    label: lang == 'ar' ? 'مبيعات' : 'Sales',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _buildLegendItem(
                    color: AppColors.spoilageRed,
                    label: lang == 'ar' ? 'هدر وتلف' : 'Waste',
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 40,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? AppColors.surfaceDark : Colors.white,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.borderLight,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) {
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 5,
                    barRods: [
                      BarChartRodData(
                        toY: salesData[i],
                        gradient: const LinearGradient(
                          colors: [Color(0xFF34D399), Color(0xFF059669)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 11,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: wasteData[i],
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF87171), Color(0xFFDC2626)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        width: 9,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label, required bool isDark}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
