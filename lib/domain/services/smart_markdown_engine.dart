import '../../data/models/produce_item.dart';
import '../../data/models/markdown_proposal.dart';

class SmartMarkdownEngine {
  /// Evaluates produce inventory items and generates smart dynamic markdown proposals
  /// aimed at preventing food waste and recovering operational revenues.
  static List<MarkdownProposal> generateProposals(List<ProduceItem> items) {
    final proposals = <MarkdownProposal>[];

    for (final item in items) {
      if (item.currentStock <= 0) continue;

      // Don't propose if already actively marked down
      if (item.isMarkdownActive) continue;

      final proposal = evaluateItem(item);
      if (proposal != null) {
        proposals.add(proposal);
      }
    }

    // Sort by urgency (critical first), then by projected waste loss descending
    proposals.sort((a, b) {
      final urgencyCompare = b.urgency.index.compareTo(a.urgency.index);
      if (urgencyCompare != 0) return urgencyCompare;
      return b.projectedWasteLoss.compareTo(a.projectedWasteLoss);
    });

    return proposals;
  }

  static MarkdownProposal? evaluateItem(ProduceItem item) {
    final freshness = item.freshnessScore;
    double discountPercent = 0.0;
    MarkdownUrgency urgency = MarkdownUrgency.low;
    String reasonAr = '';
    String reasonEn = '';
    int daysToExpiry = 1;

    if (freshness < 0.45) {
      // Critical stage: perishable product will spoil within 24-36 hours
      urgency = MarkdownUrgency.critical;
      discountPercent = 40.0;
      daysToExpiry = 1;
      reasonAr = 'المنتج يقترب من الذبول الشديد خلال 24 ساعة، خفّض سعره بنسبة 40% لتصريفه فوراً كعرض إنقاذ بدلاً من خسارته بالكامل كنفايات.';
      reasonEn = 'Approaching severe wilting within 24 hours. Cut price by 40% as a rescue sale to prevent 100% spoilage loss.';
    } else if (freshness < 0.65) {
      // Medium stage: freshness declining, needs prompt sell-through
      urgency = MarkdownUrgency.medium;
      discountPercent = 25.0;
      daysToExpiry = (item.shelfLifeDays * 0.35).clamp(1, 3).round();
      reasonAr = 'انخفاض مؤشر النضارة إلى ${(freshness * 100).toInt()}%، خفّض السعر بنسبة 25% لتسريع وتيرة البيع وحماية رأس المال.';
      reasonEn = 'Freshness index dropped to ${(freshness * 100).toInt()}%. A 25% discount is recommended to accelerate customer checkout.';
    } else if (freshness < 0.78 && item.currentStock > (item.minStockThreshold * 1.8)) {
      // Overstock velocity booster
      urgency = MarkdownUrgency.low;
      discountPercent = 15.0;
      daysToExpiry = (item.shelfLifeDays * 0.55).clamp(2, 5).round();
      reasonAr = 'كمية المخزون (${item.currentStock.toStringAsFixed(0)} ${item.unit.name}) مرتفعة مع تباطؤ الاستهلاك، يُوصى بتخفيض 15% لتنشيط الحركة.';
      reasonEn = 'Stock level (${item.currentStock.toStringAsFixed(0)} ${item.unit.name}) is high compared to shelf life. A 15% velocity promotion prevents stagnation.';
    } else {
      return null;
    }

    // Calculate discounted price (rounded to 2 decimal places)
    double discountedPrice = (item.sellingPrice * (1.0 - (discountPercent / 100.0)));
    discountedPrice = double.parse(discountedPrice.toStringAsFixed(2));

    // Floor safeguard: protect gross recovery
    final absoluteFloor = double.parse((item.costPrice * 0.70).toStringAsFixed(2));
    if (discountedPrice < absoluteFloor && urgency != MarkdownUrgency.critical) {
      discountedPrice = absoluteFloor;
      discountPercent = ((item.sellingPrice - discountedPrice) / item.sellingPrice) * 100.0;
      discountPercent = double.parse(discountPercent.toStringAsFixed(0));
    }

    final potentialRevenue = double.parse((item.currentStock * discountedPrice).toStringAsFixed(2));
    final projectedLoss = double.parse((item.currentStock * item.costPrice).toStringAsFixed(2));

    return MarkdownProposal(
      produceId: item.id,
      produceNameAr: item.nameAr,
      produceNameEn: item.nameEn,
      currentSellingPrice: item.sellingPrice,
      recommendedPrice: discountedPrice,
      discountPercent: discountPercent,
      urgency: urgency,
      reasonAr: reasonAr,
      reasonEn: reasonEn,
      potentialRecoveredRevenue: potentialRevenue,
      projectedWasteLoss: projectedLoss,
      estimatedDaysToExpiry: daysToExpiry,
      currentFreshnessScore: freshness,
      currentStock: item.currentStock,
    );
  }
}
