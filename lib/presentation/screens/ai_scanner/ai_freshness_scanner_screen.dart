import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../data/models/produce_item.dart';
import '../../../data/models/produce_category.dart';
import '../../../data/models/ai_inspection_result.dart';
import '../../../data/models/markdown_proposal.dart';
import '../../../domain/services/ai_vision_inspection_service.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/markdown_controller.dart';

class AiFreshnessScannerScreen extends ConsumerStatefulWidget {
  final ProduceItem? targetItem;

  const AiFreshnessScannerScreen({super.key, this.targetItem});

  @override
  ConsumerState<AiFreshnessScannerScreen> createState() => _AiFreshnessScannerScreenState();
}

class _AiFreshnessScannerScreenState extends ConsumerState<AiFreshnessScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  ProduceItem? _selectedItem;
  AiScanPreset? _selectedPreset;
  bool _isAnalyzing = false;
  String _analysisStep = '';
  AiInspectionResult? _inspectionResult;
  bool _flashEnabled = false;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.targetItem;
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.08, end: 0.92).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _startScan({double? overrideFreshness}) async {
    if (_selectedItem == null && _selectedPreset == null) {
      final lang = ref.read(appLocaleProvider).languageCode;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'الرجاء اختيار صنف للفحص أولاً'
                : 'Please select a produce item to inspect first',
          ),
          backgroundColor: AppColors.spoilageRed,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _inspectionResult = null;
      _analysisStep = '1/3 جاري مسح مظهر الثمار وتحديد الصنف...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _analysisStep = '2/3 فحص نضارة القشرة ونسبة الرطوبة...');

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _analysisStep = '3/3 احتساب درجة الجودة وتوليد التوصيات...');

    ProduceItem itemToScan;
    if (_selectedItem != null) {
      itemToScan = _selectedItem!;
    } else {
      // Build dummy ProduceItem from preset
      itemToScan = ref.read(inventoryNotifierProvider).value?.allItems.firstWhere(
                (i) => i.category.name == _selectedPreset!.produceCategory,
                orElse: () => ref.read(inventoryNotifierProvider).value!.allItems.first,
              ) ??
          ProduceItem(
            id: 'demo_item',
            nameAr: _selectedPreset!.titleAr,
            nameEn: _selectedPreset!.titleEn,
            category: ref.read(inventoryNotifierProvider).value!.allItems.first.category,
            unit: ProduceUnit.kg,
            currentStock: 35.0,
            minStockThreshold: 10.0,
            costPrice: 2.0,
            sellingPrice: 3.5,
            wholesaleMarketPrice: 2.2,
            shelfLifeDays: 5,
            freshnessScore: _selectedPreset!.simulatedFreshness,
            emoji: _selectedPreset!.emoji,
            primaryColorHex: '#10B981',
          );
    }

    final result = await AiVisionInspectionService.inspectProduce(
      item: itemToScan,
      overrideFreshness: overrideFreshness ?? _selectedPreset?.simulatedFreshness,
    );

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _inspectionResult = result;
    });
  }

  void _applyAiMarkdown() {
    if (_inspectionResult == null || _selectedItem == null) return;

    final item = _selectedItem!;
    final discount = _inspectionResult!.suggestedDiscountPercent;
    if (discount <= 0) return;

    final newPrice = double.parse((item.sellingPrice * (1.0 - (discount / 100.0))).toStringAsFixed(2));

    final proposal = MarkdownProposal(
      produceId: item.id,
      produceNameAr: item.nameAr,
      produceNameEn: item.nameEn,
      currentSellingPrice: item.sellingPrice,
      recommendedPrice: newPrice,
      discountPercent: discount,
      urgency: _inspectionResult!.freshnessScore < 0.45 ? MarkdownUrgency.critical : MarkdownUrgency.medium,
      reasonAr: _inspectionResult!.recommendedActionAr,
      reasonEn: _inspectionResult!.recommendedActionEn,
      potentialRecoveredRevenue: double.parse((item.currentStock * newPrice).toStringAsFixed(2)),
      projectedWasteLoss: double.parse((item.currentStock * item.costPrice).toStringAsFixed(2)),
      estimatedDaysToExpiry: (_inspectionResult!.estimatedRemainingShelfLifeHours / 24).ceil(),
      currentFreshnessScore: _inspectionResult!.freshnessScore,
      currentStock: item.currentStock,
    );

    ref.read(markdownNotifierProvider.notifier).applyMarkdown(proposal);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تم تطبيق خصم الإنقاذ ($discount%) على ${item.nameAr} بنجاح!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inventory = ref.watch(inventoryNotifierProvider).value?.allItems ?? [];

    // Ensure selectedItem points to updated inventory item
    if (_selectedItem != null) {
      _selectedItem = inventory.firstWhere((i) => i.id == _selectedItem!.id, orElse: () => _selectedItem!);
    } else if (inventory.isNotEmpty) {
      _selectedItem = inventory.first;
    }

    final activeEmoji = _selectedPreset?.emoji ?? _selectedItem?.emoji ?? '🥬';
    final activeName = _selectedPreset != null
        ? (lang == 'ar' ? _selectedPreset!.titleAr : _selectedPreset!.titleEn)
        : (_selectedItem?.getName(lang) ?? '');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          AppStrings.get('camera_scanner_title', lang),
          style: AppTypography.headlineSmall(isDark: isDark).copyWith(fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _flashEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _flashEnabled ? AppColors.warningOrange : Colors.grey,
            ),
            onPressed: () => setState(() => _flashEnabled = !_flashEnabled),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanner Viewport
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 310,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        // Background camera simulation grid
                        CustomPaint(
                          size: const Size(double.infinity, 310),
                          painter: _ScannerGridPainter(),
                        ),

                        // Center Target Produce
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: _isAnalyzing ? AppColors.citrusYellow : AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    activeEmoji,
                                    style: const TextStyle(fontSize: 70),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Text(
                                  activeName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Animated Laser Sweep
                        if (_isAnalyzing)
                          AnimatedBuilder(
                            animation: _laserAnimation,
                            builder: (context, child) {
                              return Positioned(
                                top: 310 * _laserAnimation.value,
                                left: 20,
                                right: 20,
                                child: Container(
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: AppColors.citrusYellow,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.citrusYellow.withValues(alpha: 0.8),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                        // Corner Targeting Brackets
                        const Positioned(top: 14, left: 14, child: _CornerBracket(isTop: true, isLeft: true)),
                        const Positioned(top: 14, right: 14, child: _CornerBracket(isTop: true, isLeft: false)),
                        const Positioned(bottom: 14, left: 14, child: _CornerBracket(isTop: false, isLeft: true)),
                        const Positioned(bottom: 14, right: 14, child: _CornerBracket(isTop: false, isLeft: false)),

                        // Telemetry Badge
                        Positioned(
                          top: 14,
                          left: 40,
                          right: 40,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _isAnalyzing ? AppColors.warningOrange : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isAnalyzing
                                        ? 'AI VISION PROCESSING...'
                                        : 'COMPUTER VISION READY (YOLOv8 + ResNet)',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Step Progress while analyzing
            if (_isAnalyzing) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        _analysisStep,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Scan Action Button
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : () => _startScan(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              icon: const Icon(Icons.document_scanner_rounded, size: 22),
              label: Text(
                AppStrings.get('scan_now', lang),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 20),

            // Preset Test Scenarios
            Text(
              AppStrings.get('sample_presets', lang),
              style: AppTypography.titleMedium(isDark: isDark).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AiVisionInspectionService.samplePresets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final preset = AiVisionInspectionService.samplePresets[index];
                  final isSelected = _selectedPreset?.id == preset.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPreset = preset;
                        _selectedItem = null;
                      });
                      _startScan(overrideFreshness: preset.simulatedFreshness);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 170,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isDark ? const Color(0xFF1E293B) : Colors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(preset.emoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lang == 'ar' ? preset.titleAr : preset.titleEn,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${(preset.simulatedFreshness * 100).toInt()}% نضارة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: preset.simulatedFreshness < 0.5
                                        ? AppColors.spoilageRed
                                        : AppColors.primaryDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Select from Current Inventory
            Text(
              lang == 'ar' ? 'أو اختر صنفاً من مخزون المتجر' : 'Or select from Store Inventory',
              style: AppTypography.titleMedium(isDark: isDark).copyWith(fontSize: 13),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: inventory.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final isSelected = _selectedItem?.id == item.id && _selectedPreset == null;
                  return ChoiceChip(
                    label: Text('${item.emoji} ${item.getName(lang)}'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedItem = item;
                          _selectedPreset = null;
                        });
                        _startScan();
                      }
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.3),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Diagnostic Results Card
            if (_inspectionResult != null) _buildResultCard(context, _inspectionResult!, lang, isDark),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    AiInspectionResult res,
    String lang,
    bool isDark,
  ) {
    final freshnessPercent = (res.freshnessScore * 100).toInt();
    final Color scoreColor = res.freshnessScore >= 0.8
        ? AppColors.primaryDark
        : (res.freshnessScore >= 0.5 ? AppColors.warningOrange : AppColors.spoilageRed);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Freshness score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'ar' ? 'تقرير فحص جودة المحصول' : 'Produce Quality Diagnostics',
                    style: AppTypography.titleMedium(isDark: isDark).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${AppStrings.get('confidence_score', lang)}: ${(res.confidenceScore * 100).toInt()}%',
                    style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scoreColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      res.freshnessScore >= 0.8
                          ? Icons.verified_rounded
                          : (res.freshnessScore >= 0.5 ? Icons.warning_amber_rounded : Icons.report_problem_rounded),
                      color: scoreColor,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$freshnessPercent%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Detected Defects & Biological Cues
          Text(
            AppStrings.get('detected_defects', lang),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...res.detectedDefects.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.type.getLocalizedName(lang),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.getDescription(lang),
                      style: const TextStyle(fontSize: 11, height: 1.3),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),

          // Action Recommendation Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.citrusYellow.withValues(alpha: 0.15),
                  AppColors.warningOrange.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb_rounded, color: AppColors.warningOrange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.get('ai_recommendation', lang),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.warningOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  res.getAction(lang),
                  style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          if (res.suggestedDiscountPercent > 0 && _selectedItem != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _applyAiMarkdown,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warningOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 20),
              label: Text(
                'تطبيق خصم الإنقاذ (${res.suggestedDiscountPercent.toStringAsFixed(0)}%) فوراً',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScannerGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const double step = 30;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _CornerBracket({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: CustomPaint(
        painter: _BracketPainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _BracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
