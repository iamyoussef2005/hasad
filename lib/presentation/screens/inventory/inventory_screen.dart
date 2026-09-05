import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../controllers/inventory_controller.dart';
import '../../controllers/pos_controller.dart';
import 'produce_details_screen.dart';
import 'add_edit_produce_dialog.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/produce_grid_card.dart';
import 'widgets/produce_list_item.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final inventoryAsync = ref.watch(inventoryNotifierProvider);

    return Scaffold(
      body: inventoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (inventory) {
          final items = inventory.filteredItems;

          return Column(
            children: [
              // Search & View Toggle Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: TextField(
                        onChanged: (val) {
                          ref.read(inventoryNotifierProvider.notifier).setSearchQuery(val);
                        },
                        decoration: InputDecoration(
                          hintText: AppStrings.get('search_placeholder', lang),
                          hintStyle: AppTypography.bodySmall(isDark: isDark),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Grid / List View Toggle
                    InkWell(
                      onTap: () {
                        ref.read(inventoryNotifierProvider.notifier).toggleViewMode();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: Icon(
                          inventory.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Horizontal Bar
              CategoryFilterBar(
                selectedCategory: inventory.selectedCategory,
                lang: lang,
                onCategorySelected: (cat) {
                  ref.read(inventoryNotifierProvider.notifier).selectCategory(cat);
                },
              ),
              const SizedBox(height: 10),

              // Summary status bar (showing count of items)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${items.length} ${lang == 'ar' ? 'صنف متوفر' : 'items found'}',
                      style: AppTypography.bodySmall(isDark: isDark).copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang == 'ar' ? 'تحديث المخزون فوري' : 'Live Sync Active',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Items Content: Grid or List
              Expanded(
                child: items.isEmpty
                    ? _buildEmptyState(context, lang, isDark)
                    : inventory.isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ProduceGridCard(
                                item: item,
                                lang: lang,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProduceDetailsScreen(produceId: item.id),
                                    ),
                                  );
                                },
                                onQuickAction: () {
                                  // Quick add to POS cart
                                  ref.read(posNotifierProvider.notifier).selectProduce(item);
                                  ref.read(posNotifierProvider.notifier).addToCart();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${item.getName(lang)} ${lang == 'ar' ? 'أضيفت لسلة البيع' : 'added to cart'}',
                                      ),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: AppColors.primaryDark,
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: items.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ProduceListItem(
                                item: item,
                                lang: lang,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProduceDetailsScreen(produceId: item.id),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEditProduceDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppStrings.get('add_produce', lang),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String lang, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🥗', style: TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.get('no_items_found', lang),
            style: AppTypography.headlineSmall(isDark: isDark),
          ),
          const SizedBox(height: 6),
          Text(
            lang == 'ar'
                ? 'جرب البحث باسم صنف آخر أو غير التصنيف المحدد'
                : 'Try searching for another produce or clear filter',
            style: AppTypography.bodySmall(isDark: isDark),
          ),
        ],
      ),
    );
  }
}
