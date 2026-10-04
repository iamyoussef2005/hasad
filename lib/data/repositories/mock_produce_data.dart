import '../models/produce_item.dart';
import '../models/produce_category.dart';
import '../models/batch_item.dart';
import '../models/price_point.dart';
import '../models/waste_record.dart';

class MockProduceData {
  static List<ProduceItem> getInitialProduce() {
    final now = DateTime.now();

    return [
      ProduceItem(
        id: 'p_1',
        nameAr: 'طماطم بلدي فاخرة',
        nameEn: 'Vine Fresh Tomatoes',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.kg,
        currentStock: 145.0,
        minStockThreshold: 30.0,
        costPrice: 3.5,
        sellingPrice: 5.5,
        wholesaleMarketPrice: 3.2,
        shelfLifeDays: 6,
        freshnessScore: 0.88,
        emoji: '🍅',
        primaryColorHex: '#EF4444',
        isFeatured: true,
        batches: [
          BatchItem(
            id: 'b_101',
            receivedDate: now.subtract(const Duration(days: 1)),
            quantityReceived: 100.0,
            quantityRemaining: 85.0,
            supplierName: 'مزارع الخرج الوطنية',
            costPerUnit: 3.4,
          ),
          BatchItem(
            id: 'b_102',
            receivedDate: now.subtract(const Duration(hours: 10)),
            quantityReceived: 60.0,
            quantityRemaining: 60.0,
            supplierName: 'سوق العزيزية للجملة',
            costPerUnit: 3.6,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 3.5, baseSell: 5.5),
      ),
      ProduceItem(
        id: 'p_2',
        nameAr: 'خيار محمي درجة أولى',
        nameEn: 'Greenhouse Cucumbers',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.kg,
        currentStock: 18.0, // Low stock trigger
        minStockThreshold: 25.0,
        costPrice: 2.8,
        sellingPrice: 4.5,
        wholesaleMarketPrice: 3.0,
        shelfLifeDays: 5,
        freshnessScore: 0.92,
        emoji: '🥒',
        primaryColorHex: '#10B981',
        batches: [
          BatchItem(
            id: 'b_201',
            receivedDate: now.subtract(const Duration(days: 1)),
            quantityReceived: 50.0,
            quantityRemaining: 18.0,
            supplierName: 'مزارع القصيم الخضراء',
            costPerUnit: 2.8,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 2.8, baseSell: 4.5),
      ),
      ProduceItem(
        id: 'p_3',
        nameAr: 'خس روماني مقرمش',
        nameEn: 'Romaine Lettuce',
        category: ProduceCategory.leafyGreens,
        unit: ProduceUnit.bundle,
        currentStock: 45.0,
        minStockThreshold: 15.0,
        costPrice: 1.8,
        sellingPrice: 3.0,
        wholesaleMarketPrice: 2.0,
        shelfLifeDays: 4,
        freshnessScore: 0.42, // Critical freshness, triggers AI markdown rescue proposal
        emoji: '🥬',
        primaryColorHex: '#22C55E',
        batches: [
          BatchItem(
            id: 'b_301',
            receivedDate: now.subtract(const Duration(days: 2)),
            quantityReceived: 80.0,
            quantityRemaining: 45.0,
            supplierName: 'مزارع تبوك الزراعية',
            costPerUnit: 1.8,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 1.8, baseSell: 3.0),
      ),
      ProduceItem(
        id: 'p_4',
        nameAr: 'نعناع حساوي طازج',
        nameEn: 'Fresh Mint Herbs',
        category: ProduceCategory.herbs,
        unit: ProduceUnit.bundle,
        currentStock: 60.0,
        minStockThreshold: 20.0,
        costPrice: 0.75,
        sellingPrice: 1.5,
        wholesaleMarketPrice: 0.8,
        shelfLifeDays: 3,
        freshnessScore: 0.95,
        emoji: '🌿',
        primaryColorHex: '#059669',
        batches: [
          BatchItem(
            id: 'b_401',
            receivedDate: now.subtract(const Duration(hours: 6)),
            quantityReceived: 75.0,
            quantityRemaining: 60.0,
            supplierName: 'واحة الأحساء',
            costPerUnit: 0.75,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 0.75, baseSell: 1.5),
      ),
      ProduceItem(
        id: 'p_5',
        nameAr: 'ليمون بنزهير بلدي',
        nameEn: 'Local Yellow Lemons',
        category: ProduceCategory.citrus,
        unit: ProduceUnit.kg,
        currentStock: 85.0,
        minStockThreshold: 20.0,
        costPrice: 4.0,
        sellingPrice: 7.0,
        wholesaleMarketPrice: 4.2,
        shelfLifeDays: 14,
        freshnessScore: 0.90,
        emoji: '🍋',
        primaryColorHex: '#FBBF24',
        batches: [
          BatchItem(
            id: 'b_501',
            receivedDate: now.subtract(const Duration(days: 3)),
            quantityReceived: 120.0,
            quantityRemaining: 85.0,
            supplierName: 'مزارع نجران للحمضيات',
            costPerUnit: 4.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 4.0, baseSell: 7.0),
      ),
      ProduceItem(
        id: 'p_6',
        nameAr: 'برتقال عصير فالنسيا',
        nameEn: 'Valencia Juice Oranges',
        category: ProduceCategory.citrus,
        unit: ProduceUnit.box,
        currentStock: 24.0,
        minStockThreshold: 10.0,
        costPrice: 28.0,
        sellingPrice: 42.0,
        wholesaleMarketPrice: 30.0,
        shelfLifeDays: 18,
        freshnessScore: 0.85,
        emoji: '🍊',
        primaryColorHex: '#F97316',
        batches: [
          BatchItem(
            id: 'b_601',
            receivedDate: now.subtract(const Duration(days: 4)),
            quantityReceived: 40.0,
            quantityRemaining: 24.0,
            supplierName: 'شركة الوادي الأخضر',
            costPerUnit: 28.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 28.0, baseSell: 42.0),
      ),
      ProduceItem(
        id: 'p_7',
        nameAr: 'فراولة معلقة فاخرة',
        nameEn: 'Sweet Hydroponic Strawberries',
        category: ProduceCategory.fruits,
        unit: ProduceUnit.box,
        currentStock: 8.0, // Low stock!
        minStockThreshold: 12.0,
        costPrice: 12.0,
        sellingPrice: 18.0,
        wholesaleMarketPrice: 13.0,
        shelfLifeDays: 3,
        freshnessScore: 0.55, // Wilting quickly, needs clearance
        emoji: '🍓',
        primaryColorHex: '#E11D48',
        batches: [
          BatchItem(
            id: 'b_701',
            receivedDate: now.subtract(const Duration(days: 2)),
            quantityReceived: 30.0,
            quantityRemaining: 8.0,
            supplierName: 'مزارع استرا',
            costPerUnit: 12.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 12.0, baseSell: 18.0),
      ),
      ProduceItem(
        id: 'p_8',
        nameAr: 'بطاطا حائل ذهبية',
        nameEn: 'Hail Golden Potatoes',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.box,
        currentStock: 65.0,
        minStockThreshold: 20.0,
        costPrice: 15.0,
        sellingPrice: 24.0,
        wholesaleMarketPrice: 16.0,
        shelfLifeDays: 35,
        freshnessScore: 0.98,
        emoji: '🥔',
        primaryColorHex: '#D97706',
        batches: [
          BatchItem(
            id: 'b_801',
            receivedDate: now.subtract(const Duration(days: 5)),
            quantityReceived: 100.0,
            quantityRemaining: 65.0,
            supplierName: 'شركة التنمية الزراعية',
            costPerUnit: 15.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 15.0, baseSell: 24.0),
      ),
      ProduceItem(
        id: 'p_9',
        nameAr: 'فلفل رومي ملون',
        nameEn: 'Colorful Bell Peppers',
        category: ProduceCategory.vegetables,
        unit: ProduceUnit.kg,
        currentStock: 35.0,
        minStockThreshold: 15.0,
        costPrice: 6.0,
        sellingPrice: 9.5,
        wholesaleMarketPrice: 6.5,
        shelfLifeDays: 8,
        freshnessScore: 0.82,
        emoji: '🫑',
        primaryColorHex: '#16A34A',
        batches: [
          BatchItem(
            id: 'b_901',
            receivedDate: now.subtract(const Duration(days: 2)),
            quantityReceived: 50.0,
            quantityRemaining: 35.0,
            supplierName: 'مزارع الجوف الحديثة',
            costPerUnit: 6.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 6.0, baseSell: 9.5),
      ),
      ProduceItem(
        id: 'p_10',
        nameAr: 'بطيخ أحمر صيفي حلو',
        nameEn: 'Sweet Red Watermelon',
        category: ProduceCategory.fruits,
        unit: ProduceUnit.piece,
        currentStock: 28.0,
        minStockThreshold: 10.0,
        costPrice: 11.0,
        sellingPrice: 19.0,
        wholesaleMarketPrice: 12.0,
        shelfLifeDays: 12,
        freshnessScore: 0.91,
        emoji: '🍉',
        primaryColorHex: '#DC2626',
        batches: [
          BatchItem(
            id: 'b_1001',
            receivedDate: now.subtract(const Duration(days: 2)),
            quantityReceived: 50.0,
            quantityRemaining: 28.0,
            supplierName: 'مزارع وادي الدواسر',
            costPerUnit: 11.0,
          ),
        ],
        priceHistory: _generatePriceHistory(baseCost: 11.0, baseSell: 19.0),
      ),
    ];
  }

  static List<WasteRecord> getInitialWasteRecords() {
    final now = DateTime.now();
    return [
      WasteRecord(
        id: 'w_1',
        produceId: 'p_3',
        produceNameAr: 'خس روماني مقرمش',
        produceNameEn: 'Romaine Lettuce',
        quantityWasted: 6.0,
        financialLoss: 10.8, // 6 * 1.8
        reason: WasteReason.wiltingAndRot,
        date: now.subtract(const Duration(hours: 3)),
        notes: 'ذبول في الأطراف الخارجية بسبب حرارة العرض',
      ),
      WasteRecord(
        id: 'w_2',
        produceId: 'p_7',
        produceNameAr: 'فراولة معلقة فاخرة',
        produceNameEn: 'Sweet Hydroponic Strawberries',
        quantityWasted: 3.0,
        financialLoss: 36.0, // 3 * 12.0
        reason: WasteReason.poorCooling,
        date: now.subtract(const Duration(hours: 8)),
        notes: 'تأثر بالرطوبة داخل الثلاجة السفلية',
      ),
      WasteRecord(
        id: 'w_3',
        produceId: 'p_1',
        produceNameAr: 'طماطم بلدي فاخرة',
        produceNameEn: 'Vine Fresh Tomatoes',
        quantityWasted: 8.5,
        financialLoss: 29.75, // 8.5 * 3.5
        reason: WasteReason.transitDamage,
        date: now.subtract(const Duration(days: 1)),
        notes: 'حبات مهروسة أسفل الصندوق أثناء التنزيل من الشاحنة',
      ),
    ];
  }

  static List<PricePoint> _generatePriceHistory({
    required double baseCost,
    required double baseSell,
  }) {
    final now = DateTime.now();
    final points = <PricePoint>[];
    final costOffsets = [-0.4, -0.2, 0.1, -0.1, 0.3, 0.0];
    final sellOffsets = [-0.5, 0.0, 0.2, 0.0, 0.4, 0.0];

    for (int i = 5; i >= 0; i--) {
      points.add(
        PricePoint(
          date: now.subtract(Duration(days: i * 5)),
          wholesalePrice: (baseCost + costOffsets[5 - i]).clamp(0.5, 100.0),
          retailPrice: (baseSell + sellOffsets[5 - i]).clamp(1.0, 150.0),
        ),
      );
    }
    return points;
  }
}
