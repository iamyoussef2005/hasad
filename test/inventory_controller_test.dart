import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:greenstock/data/models/produce_item.dart';
import 'package:greenstock/data/models/produce_category.dart';
import 'package:greenstock/data/models/waste_record.dart';
import 'package:greenstock/presentation/controllers/waste_controller.dart';
import 'package:greenstock/presentation/controllers/pos_controller.dart';

void main() {
  group('Produce Inventory & Business Logic Tests', () {
    test('Profit margin calculation is mathematically accurate', () {
      const item = ProduceItem(
        id: 'test_1',
        nameAr: 'طماطم',
        nameEn: 'Tomatoes',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.kg,
        currentStock: 100,
        minStockThreshold: 20,
        costPrice: 4.0,
        sellingPrice: 5.0,
        wholesaleMarketPrice: 3.8,
        shelfLifeDays: 5,
        freshnessScore: 0.9,
        emoji: '🍅',
        primaryColorHex: '#EF4444',
      );

      // Profit margin: ((5 - 4) / 5) * 100 = 20%
      expect(item.profitMargin, equals(20.0));
      expect(item.totalValue, equals(400.0));
      expect(item.isLowStock, isFalse);
    });

    test('Low stock threshold triggers alert', () {
      const item = ProduceItem(
        id: 'test_low',
        nameAr: 'خيار',
        nameEn: 'Cucumbers',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.kg,
        currentStock: 12,
        minStockThreshold: 15,
        costPrice: 2.0,
        sellingPrice: 3.5,
        wholesaleMarketPrice: 2.1,
        shelfLifeDays: 4,
        freshnessScore: 0.85,
        emoji: '🥒',
        primaryColorHex: '#10B981',
      );

      expect(item.isLowStock, isTrue);
    });

    test('POS scale calculator and cart accumulation', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const item = ProduceItem(
        id: 'test_scale',
        nameAr: 'تفاح',
        nameEn: 'Apples',
        category: ProduceCategory.fruits,
        unit: ProduceUnit.kg,
        currentStock: 50,
        minStockThreshold: 10,
        costPrice: 5.0,
        sellingPrice: 8.0,
        wholesaleMarketPrice: 5.2,
        shelfLifeDays: 14,
        freshnessScore: 0.95,
        emoji: '🍎',
        primaryColorHex: '#DC2626',
      );

      final notifier = container.read(posNotifierProvider.notifier);
      notifier.selectProduce(item);
      notifier.updateWeight(2.5); // 2.5 kg * 8.0 = 20.0 SAR
      notifier.addToCart();

      final state = container.read(posNotifierProvider);
      expect(state.cart.length, equals(1));
      expect(state.cart.first.quantity, equals(2.5));
      expect(state.cart.first.totalPrice, equals(20.0));
      expect(state.cartTotal, equals(20.0));
    });

    test('Waste recording calculates financial loss correctly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final wasteNotifier = container.read(wasteNotifierProvider.notifier);

      final record = WasteRecord(
        id: 'w_test_1',
        produceId: 'p_1',
        produceNameAr: 'طماطم بلدي فاخرة',
        produceNameEn: 'Vine Fresh Tomatoes',
        quantityWasted: 10.0,
        financialLoss: 35.0,
        reason: WasteReason.wiltingAndRot,
        date: DateTime.now(),
      );

      await wasteNotifier.recordWaste(record);

      final wasteState = container.read(wasteNotifierProvider).value!;
      expect(wasteState.records.any((r) => r.id == 'w_test_1'), isTrue);
      expect(wasteState.totalFinancialLoss, greaterThanOrEqualTo(35.0));
    });
  });
}
