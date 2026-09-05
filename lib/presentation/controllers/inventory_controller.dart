import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/produce_item.dart';
import '../../data/models/produce_category.dart';
import '../../data/models/batch_item.dart';
import '../../data/repositories/produce_repository.dart';

final produceRepositoryProvider = Provider<ProduceRepository>((ref) {
  return InMemoryProduceRepository();
});

class InventoryState {
  final List<ProduceItem> allItems;
  final ProduceCategory selectedCategory;
  final String searchQuery;
  final bool isGridView;
  final bool isLoading;

  const InventoryState({
    required this.allItems,
    this.selectedCategory = ProduceCategory.all,
    this.searchQuery = '',
    this.isGridView = true,
    this.isLoading = false,
  });

  List<ProduceItem> get filteredItems {
    return allItems.where((item) {
      final matchesCategory = selectedCategory == ProduceCategory.all || item.category == selectedCategory;
      final q = searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          item.nameAr.toLowerCase().contains(q) ||
          item.nameEn.toLowerCase().contains(q) ||
          item.batches.any((b) => b.supplierName.toLowerCase().contains(q));
      return matchesCategory && matchesSearch;
    }).toList();
  }

  int get lowStockCount => allItems.where((item) => item.isLowStock).length;
  double get totalStockValue => allItems.fold(0.0, (sum, item) => sum + item.totalValue);

  double get averageFreshness {
    if (allItems.isEmpty) return 1.0;
    final sum = allItems.fold(0.0, (total, item) => total + item.freshnessScore);
    return sum / allItems.length;
  }

  InventoryState copyWith({
    List<ProduceItem>? allItems,
    ProduceCategory? selectedCategory,
    String? searchQuery,
    bool? isGridView,
    bool? isLoading,
  }) {
    return InventoryState(
      allItems: allItems ?? this.allItems,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class InventoryNotifier extends AsyncNotifier<InventoryState> {
  @override
  Future<InventoryState> build() async {
    final repo = ref.read(produceRepositoryProvider);
    final items = await repo.getAllProduce();
    return InventoryState(allItems: items);
  }

  void selectCategory(ProduceCategory category) {
    state = AsyncData(state.value!.copyWith(selectedCategory: category));
  }

  void setSearchQuery(String query) {
    state = AsyncData(state.value!.copyWith(searchQuery: query));
  }

  void toggleViewMode() {
    state = AsyncData(state.value!.copyWith(isGridView: !state.value!.isGridView));
  }

  Future<void> addProduce(ProduceItem item) async {
    final repo = ref.read(produceRepositoryProvider);
    await repo.addProduce(item);
    final items = await repo.getAllProduce();
    state = AsyncData(state.value!.copyWith(allItems: items));
  }

  Future<void> updateProduce(ProduceItem item) async {
    final repo = ref.read(produceRepositoryProvider);
    await repo.updateProduce(item);
    final items = await repo.getAllProduce();
    state = AsyncData(state.value!.copyWith(allItems: items));
  }

  Future<void> deleteProduce(String id) async {
    final repo = ref.read(produceRepositoryProvider);
    await repo.deleteProduce(id);
    final items = await repo.getAllProduce();
    state = AsyncData(state.value!.copyWith(allItems: items));
  }

  Future<void> addBatch(String produceId, BatchItem batch) async {
    final repo = ref.read(produceRepositoryProvider);
    await repo.addBatch(produceId, batch);
    final items = await repo.getAllProduce();
    state = AsyncData(state.value!.copyWith(allItems: items));
  }
}

final inventoryNotifierProvider = AsyncNotifierProvider<InventoryNotifier, InventoryState>(
  InventoryNotifier.new,
);
