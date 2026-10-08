import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../data/models/batch_item.dart';
import '../../controllers/inventory_controller.dart';
import '../waste/record_waste_dialog.dart';
import '../ai_scanner/ai_freshness_scanner_screen.dart';
import 'add_edit_produce_dialog.dart';
import 'widgets/freshness_badge.dart';

class ProduceDetailsScreen extends ConsumerWidget {
  final String produceId;

  const ProduceDetailsScreen({super.key, required this.produceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);

    return inventoryAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (inventory) {
        final item = inventory.allItems.firstWhere(
          (i) => i.id == produceId,
          orElse: () => inventory.allItems.first,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              item.getName(lang),
              style: AppTypography.headlineSmall(isDark: isDark),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.document_scanner_rounded, color: AppColors.primary),
                tooltip: AppStrings.get('ai_scan_camera', lang),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AiFreshnessScannerScreen(targetItem: item),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditProduceDialog(itemToEdit: item),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.spoilageRed),
                onPressed: () => _confirmDelete(context, ref, item.id, lang),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'produce_emoji_${item.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(item.emoji, style: const TextStyle(fontSize: 40)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.getName(lang),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.category.getLocalizedName(lang)} • ${item.shelfLifeDays} ${AppStrings.get('days_shelf_life', lang)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FreshnessBadge(
                              score: item.freshnessScore,
                              lang: lang,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: AppStrings.get('selling_price', lang),
                        value: '${item.sellingPrice.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                        caption: '${lang == 'ar' ? 'لكل' : 'per'} ${item.unit.getLocalized(lang)}',
                        icon: Icons.sell_rounded,
                        color: AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: AppStrings.get('cost_price', lang),
                        value: '${item.costPrice.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                        caption: '${lang == 'ar' ? 'ربح' : 'Margin'} ${item.profitMargin.toStringAsFixed(0)}%',
                        icon: Icons.receipt_long_rounded,
                        color: AppColors.secondary,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: AppStrings.get('available_qty', lang),
                        value: item.currentStock.toStringAsFixed(item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1),
                        caption: item.unit.getLocalized(lang),
                        icon: Icons.inventory_rounded,
                        color: item.isLowStock ? AppColors.spoilageRed : AppColors.primary,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Wholesale vs Retail Price Fluctuation Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
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
                                AppStrings.get('price_fluctuation', lang),
                                style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                              ),
                              Text(
                                AppStrings.get('market_comparison', lang),
                                style: AppTypography.bodySmall(isDark: isDark),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              lang == 'ar'
                                  ? 'سوق الجملة: ${item.wholesaleMarketPrice} ر.س'
                                  : 'Wholesale: ${item.wholesaleMarketPrice} SAR',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: isDark ? Colors.white10 : AppColors.borderLight,
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: const FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              // Retail line
                              LineChartBarData(
                                spots: List.generate(
                                  item.priceHistory.length,
                                  (i) => FlSpot(i.toDouble(), item.priceHistory[i].retailPrice),
                                ),
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                              ),
                              // Wholesale line
                              LineChartBarData(
                                spots: List.generate(
                                  item.priceHistory.length,
                                  (i) => FlSpot(i.toDouble(), item.priceHistory[i].wholesalePrice),
                                ),
                                isCurved: true,
                                color: AppColors.secondary,
                                barWidth: 2,
                                dashArray: [4, 4],
                                isStrokeCapRound: true,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Batches Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.get('recent_batches', lang),
                      style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 15),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddBatchDialog(context, ref, item, lang),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(lang == 'ar' ? 'إضافة دفعة توريد' : 'Add Batch'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (item.batches.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        lang == 'ar' ? 'لا توجد دفعات مسجلة' : 'No batches logged',
                        style: AppTypography.bodySmall(isDark: isDark),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.batches.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final batch = item.batches[index];
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    batch.supplierName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${lang == 'ar' ? 'تكلفة التوريد:' : 'Cost:'} ${batch.costPerUnit} ${AppStrings.get('currency', lang)}',
                                    style: AppTypography.bodySmall(isDark: isDark),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${batch.quantityRemaining.toStringAsFixed(0)} / ${batch.quantityReceived.toStringAsFixed(0)}',
                                  style: AppTypography.numberSmall(isDark: isDark).copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  item.unit.getLocalized(lang),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),

                // Record Waste for this Item Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => RecordWasteDialog(preselectedProduceId: item.id),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.spoilageLight,
                      foregroundColor: AppColors.spoilageRed,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded),
                    label: Text(
                      AppStrings.get('record_waste', lang),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String caption,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTypography.numberMedium(isDark: isDark).copyWith(fontSize: 14),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id, String lang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'ar' ? 'حذف الصنف؟' : 'Delete Produce?'),
        content: Text(
          lang == 'ar'
              ? 'هل أنت متأكد من حذف هذا الصنف من سجل المخزون نهائياً؟'
              : 'Are you sure you want to permanently remove this produce item?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.spoilageRed),
            onPressed: () {
              ref.read(inventoryNotifierProvider.notifier).deleteProduce(id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: Text(lang == 'ar' ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddBatchDialog(BuildContext context, WidgetRef ref, dynamic item, String lang) {
    final qtyController = TextEditingController();
    final costController = TextEditingController(text: item.costPrice.toString());
    final supplierController = TextEditingController(text: 'سوق الجملة المركزي');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'ar' ? 'توريد دفعة جديدة' : 'Add Receiving Batch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: supplierController,
              decoration: InputDecoration(
                labelText: AppStrings.get('supplier', lang),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '${lang == 'ar' ? 'الكمية المستلمة' : 'Qty'} (${item.unit.getLocalized(lang)})',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: AppStrings.get('cost_price', lang),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final qty = double.tryParse(qtyController.text) ?? 0.0;
              final cost = double.tryParse(costController.text) ?? item.costPrice;
              if (qty > 0) {
                final newBatch = BatchItem(
                  id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                  receivedDate: DateTime.now(),
                  quantityReceived: qty,
                  quantityRemaining: qty,
                  supplierName: supplierController.text.trim().isEmpty
                      ? 'مورد محلي'
                      : supplierController.text.trim(),
                  costPerUnit: cost,
                );
                ref.read(inventoryNotifierProvider.notifier).addBatch(item.id, newBatch);
              }
              Navigator.pop(ctx);
            },
            child: Text(lang == 'ar' ? 'تأكيد الاستلام' : 'Confirm Inflow', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
