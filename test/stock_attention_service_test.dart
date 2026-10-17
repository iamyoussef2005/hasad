import 'package:flutter_test/flutter_test.dart';
import 'package:greenstock/data/repositories/mock_produce_data.dart';
import 'package:greenstock/domain/services/stock_attention_service.dart';

void main() {
  const service = StockAttentionService();
  final base = MockProduceData.getInitialProduce().first;

  test(
    'out of stock precedes freshness risk, sorted by financial exposure',
    () {
      final empty = base.copyWith(
        id: 'empty',
        currentStock: 0,
        freshnessScore: 0.1,
      );
      final risk = base.copyWith(
        id: 'risk',
        currentStock: 100,
        minStockThreshold: 1,
        freshnessScore: 0.2,
      );
      final smallerRisk = risk.copyWith(id: 'smaller', currentStock: 50);
      final low = base.copyWith(
        id: 'low',
        currentStock: 1,
        minStockThreshold: 2,
        freshnessScore: 0.9,
      );
      final healthy = base.copyWith(
        id: 'healthy',
        currentStock: 100,
        minStockThreshold: 1,
        freshnessScore: 0.9,
      );
      final result = service.evaluate([low, healthy, smallerRisk, risk, empty]);
      expect(result.map((e) => e.item.id), ['empty', 'risk', 'smaller', 'low']);
      expect(result.first.valueAtRisk, 0);
      expect(result[1].valueAtRisk, 100 * risk.costPrice);
    },
  );

  test('freshness boundary, combined risks, and restocking targets', () {
    final boundary = base.copyWith(
      currentStock: 10,
      minStockThreshold: 10,
      freshnessScore: 0.5,
    );
    final result = service.evaluate([boundary]);
    expect(result.single.needsFreshnessReview, isFalse);
    expect(result.single.suggestedOrder, 10);
    final both = boundary.copyWith(freshnessScore: 0.49);
    expect(service.evaluate([both]).length, 1);
    expect(
      service.evaluate([both], filter: AttentionFilter.freshness).length,
      1,
    );
    expect(service.evaluate([both], filter: AttentionFilter.restock).length, 1);
  });

  test(
    'search supports Arabic and case-insensitive English, and empty inventory',
    () {
      final item = base.copyWith(
        nameAr: 'تفاح',
        nameEn: 'Apples',
        currentStock: 0,
      );
      expect(service.evaluate([item], query: ' APpLe ').length, 1);
      expect(service.evaluate([item], query: 'تفاح').length, 1);
      expect(service.evaluate([item], query: 'orange'), isEmpty);
      expect(service.evaluate([]), isEmpty);
      expect(
        StockAttention(
          item.copyWith(currentStock: 100, minStockThreshold: 1),
        ).suggestedOrder,
        0,
      );
    },
  );
}
