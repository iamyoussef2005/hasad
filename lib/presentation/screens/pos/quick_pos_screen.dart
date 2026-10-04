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
                              // Digital Precision Scale Terminal Box
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0B132B) : const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Scale Header: Status indicators (Responsive & Overflow-proof)
                                    Row(
                                      children: [
                                        const Icon(Icons.scale_rounded, size: 13, color: Color(0xFF34D399)),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            lang == 'ar' ? 'الميزان الرقمي' : 'Digital Scale',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF34D399),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 5,
                                          height: 5,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF10B981),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(0xFF10B981),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Text(
                                          'STABLE',
                                          style: TextStyle(
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: const Text(
                                            'NET',
                                            style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    if (posState.selectedItem != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.06),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${posState.selectedItem!.emoji} ${posState.selectedItem!.getName(lang)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Scale weight numbers OLED readout
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text(
                                            posState.inputWeight.toStringAsFixed(2),
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF34D399),
                                              letterSpacing: 1,
                                              shadows: [
                                                Shadow(
                                                  color: Color(0xFF10B981),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            posState.selectedItem!.unit.getLocalized(lang),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Total item price
                                      Text(
                                        '= ${(posState.selectedItem!.sellingPrice * posState.inputWeight).toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFFBBF24),
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
                                        height: 34,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            ref.read(posNotifierProvider.notifier).addToCart();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            padding: EdgeInsets.zero,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          icon: const Icon(Icons.add_shopping_cart_rounded, size: 14, color: Colors.white),
                                          label: Text(
                                            lang == 'ar' ? 'إضافة للسلة' : 'Add to Cart',
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.touch_app_outlined, size: 14, color: Colors.white60),
                                            const SizedBox(width: 6),
                                            Text(
                                              lang == 'ar' ? 'اضغط صنفاً لبدء وزنه' : 'Select item to weigh',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
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
                              height: 38,
                              child: ElevatedButton.icon(
                                onPressed: posState.cart.isEmpty
                                    ? null
                                    : () async {
                                        final savedCart = List<CartItem>.from(posState.cart);
                                        final savedTotal = posState.cartTotal;
                                        await ref.read(posNotifierProvider.notifier).checkout();
                                        if (context.mounted) {
                                          _showReceiptDialog(context, savedCart, savedTotal, lang, isDark);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.receipt_long_rounded, size: 16, color: Colors.white),
                                label: Text(
                                  AppStrings.get('confirm_sale', lang),
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
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

  void _showReceiptDialog(
    BuildContext context,
    List<CartItem> items,
    double totalAmount,
    String lang,
    bool isDark,
  ) {
    final vatAmount = totalAmount * 0.15 / 1.15;
    final subtotal = totalAmount - vatAmount;
    final now = DateTime.now();
    final invoiceNumber = 'INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Success Check Icon
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      lang == 'ar' ? 'تمت عملية البيع بنجاح!' : 'Sale Completed Successfully!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Center(
                    child: Text(
                      lang == 'ar' ? 'فاتورة ضريبية مبسطة (إلكترونية)' : 'Simplified Tax E-Invoice',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Receipt Sheet Container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'ar' ? 'رقم الفاتورة:' : 'Invoice #:',
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            Text(
                              invoiceNumber,
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'ar' ? 'التاريخ والوقت:' : 'Date & Time:',
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            Text(
                              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day}/${now.month}/${now.year}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const Divider(height: 18, thickness: 0.8),

                        // Items list
                        ...items.map((cartItem) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(cartItem.produce.emoji, style: const TextStyle(fontSize: 15)),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem.produce.getName(lang),
                                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${cartItem.quantity.toStringAsFixed(2)} ${cartItem.produce.unit.getLocalized(lang)} × ${cartItem.produce.sellingPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${cartItem.totalPrice.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(height: 18, thickness: 0.8),

                        // Financial totals
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'ar' ? 'المبلغ بدون الضريبة:' : 'Subtotal Excl. VAT:',
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            Text(
                              '${subtotal.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'ar' ? 'ضريبة القيمة المضافة (15%):' : 'VAT (15%):',
                              style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                            ),
                            Text(
                              '${vatAmount.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              lang == 'ar' ? 'الإجمالي النهائي:' : 'Grand Total:',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              '${totalAmount.toStringAsFixed(2)} ${AppStrings.get('currency', lang)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        // Simulated QR Code for e-invoicing
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.qr_code_2_rounded, size: 32, color: Colors.black87),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang == 'ar' ? 'فاتورة إلكترونية مطابقة' : 'ZATCA E-Invoice',
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black87),
                                  ),
                                  Text(
                                    lang == 'ar' ? 'متوافقة مع هيئة الزكاة والضريبة' : 'Tax & Customs Authority Compliant',
                                    style: TextStyle(fontSize: 7.5, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  lang == 'ar' ? 'جاري إرسال الفاتورة لطابعة الإيصالات الحرارية...' : 'Printing receipt to thermal printer...',
                                ),
                                backgroundColor: AppColors.primaryDark,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.print_outlined, size: 15, color: AppColors.primary),
                          label: Text(
                            lang == 'ar' ? 'طباعة' : 'Print',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            lang == 'ar' ? 'إتمام' : 'Done',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
