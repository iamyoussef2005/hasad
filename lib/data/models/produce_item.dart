import 'produce_category.dart';
import 'batch_item.dart';
import 'price_point.dart';

class ProduceItem {
  final String id;
  final String nameAr;
  final String nameEn;
  final ProduceCategory category;
  final ProduceUnit unit;
  final double currentStock;
  final double minStockThreshold;
  final double costPrice;
  final double sellingPrice;
  final double wholesaleMarketPrice;
  final int shelfLifeDays;
  final double freshnessScore; // 0.0 to 1.0
  final String emoji;
  final String primaryColorHex;
  final List<BatchItem> batches;
  final List<PricePoint> priceHistory;
  final bool isFeatured;
  final double? originalPrice;
  final bool isMarkdownActive;
  final double discountPercentage;
  final DateTime? lastAiInspectionDate;

  const ProduceItem({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStockThreshold,
    required this.costPrice,
    required this.sellingPrice,
    required this.wholesaleMarketPrice,
    required this.shelfLifeDays,
    required this.freshnessScore,
    required this.emoji,
    required this.primaryColorHex,
    this.batches = const [],
    this.priceHistory = const [],
    this.isFeatured = false,
    this.originalPrice,
    this.isMarkdownActive = false,
    this.discountPercentage = 0.0,
    this.lastAiInspectionDate,
  });

  bool get isLowStock => currentStock <= minStockThreshold;
  double get totalValue => currentStock * costPrice;
  double get profitMargin => sellingPrice > 0 ? ((sellingPrice - costPrice) / sellingPrice) * 100 : 0.0;
  bool get hasRescueDiscount => isMarkdownActive && discountPercentage > 0;

  String getName(String lang) => lang == 'ar' ? nameAr : nameEn;

  ProduceItem copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    ProduceCategory? category,
    ProduceUnit? unit,
    double? currentStock,
    double? minStockThreshold,
    double? costPrice,
    double? sellingPrice,
    double? wholesaleMarketPrice,
    int? shelfLifeDays,
    double? freshnessScore,
    String? emoji,
    String? primaryColorHex,
    List<BatchItem>? batches,
    List<PricePoint>? priceHistory,
    bool? isFeatured,
    double? originalPrice,
    bool? isMarkdownActive,
    double? discountPercentage,
    DateTime? lastAiInspectionDate,
  }) {
    return ProduceItem(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      wholesaleMarketPrice: wholesaleMarketPrice ?? this.wholesaleMarketPrice,
      shelfLifeDays: shelfLifeDays ?? this.shelfLifeDays,
      freshnessScore: freshnessScore ?? this.freshnessScore,
      emoji: emoji ?? this.emoji,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      batches: batches ?? this.batches,
      priceHistory: priceHistory ?? this.priceHistory,
      isFeatured: isFeatured ?? this.isFeatured,
      originalPrice: originalPrice ?? this.originalPrice,
      isMarkdownActive: isMarkdownActive ?? this.isMarkdownActive,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      lastAiInspectionDate: lastAiInspectionDate ?? this.lastAiInspectionDate,
    );
  }
}
