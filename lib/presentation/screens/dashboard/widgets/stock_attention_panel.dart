import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_locale_provider.dart';
import '../../../../data/models/produce_item.dart';
import '../../../../domain/services/stock_attention_service.dart';
import '../../inventory/produce_details_screen.dart';

class StockAttentionPanel extends StatefulWidget {
  final List<ProduceItem> items;
  final String lang;
  const StockAttentionPanel({
    super.key,
    required this.items,
    required this.lang,
  });

  @override
  State<StockAttentionPanel> createState() => _StockAttentionPanelState();
}

class _StockAttentionPanelState extends State<StockAttentionPanel> {
  AttentionFilter _filter = AttentionFilter.all;
  String _query = '';
  bool _expanded = false;
  static const _service = StockAttentionService();
  bool get _ar => widget.lang == 'ar';
  String _t(String ar, String en) => _ar ? ar : en;

  Future<void> _copyOrder() async {
    final entries = _service.evaluate(
      widget.items,
      filter: AttentionFilter.restock,
    );
    final lines = entries.map(
      (e) =>
          '${e.item.getName(widget.lang)}: ${e.suggestedOrder.toStringAsFixed(1)} ${e.item.unit.getLocalized(widget.lang)}',
    );
    try {
      await Clipboard.setData(
        ClipboardData(
          text: [
            _t('قائمة شراء مقترحة — حصاد', 'Suggested purchase list — Hasad'),
            _t(
              'الكميات تستهدف ضعف الحد الأدنى للمخزون.',
              'Quantities target twice the minimum stock threshold.',
            ),
            ...lines,
          ].join('\n'),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_t('تم نسخ قائمة الشراء', 'Purchase list copied')),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('تعذر النسخ، حاول مجدداً', 'Could not copy. Please try again.'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all = _service.evaluate(widget.items);
    final entries = _service.evaluate(
      widget.items,
      filter: _filter,
      query: _query,
    );
    final risk = all.fold(0.0, (sum, e) => sum + e.valueAtRisk);
    final restockCount = all.where((e) => e.needsRestock).length;
    final visible = _expanded ? entries : entries.take(3).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _t('مركز المتابعة', 'Attention center'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${all.length} ${_t('أصناف', 'items')}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _t(
                'الأولوية للنافد، ثم منخفض النضارة، ثم نقص المخزون.',
                'Out of stock first, then freshness risk, then low stock.',
              ),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _metric(
                  context,
                  Icons.shield_outlined,
                  '${risk.toStringAsFixed(0)} ${AppStrings.get('currency', widget.lang)}',
                  _t(
                    'قيمة مخزون يحتاج فحص نضارة',
                    'Stock value needing freshness review',
                  ),
                ),
                _metric(
                  context,
                  Icons.shopping_basket_outlined,
                  '$restockCount',
                  _t('أصناف لإعادة الطلب', 'Items to reorder'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => setState(() {
                _query = value;
                _expanded = false;
              }),
              decoration: InputDecoration(
                hintText: _t('ابحث ضمن التنبيهات...', 'Search alerts...'),
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final filter in AttentionFilter.values)
                  ChoiceChip(
                    label: Text(switch (filter) {
                      AttentionFilter.all => _t('الكل', 'All'),
                      AttentionFilter.freshness => _t(
                        'فحص النضارة',
                        'Freshness',
                      ),
                      AttentionFilter.restock => _t('إعادة الطلب', 'Restock'),
                    }),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() {
                      _filter = filter;
                      _expanded = false;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        all.isEmpty
                            ? Icons.task_alt_rounded
                            : Icons.search_off_rounded,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        all.isEmpty
                            ? _t(
                                'لا توجد أصناف تحتاج متابعة',
                                'No items need attention',
                              )
                            : _t(
                                'لا توجد نتائج لهذا الفلتر',
                                'No matching alerts',
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            for (final entry in visible) ...[
              const Divider(height: 1),
              _entry(context, entry),
            ],
            if (entries.length > 3)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded
                      ? _t('عرض أقل', 'Show less')
                      : _t(
                          'عرض الكل (${entries.length})',
                          'Show all (${entries.length})',
                        ),
                ),
              ),
            const Divider(height: 24),
            OutlinedButton.icon(
              onPressed: restockCount == 0 ? null : _copyOrder,
              icon: const Icon(Icons.copy_all_outlined, size: 18),
              label: Text(
                _t('نسخ قائمة الشراء المقترحة', 'Copy suggested purchase list'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context,
    IconData icon,
    String value,
    String label,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _entry(BuildContext context, StockAttention entry) {
    final item = entry.item;
    final color = entry.isOutOfStock || entry.needsFreshnessReview
        ? Theme.of(context).colorScheme.error
        : const Color(0xFFB6680A);
    final reasons = [
      if (entry.isOutOfStock)
        _t('نفد المخزون', 'Out of stock')
      else if (entry.needsRestock)
        _t('مخزون منخفض', 'Low stock'),
      if (entry.needsFreshnessReview)
        _t(
          'نضارة ${(item.freshnessScore * 100).round()}٪',
          'Freshness ${(item.freshnessScore * 100).round()}%',
        ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          leading: Icon(
            item.category.icon,
            size: 22,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          title: Text(
            item.getName(widget.lang),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            '${reasons.join(' • ')}\n${item.currentStock.toStringAsFixed(1)} ${item.unit.getLocalized(widget.lang)}',
            style: TextStyle(color: color, height: 1.6),
          ),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProduceDetailsScreen(produceId: item.id),
            ),
          ),
        ),
      ),
    );
  }
}
