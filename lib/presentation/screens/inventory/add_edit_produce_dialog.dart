import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../data/models/produce_item.dart';
import '../../../data/models/produce_category.dart';
import '../../../data/models/batch_item.dart';
import '../../controllers/inventory_controller.dart';

class AddEditProduceDialog extends ConsumerStatefulWidget {
  final ProduceItem? itemToEdit;

  const AddEditProduceDialog({super.key, this.itemToEdit});

  @override
  ConsumerState<AddEditProduceDialog> createState() => _AddEditProduceDialogState();
}

class _AddEditProduceDialogState extends ConsumerState<AddEditProduceDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameArController;
  late TextEditingController _nameEnController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _stockController;
  late TextEditingController _thresholdController;
  late TextEditingController _shelfLifeController;

  late ProduceCategory _selectedCategory;
  late ProduceUnit _selectedUnit;
  late String _selectedEmoji;

  final List<String> _emojis = [
    '🍅', '🥒', '🍋', '🌿', '🥬', '🥔', '🍊', '🍌',
    '🫑', '🍓', '🧅', '🍉', '🥕', '🍇', '🥑', '🌽',
    '🍏', '🥭', '🍍', '🧄', '🥦', '🍑', '🍒', '🍐'
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _nameArController = TextEditingController(text: item?.nameAr ?? '');
    _nameEnController = TextEditingController(text: item?.nameEn ?? '');
    _costPriceController = TextEditingController(text: item?.costPrice.toString() ?? '3.5');
    _sellingPriceController = TextEditingController(text: item?.sellingPrice.toString() ?? '5.0');
    _stockController = TextEditingController(text: item?.currentStock.toString() ?? '50');
    _thresholdController = TextEditingController(text: item?.minStockThreshold.toString() ?? '15');
    _shelfLifeController = TextEditingController(text: item?.shelfLifeDays.toString() ?? '6');

    _selectedCategory = item?.category ?? ProduceCategory.vegetables;
    _selectedUnit = item?.unit ?? ProduceUnit.kg;
    _selectedEmoji = item?.emoji ?? '🍅';
  }

  @override
  void dispose() {
    _nameArController.dispose();
    _nameEnController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.itemToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing
                          ? AppStrings.get('edit_produce', lang)
                          : AppStrings.get('add_produce', lang),
                      style: AppTypography.headlineSmall(isDark: isDark),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Emoji Selector Row
                        Text(
                          lang == 'ar' ? 'أيقونة الصنف' : 'Produce Emoji Icon',
                          style: AppTypography.bodySmall(isDark: isDark).copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _emojis.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final emoji = _emojis[index];
                              final isSelected = emoji == _selectedEmoji;
                              return InkWell(
                                onTap: () => setState(() => _selectedEmoji = emoji),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryLight : (isDark ? AppColors.bgDark : AppColors.bgLight),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name AR
                        TextFormField(
                          controller: _nameArController,
                          decoration: InputDecoration(
                            labelText: lang == 'ar' ? 'الاسم بالعربية' : 'Arabic Name',
                            prefixIcon: const Icon(Icons.title_rounded, size: 20),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال الاسم' : null,
                        ),
                        const SizedBox(height: 12),

                        // Name EN
                        TextFormField(
                          controller: _nameEnController,
                          decoration: InputDecoration(
                            labelText: lang == 'ar' ? 'الاسم بالإنجليزية' : 'English Name',
                            prefixIcon: const Icon(Icons.translate_rounded, size: 20),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'Please enter English name' : null,
                        ),
                        const SizedBox(height: 12),

                        // Category & Unit Row
                        Row(
                          children: [
                            // Category Dropdown
                            Expanded(
                              child: DropdownButtonFormField<ProduceCategory>(
                                initialValue: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: lang == 'ar' ? 'التصنيف' : 'Category',
                                ),
                                items: ProduceCategory.values
                                    .where((c) => c != ProduceCategory.all)
                                    .map((c) {
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text(c.getLocalizedName(lang), style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (cat) {
                                  if (cat != null) setState(() => _selectedCategory = cat);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Unit Dropdown
                            Expanded(
                              child: DropdownButtonFormField<ProduceUnit>(
                                initialValue: _selectedUnit,
                                decoration: InputDecoration(
                                  labelText: lang == 'ar' ? 'وحدة القياس' : 'Unit',
                                ),
                                items: ProduceUnit.values.map((u) {
                                  return DropdownMenuItem(
                                    value: u,
                                    child: Text(u.getLocalized(lang), style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (u) {
                                  if (u != null) setState(() => _selectedUnit = u);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Pricing Row (Cost & Sell)
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _costPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: AppStrings.get('cost_price', lang),
                                  suffixText: AppStrings.get('currency', lang),
                                ),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل رقماً' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _sellingPriceController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: AppStrings.get('selling_price', lang),
                                  suffixText: AppStrings.get('currency', lang),
                                ),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل رقماً' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stock Qty & Low Stock Threshold Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _stockController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: lang == 'ar' ? 'الكمية الحالية' : 'Current Stock',
                                  suffixText: _selectedUnit.getLocalized(lang),
                                ),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل رقماً' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _thresholdController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: InputDecoration(
                                  labelText: lang == 'ar' ? 'حد التنبيه' : 'Min Alert',
                                  suffixText: _selectedUnit.getLocalized(lang),
                                ),
                                validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل رقماً' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Shelf Life Days
                        TextFormField(
                          controller: _shelfLifeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppStrings.get('days_shelf_life', lang),
                            prefixIcon: const Icon(Icons.hourglass_top_rounded, size: 20),
                          ),
                          validator: (v) => int.tryParse(v ?? '') == null ? 'أدخل عدداً صحيحاً' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(lang == 'ar' ? 'إلغاء' : 'Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          lang == 'ar' ? 'حفظ الصنف' : 'Save Produce',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveItem() {
    if (!_formKey.currentState!.validate()) return;

    final cost = double.parse(_costPriceController.text);
    final sell = double.parse(_sellingPriceController.text);
    final stock = double.parse(_stockController.text);
    final threshold = double.parse(_thresholdController.text);
    final shelfLife = int.parse(_shelfLifeController.text.isNotEmpty ? _shelfLifeController.text : '7');

    final isEditing = widget.itemToEdit != null;
    final produceItem = ProduceItem(
      id: isEditing ? widget.itemToEdit!.id : 'p_${const Uuid().v4().substring(0, 8)}',
      nameAr: _nameArController.text.trim(),
      nameEn: _nameEnController.text.trim(),
      category: _selectedCategory,
      unit: _selectedUnit,
      currentStock: stock,
      minStockThreshold: threshold,
      costPrice: cost,
      sellingPrice: sell,
      wholesaleMarketPrice: cost * 0.95,
      shelfLifeDays: shelfLife,
      freshnessScore: isEditing ? widget.itemToEdit!.freshnessScore : 0.95,
      emoji: _selectedEmoji,
      primaryColorHex: '#10B981',
      batches: isEditing
          ? widget.itemToEdit!.batches
          : [
              BatchItem(
                id: 'b_${DateTime.now().millisecondsSinceEpoch}',
                receivedDate: DateTime.now(),
                quantityReceived: stock,
                quantityRemaining: stock,
                supplierName: 'سوق الجملة المركزي',
                costPerUnit: cost,
              )
            ],
      priceHistory: isEditing ? widget.itemToEdit!.priceHistory : [],
    );

    if (isEditing) {
      ref.read(inventoryNotifierProvider.notifier).updateProduce(produceItem);
    } else {
      ref.read(inventoryNotifierProvider.notifier).addProduce(produceItem);
    }

    Navigator.pop(context);
  }
}
