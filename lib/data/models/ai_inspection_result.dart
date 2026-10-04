enum AiDefectType {
  wilting,
  skinBrowning,
  fungalSpot,
  bruising,
  moistureLoss,
  optimal;

  String getLocalizedName(String lang) {
    switch (this) {
      case AiDefectType.wilting:
        return lang == 'ar' ? 'ذبول أوراق' : 'Leaf Wilting';
      case AiDefectType.skinBrowning:
        return lang == 'ar' ? 'تغير لون القشرة' : 'Skin Browning';
      case AiDefectType.fungalSpot:
        return lang == 'ar' ? 'بقع فطرية/عفن' : 'Fungal Spot / Mold';
      case AiDefectType.bruising:
        return lang == 'ar' ? 'كدمات ضغط' : 'Pressure Bruising';
      case AiDefectType.moistureLoss:
        return lang == 'ar' ? 'فقدان رطوبة وتجعد' : 'Moisture Loss / Wrinkling';
      case AiDefectType.optimal:
        return lang == 'ar' ? 'نضارة ممتازة' : 'Peak Freshness';
    }
  }
}

class AiDefectFinding {
  final AiDefectType type;
  final double severityPercent;
  final String locationTag;
  final String descriptionAr;
  final String descriptionEn;

  const AiDefectFinding({
    required this.type,
    required this.severityPercent,
    required this.locationTag,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  String getDescription(String lang) => lang == 'ar' ? descriptionAr : descriptionEn;
}

class AiInspectionResult {
  final String produceId;
  final String produceNameAr;
  final String produceNameEn;
  final DateTime timestamp;
  final double freshnessScore; // 0.0 to 1.0
  final double confidenceScore; // 0.0 to 1.0
  final List<AiDefectFinding> detectedDefects;
  final String recommendedActionAr;
  final String recommendedActionEn;
  final double suggestedDiscountPercent;
  final int estimatedRemainingShelfLifeHours;

  const AiInspectionResult({
    required this.produceId,
    required this.produceNameAr,
    required this.produceNameEn,
    required this.timestamp,
    required this.freshnessScore,
    required this.confidenceScore,
    required this.detectedDefects,
    required this.recommendedActionAr,
    required this.recommendedActionEn,
    required this.suggestedDiscountPercent,
    required this.estimatedRemainingShelfLifeHours,
  });

  String getAction(String lang) => lang == 'ar' ? recommendedActionAr : recommendedActionEn;
}
