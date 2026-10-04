enum MarkdownUrgency {
  low,
  medium,
  critical;

  String getLocalized(String lang) {
    switch (this) {
      case MarkdownUrgency.critical:
        return lang == 'ar' ? 'إنقاذ عاجل' : 'Critical Rescue';
      case MarkdownUrgency.medium:
        return lang == 'ar' ? 'تخفيض سريع' : 'Fast Markdown';
      case MarkdownUrgency.low:
        return lang == 'ar' ? 'تحفيز مبيعات' : 'Velocity Promo';
    }
  }
}

class MarkdownProposal {
  final String produceId;
  final String produceNameAr;
  final String produceNameEn;
  final double currentSellingPrice;
  final double recommendedPrice;
  final double discountPercent;
  final MarkdownUrgency urgency;
  final String reasonAr;
  final String reasonEn;
  final double potentialRecoveredRevenue;
  final double projectedWasteLoss;
  final int estimatedDaysToExpiry;
  final double currentFreshnessScore;
  final double currentStock;

  const MarkdownProposal({
    required this.produceId,
    required this.produceNameAr,
    required this.produceNameEn,
    required this.currentSellingPrice,
    required this.recommendedPrice,
    required this.discountPercent,
    required this.urgency,
    required this.reasonAr,
    required this.reasonEn,
    required this.potentialRecoveredRevenue,
    required this.projectedWasteLoss,
    required this.estimatedDaysToExpiry,
    required this.currentFreshnessScore,
    required this.currentStock,
  });

  String getName(String lang) => lang == 'ar' ? produceNameAr : produceNameEn;
  String getReason(String lang) => lang == 'ar' ? reasonAr : reasonEn;
}
