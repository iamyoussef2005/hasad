import '../../data/models/produce_item.dart';

enum AttentionFilter { all, freshness, restock }

/// Transparent inventory rules; freshness is a recorded score, not an expiry date.
class StockAttention {
  final ProduceItem item;
  const StockAttention(this.item);

  bool get needsFreshnessReview =>
      item.currentStock > 0 && item.freshnessScore < 0.5;
  bool get needsRestock => item.isLowStock;
  bool get isOutOfStock => item.currentStock <= 0;
  double get valueAtRisk => needsFreshnessReview ? item.totalValue : 0;

  // A target of twice the minimum is a purchasing suggestion, not a demand forecast.
  double get suggestedOrder => (item.minStockThreshold * 2 - item.currentStock)
      .clamp(0.0, double.infinity);

  int get priority => isOutOfStock ? 0 : (needsFreshnessReview ? 1 : 2);
}

class StockAttentionService {
  const StockAttentionService();

  List<StockAttention> evaluate(
    Iterable<ProduceItem> items, {
    AttentionFilter filter = AttentionFilter.all,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    final result = items.map(StockAttention.new).where((entry) {
      final matchesFilter = switch (filter) {
        AttentionFilter.all => entry.needsRestock || entry.needsFreshnessReview,
        AttentionFilter.freshness => entry.needsFreshnessReview,
        AttentionFilter.restock => entry.needsRestock,
      };
      return matchesFilter &&
          (q.isEmpty ||
              entry.item.nameAr.toLowerCase().contains(q) ||
              entry.item.nameEn.toLowerCase().contains(q));
    }).toList();
    result.sort((a, b) {
      final urgency = a.priority.compareTo(b.priority);
      if (urgency != 0) return urgency;
      final exposure = b.valueAtRisk.compareTo(a.valueAtRisk);
      return exposure != 0 ? exposure : a.item.id.compareTo(b.item.id);
    });
    return List.unmodifiable(result);
  }
}
