import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../data/models/waste_record.dart';
import '../../../data/models/produce_item.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/waste_controller.dart';

class RecordWasteDialog extends ConsumerStatefulWidget {
  final String? preselectedProduceId;

  const RecordWasteDialog({super.key, this.preselectedProduceId});

  @override
  ConsumerState<RecordWasteDialog> createState() => _RecordWasteDialogState();
}

class _RecordWasteDialogState extends ConsumerState<RecordWasteDialog> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProduceId;
  ProduceItem? _selectedItem;
  final TextEditingController _quantityController = TextEditingController(text: '1.0');
  final TextEditingController _notesController = TextEditingController();
  WasteReason _selectedReason = WasteReason.wiltingAndRot;

  double _calculatedLoss = 0.0;

  @override
  void initState() {
    super.initState();
    _selectedProduceId = widget.preselectedProduceId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalcLoss() {
    if (_selectedItem == null) return;
    final qty = double.tryParse(_quantityController.text) ?? 0.0;
    setState(() {
      _calculatedLoss = qty * _selectedItem!.costPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);

    return inventoryAsync.when(
      loading: () => const Dialog(child: SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))),
      error: (err, stack) => const Dialog(child: Text('Error')),
      data: (inventory) {
        if (_selectedItem == null && inventory.allItems.isNotEmpty) {
          _selectedItem = _selectedProduceId != null
              ? inventory.allItems.firstWhere((i) => i.id == _selectedProduceId, orElse: () => inventory.allItems.first)
              : inventory.allItems.first;
          _selectedProduceId = _selectedItem!.id;
          _recalcLoss();
        }

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.spoilageLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delete_sweep_rounded, color: AppColors.spoilageRed, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.get('record_waste', lang),
                            style: AppTypography.headlineSmall(isDark: isDark),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      AppStrings.get('record_waste_subtitle', lang),
                      style: AppTypography.bodySmall(isDark: isDark),
                    ),
                    const SizedBox(height: 16),

                    // Produce Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProduceId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'الصنف التالف' : 'Produce Item',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: inventory.allItems.map((item) {
                        final stockStr = item.currentStock.toStringAsFixed(
                          item.currentStock.truncateToDouble() == item.currentStock ? 0 : 1,
                        );
                        return DropdownMenuItem(
                          value: item.id,
                          child: Row(
                            children: [
                              Text(item.emoji, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.getName(lang)} ($stockStr ${item.unit.getLocalized(lang)})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedProduceId = val;
                            _selectedItem = inventory.allItems.firstWhere((i) => i.id == val);
                            _recalcLoss();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quantity Wasted Field
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'الكمية التالفة' : 'Wasted Quantity',
                        suffixText: _selectedItem?.unit.getLocalized(lang) ?? 'كغ',
                        prefixIcon: const Icon(Icons.scale_rounded, size: 20),
                      ),
                      onChanged: (_) => _recalcLoss(),
                      validator: (v) {
                        final parsed = double.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) return 'أدخل كمية صحيحة';
                        if (_selectedItem != null && parsed > _selectedItem!.currentStock) {
                          return 'الكمية أكبر من المخزون المتوفر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Reason Dropdown
                    DropdownButtonFormField<WasteReason>(
                      initialValue: _selectedReason,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'سبب التلف' : 'Spoilage Reason',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: WasteReason.values.map((reason) {
                        return DropdownMenuItem(
                          value: reason,
                          child: Text(reason.getLocalized(lang), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (r) {
                        if (r != null) setState(() => _selectedReason = r);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'ملاحظات إضافية' : 'Notes',
                        prefixIcon: const Icon(Icons.edit_note_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calculated Financial Loss Banner
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1D1D) : AppColors.spoilageLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang == 'ar' ? 'الخسارة المالية المباشرة:' : 'Direct Financial Loss:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.spoilageRed,
                            ),
                          ),
                          Text(
                            '${_calculatedLoss.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                            style: AppTypography.numberMedium(isDark: isDark).copyWith(
                              color: AppColors.spoilageRed,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitWaste,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.spoilageRed,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          lang == 'ar' ? 'تسجيل وقيد التلف' : 'Log Waste Record',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitWaste() {
    if (!_formKey.currentState!.validate() || _selectedItem == null) return;

    final qty = double.parse(_quantityController.text);
    final record = WasteRecord(
      id: 'w_${const Uuid().v4().substring(0, 8)}',
      produceId: _selectedItem!.id,
      produceNameAr: _selectedItem!.nameAr,
      produceNameEn: _selectedItem!.nameEn,
      quantityWasted: qty,
      financialLoss: _calculatedLoss,
      reason: _selectedReason,
      date: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    ref.read(wasteNotifierProvider.notifier).recordWaste(record);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('waste_recorded', ref.read(appLocaleProvider).languageCode)),
        backgroundColor: AppColors.spoilageRed,
      ),
    );
  }
}
