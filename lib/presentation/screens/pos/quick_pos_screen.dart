import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/pos_controller.dart';

class QuickPosScreen extends ConsumerStatefulWidget {
  const QuickPosScreen({super.key});

  @override
  ConsumerState<QuickPosScreen> createState() => _QuickPosScreenState();
}

class _QuickPosScreenState extends ConsumerState<QuickPosScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final posState = ref.watch(posNotifierProvider);

    return Scaffold(
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (inventory) {
          final items = inventory.allItems.where((i) {
            final q = _searchQuery.toLowerCase().trim();
            if (q.isEmpty) return true;
            return i.nameAr.toLowerCase().contains(q) || i.nameEn.toLowerCase().contains(q);
          }).toList();

          return Row(
            children: [
              // ==================== PANEL 1: PRODUCE SELECTION GRID ====================
              Expanded(
                flex: 11,
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: const TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          hintText: lang == 'ar' ? 'اختر صنفاً للوزن...' : 'Select produce...',
                          hintStyle: const TextStyle(fontSize: 11),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),

                    // Grid
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                          childAspectRatio: 0.84, // Ample height to eliminate any bottom overflow
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = posState.selectedItem?.id == item.id;

                          return InkWell(
                            onTap: () {
                              ref.read(posNotifierProvider.notifier).selectProduce(item);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : (isDark ? AppColors.surfaceDark : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Top Row: Emoji + Stock Badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(item.emoji, style: const TextStyle(fontSize: 20)),
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: item.isLowStock
                                                ? AppColors.spoilageLight
                                                : (isDark ? Colors.white10 : AppColors.bgLight),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Text(
                                            '${item.currentStock.toInt()} ${item.unit.getLocalized(lang)}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w700,
                                              color: item.isLowStock
                                                  ? AppColors.spoilageRed
                                                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Produce Name
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      item.getName(lang),
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.primaryDark
                                            : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // Bottom Row: Price & Scale Icon
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  item.sellingPrice.toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w900,
                                                    color: isSelected ? AppColors.primaryDark : AppColors.primary,
                                                  ),
                                                ),
                                                const SizedBox(width: 1),
                                                Text(
                                                  AppStrings.get('currency', lang),
                                                  style: TextStyle(
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected ? AppColors.primaryDark : AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '/${item.unit.getLocalized(lang)}',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.primary.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(
                                          Icons.scale_rounded,
                                          size: 13,
                                          color: isSelected ? Colors.white : AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ==================== PANEL 2: SCALE & CART CASHIER TERMINAL ====================
              Expanded(
                flex: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    border: Border(
                      left: lang == 'ar' ? BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8) : BorderSide.none,
                      right: lang == 'en' ? BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8) : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top + Middle: Scale box & Cart list
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Scale Box
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.bgDark : AppColors.bgLight,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.scale_rounded, size: 14, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          AppStrings.get('weight_calculator', lang),
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (posState.selectedItem != null) ...[
                                      Text(
                                        '${posState.selectedItem!.emoji} ${posState.selectedItem!.getName(lang)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Scale weight numbers
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            posState.inputWeight.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            posState.selectedItem!.unit.getLocalized(lang),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Total item price
                                      Text(
                                        '= ${(posState.selectedItem!.sellingPrice * posState.inputWeight).toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Quick presets
                                      Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        alignment: WrapAlignment.center,
                                        children: [
                                          _buildPresetBtn(0.25, '+0.25'),
                                          _buildPresetBtn(0.50, '+0.50'),
                                          _buildPresetBtn(1.00, '+1.0'),
                                          _buildPresetBtn(2.00, '+2.0'),
                                          _buildResetBtn(),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Add button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ref.read(posNotifierProvider.notifier).addToCart();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: EdgeInsets.zero,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                                          ),
                                          child: Text(
                                            lang == 'ar' ? 'إضافة للسلة' : 'Add to Cart',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        child: Text(
                                          lang == 'ar' ? 'اختر صنفاً من القائمة لبدء حسابه' : 'Tap a produce to weigh',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Cart List
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${lang == 'ar' ? 'سلة الطلب' : 'Cart'} (${posState.cart.length})',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  if (posState.cart.isNotEmpty)
                                    InkWell(
                                      onTap: () => ref.read(posNotifierProvider.notifier).clearCart(),
                                      child: Text(
                                        lang == 'ar' ? 'إفراغ' : 'Clear',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.spoilageRed,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),

                              if (posState.cart.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Center(
                                    child: Text(
                                      lang == 'ar' ? 'السلة فارغة حالياً' : 'Cart is empty',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                ...posState.cart.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final item = entry.value;
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.bgDark : AppColors.bgLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(item.produce.emoji, style: const TextStyle(fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.produce.getName(lang),
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${item.quantity.toStringAsFixed(2)} ${item.produce.unit.getLocalized(lang)} × ${item.produce.sellingPrice}',
                                                style: TextStyle(fontSize: 8.5, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          item.totalPrice.toStringAsFixed(1),
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                                        ),
                                        const SizedBox(width: 2),
                                        InkWell(
                                          onTap: () => ref.read(posNotifierProvider.notifier).removeFromCart(idx),
                                          child: const Icon(Icons.close_rounded, size: 14, color: AppColors.spoilageRed),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Checkout Box
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          border: Border(
                            top: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 0.8),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Total line wrapped safely in FittedBox
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    lang == 'ar' ? 'الإجمالي:' : 'Total:',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${posState.cartTotal.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              height: 36,
                              child: ElevatedButton(
                                onPressed: posState.cart.isEmpty
                                    ? null
                                    : () async {
                                        await ref.read(posNotifierProvider.notifier).checkout();
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(AppStrings.get('sale_completed', lang)),
                                              backgroundColor: AppColors.primary,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Text(
                                  AppStrings.get('confirm_sale', lang),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPresetBtn(double delta, String label) {
    return InkWell(
      onTap: () {
        final current = ref.read(posNotifierProvider).inputWeight;
        ref.read(posNotifierProvider.notifier).updateWeight(current + delta);
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
        ),
      ),
    );
  }

  Widget _buildResetBtn() {
    return InkWell(
      onTap: () => ref.read(posNotifierProvider.notifier).updateWeight(1.0),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.spoilageLight,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          '1كغ',
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.spoilageRed),
        ),
      ),
    );
  }
}
