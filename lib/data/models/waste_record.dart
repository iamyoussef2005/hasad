enum WasteReason {
  wiltingAndRot,
  transitDamage,
  poorCooling,
  pestContamination,
  other;

  String getLocalized(String lang) {
    switch (this) {
      case WasteReason.wiltingAndRot:
        return lang == 'ar' ? 'ذبول وتلف طبيعي' : 'Natural wilting & decay';
      case WasteReason.transitDamage:
        return lang == 'ar' ? 'أضرار النقل والتفريغ' : 'Transit & handling damage';
      case WasteReason.poorCooling:
        return lang == 'ar' ? 'عطل أو سوء تبريد' : 'Cooling / Storage issue';
      case WasteReason.pestContamination:
        return lang == 'ar' ? 'إصابة أو حشرات' : 'Pest damage';
      case WasteReason.other:
        return lang == 'ar' ? 'أسباب أخرى' : 'Other';
    }
  }
}

class WasteRecord {
  final String id;
  final String produceId;
  final String produceNameAr;
  final String produceNameEn;
  final double quantityWasted;
  final double financialLoss;
  final WasteReason reason;
  final DateTime date;
  final String notes;

  const WasteRecord({
    required this.id,
    required this.produceId,
    required this.produceNameAr,
    required this.produceNameEn,
    required this.quantityWasted,
    required this.financialLoss,
    required this.reason,
    required this.date,
    this.notes = '',
  });
}
