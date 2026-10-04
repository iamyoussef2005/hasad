import '../../data/models/produce_item.dart';
import '../../data/models/ai_inspection_result.dart';

class AiScanPreset {
  final String id;
  final String titleAr;
  final String titleEn;
  final String emoji;
  final String produceCategory;
  final double simulatedFreshness;
  final String sampleConditionAr;
  final String sampleConditionEn;

  const AiScanPreset({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.emoji,
    required this.produceCategory,
    required this.simulatedFreshness,
    required this.sampleConditionAr,
    required this.sampleConditionEn,
  });
}

class AiVisionInspectionService {
  static const List<AiScanPreset> samplePresets = [
    AiScanPreset(
      id: 'preset_lettuce_wilted',
      titleAr: 'خس روماني (أوراق خارجية ذابلة)',
      titleEn: 'Romaine Lettuce (Outer leaf wilt)',
      emoji: '🥬',
      produceCategory: 'leafyGreens',
      simulatedFreshness: 0.45,
      sampleConditionAr: 'فقدان رطوبة بالأطراف، واصفرار أولي',
      sampleConditionEn: 'Marginal chlorosis and moisture loss',
    ),
    AiScanPreset(
      id: 'preset_tomato_soft',
      titleAr: 'طماطم بلدي (بداية ليونة وضغط)',
      titleEn: 'Vine Tomato (Softening & light pressure)',
      emoji: '🍅',
      produceCategory: 'vegetables',
      simulatedFreshness: 0.58,
      sampleConditionAr: 'ليونة بالأنسجة السفلية مع احمرار زائد',
      sampleConditionEn: 'Lower tissue softening and over-ripeness',
    ),
    AiScanPreset(
      id: 'preset_cucumber_fresh',
      titleAr: 'خيار محمي (نضارة ممتازة)',
      titleEn: 'Greenhouse Cucumber (Peak Freshness)',
      emoji: '🥒',
      produceCategory: 'vegetables',
      simulatedFreshness: 0.94,
      sampleConditionAr: 'صلابة مثالية، قشرة مشدودة، لمعان كامل',
      sampleConditionEn: 'High turgidity, firm epidermis, optimal gloss',
    ),
    AiScanPreset(
      id: 'preset_berries_critical',
      titleAr: 'فراولة / توت (بداية بقع فطرية)',
      titleEn: 'Strawberries (Early fungal spotting)',
      emoji: '🍓',
      produceCategory: 'fruits',
      simulatedFreshness: 0.32,
      sampleConditionAr: 'ظهور هيفات فطرية دقيقة مع تحلل سطحي',
      sampleConditionEn: 'Micro-fungal mycelium with surface decay',
    ),
  ];

  /// Runs computer-vision analysis simulation on a given produce item
  static Future<AiInspectionResult> inspectProduce({
    required ProduceItem item,
    double? overrideFreshness,
  }) async {
    // Simulate neural network latency (image preprocessing, YOLO segmentation, ViT classification)
    await Future.delayed(const Duration(milliseconds: 1400));

    final freshness = overrideFreshness ?? item.freshnessScore;
    final defects = <AiDefectFinding>[];
    String actionAr = '';
    String actionEn = '';
    double suggestedDiscount = 0.0;
    int remainingHours = 24;

    if (freshness >= 0.85) {
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.optimal,
          severityPercent: 5.0,
          locationTag: 'surface_cuticle',
          descriptionAr: 'قشرة سليمة ومتماسكة مع احتفاظ كامل بالرطوبة والمحتوى الغذائي.',
          descriptionEn: 'Intact epidermis with optimal cellular turgidity and nutrient density.',
        ),
      );
      actionAr = 'المنتج في قمة النضارة. يُباع بالسعر الكامل ولا يتطلب أي تدخل.';
      actionEn = 'Product is in peak freshness. Sell at standard premium price.';
      suggestedDiscount = 0.0;
      remainingHours = item.shelfLifeDays * 24;
    } else if (freshness >= 0.65) {
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.moistureLoss,
          severityPercent: 22.0,
          locationTag: 'epidermal_cells',
          descriptionAr: 'انخفاض طفيف في تماسك الأنسجة الخارجية مع استمرار جودة اللب.',
          descriptionEn: 'Slight decline in surface firmness, interior flesh remains optimal.',
        ),
      );
      actionAr = 'صالح للعرض الطبيعي، يُفضل تحفيز مبيعاته خلال الـ 48 ساعة القادمة.';
      actionEn = 'Good retail condition. Prioritize rotation within the next 48 hours.';
      suggestedDiscount = 10.0;
      remainingHours = (item.shelfLifeDays * 24 * 0.6).round();
    } else if (freshness >= 0.45) {
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.wilting,
          severityPercent: 42.0,
          locationTag: 'outer_margins',
          descriptionAr: 'علامات ذبول ملحوظة على الأجزاء الخارجية وفقدان سريع للنضارة.',
          descriptionEn: 'Notable wilting on peripheral leaves and accelerated moisture loss.',
        ),
      );
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.skinBrowning,
          severityPercent: 18.0,
          locationTag: 'calyx_stem',
          descriptionAr: 'تأكسد سطحي وتغير طفيف في اللون حول العنق.',
          descriptionEn: 'Surface oxidation and subtle color shift near stem.',
        ),
      );
      actionAr = 'تطبيق خصم ذكي 25% - 35% فوراً كعرض "إنقاذ سريع" لمنع تحوله إلى هدر تام.';
      actionEn = 'Apply 25% - 35% rescue markdown immediately to clear stock before total spoilage.';
      suggestedDiscount = 30.0;
      remainingHours = 36;
    } else {
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.fungalSpot,
          severityPercent: 65.0,
          locationTag: 'localized_patches',
          descriptionAr: 'ظهور بقع تلف عميقة وبداية تشكل مستعمرات فطرية غير صالحة للاستهلاك الكامل.',
          descriptionEn: 'Deep localized decay and fungal onset requiring immediate sorting.',
        ),
      );
      defects.add(
        const AiDefectFinding(
          type: AiDefectType.bruising,
          severityPercent: 50.0,
          locationTag: 'core_tissue',
          descriptionAr: 'تحلل في الأنسجة الداخلية بسبب الضغط الميكانيكي أو سوء التخزين.',
          descriptionEn: 'Internal tissue collapse from mechanical pressure or improper cooling.',
        ),
      );
      actionAr = 'فرز وتفريز فوري، إزالة الأجزاء التالفة وتسجيل الهدر، أو تصفية الباقي بخصم 50%.';
      actionEn = 'Immediate sorting required. Discard damaged portions and clearance sale at 50% discount.';
      suggestedDiscount = 50.0;
      remainingHours = 12;
    }

    return AiInspectionResult(
      produceId: item.id,
      produceNameAr: item.nameAr,
      produceNameEn: item.nameEn,
      timestamp: DateTime.now(),
      freshnessScore: freshness,
      confidenceScore: 0.94,
      detectedDefects: defects,
      recommendedActionAr: actionAr,
      recommendedActionEn: actionEn,
      suggestedDiscountPercent: suggestedDiscount,
      estimatedRemainingShelfLifeHours: remainingHours,
    );
  }
}
