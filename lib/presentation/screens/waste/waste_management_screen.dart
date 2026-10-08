import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../core/utils/app_haptics.dart';
import '../../../data/models/waste_record.dart';
import '../../controllers/waste_controller.dart';
import '../../widgets/animated_counting_number.dart';
import 'record_waste_dialog.dart';

class WasteManagementScreen extends ConsumerWidget {
  const WasteManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final wasteAsync = ref.watch(wasteNotifierProvider);

    return Scaffold(
      body: wasteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.spoilageRed)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (wasteState) {
          final records = wasteState.records;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Warning & Summary Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.spoilageRed.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.get('spoilage_loss', lang),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.analytics_outlined, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${records.length} ${lang == 'ar' ? 'سجلات' : 'records'}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedCountingNumber(
                        value: wasteState.totalFinancialLoss,
                        decimalDigits: 2,
                        suffix: ' ${AppStrings.get('currency', lang)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${lang == 'ar' ? 'إجمالي الكميات الهالكة:' : 'Total quantity lost:'} ${wasteState.totalQuantityWasted.toStringAsFixed(1)} ${lang == 'ar' ? 'كغ/وحدة' : 'units'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Spoilage Causes Breakdown
                Text(
                  lang == 'ar' ? 'توزيع أسباب التلف' : 'Spoilage Causes Breakdown',
                  style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                ),
                const SizedBox(height: 10),

                _buildWasteDonutChart(wasteState, lang, isDark),

                ...WasteReason.values.map((reason) {
                  final loss = wasteState.lossByReason[reason] ?? 0.0;
                  final pct = wasteState.totalFinancialLoss > 0
                      ? (loss / wasteState.totalFinancialLoss)
                      : 0.0;

                  final color = _getReasonColor(reason);
                  final icon = _getReasonIcon(reason);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(icon, size: 14, color: color),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  reason.getLocalized(lang),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${loss.toStringAsFixed(1)} ${AppStrings.get('currency', lang)} (${(pct * 100).toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: isDark ? Colors.white10 : AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // History Records Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      lang == 'ar' ? 'سجل العمليات الأخير' : 'Recent Spoilage Logs',
                      style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (records.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        lang == 'ar' ? 'لا يوجد هدر مسجل حتى الآن، رائع!' : 'No spoilage recorded yet, great!',
                        style: AppTypography.bodyMedium(isDark: isDark),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final formattedDate = DateFormat('yyyy/MM/dd - hh:mm a').format(record.date);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.spoilageLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: AppColors.spoilageRed, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lang == 'ar' ? record.produceNameAr : record.produceNameEn,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      Text(
                                        '-${record.financialLoss.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.spoilageRed,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${record.reason.getLocalized(lang)} • ${record.quantityWasted} كغ',
                                    style: AppTypography.bodySmall(isDark: isDark),
                                  ),
                                  if (record.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '"${record.notes}"',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'waste_record_produce_fab',
        onPressed: () {
          AppHaptics.medium();
          showDialog(
            context: context,
            builder: (_) => const RecordWasteDialog(),
          );
        },
        backgroundColor: AppColors.spoilageRed,
        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
        label: Text(
          AppStrings.get('record_waste', lang),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildWasteDonutChart(WasteState wasteState, String lang, bool isDark) {
    if (wasteState.totalFinancialLoss <= 0) return const SizedBox.shrink();

    final reasonColors = {
      WasteReason.wiltingAndRot: const Color(0xFFEF4444),
      WasteReason.transitDamage: const Color(0xFFF97316),
      WasteReason.poorCooling: const Color(0xFF3B82F6),
      WasteReason.pestContamination: const Color(0xFFA855F7),
      WasteReason.other: const Color(0xFF64748B),
    };

    final sections = <PieChartSectionData>[];
    for (final reason in WasteReason.values) {
      final loss = wasteState.lossByReason[reason] ?? 0.0;
      if (loss <= 0) continue;
      final pct = (loss / wasteState.totalFinancialLoss) * 100;
      sections.add(
        PieChartSectionData(
          color: reasonColors[reason] ?? AppColors.spoilageRed,
          value: loss,
          title: '${pct.toInt()}%',
          radius: 32,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 26,
                    sectionsSpace: 2.5,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pie_chart_rounded, size: 14, color: AppColors.spoilageRed),
                    Text(
                      '${wasteState.totalFinancialLoss.toInt()}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: WasteReason.values.where((r) => (wasteState.lossByReason[r] ?? 0) > 0).map((r) {
                final loss = wasteState.lossByReason[r] ?? 0.0;
                final color = reasonColors[r] ?? Colors.grey;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          r.getLocalized(lang),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${loss.toStringAsFixed(1)} ${AppStrings.get('currency', lang)}',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getReasonColor(WasteReason reason) {
    switch (reason) {
      case WasteReason.wiltingAndRot:
        return const Color(0xFFEF4444);
      case WasteReason.transitDamage:
        return const Color(0xFFF97316);
      case WasteReason.poorCooling:
        return const Color(0xFF3B82F6);
      case WasteReason.pestContamination:
        return const Color(0xFFA855F7);
      case WasteReason.other:
        return const Color(0xFF64748B);
    }
  }

  IconData _getReasonIcon(WasteReason reason) {
    switch (reason) {
      case WasteReason.wiltingAndRot:
        return Icons.eco_rounded;
      case WasteReason.transitDamage:
        return Icons.local_shipping_rounded;
      case WasteReason.poorCooling:
        return Icons.ac_unit_rounded;
      case WasteReason.pestContamination:
        return Icons.bug_report_rounded;
      case WasteReason.other:
        return Icons.more_horiz_rounded;
    }
  }
}
