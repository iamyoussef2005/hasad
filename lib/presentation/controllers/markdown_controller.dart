import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/markdown_proposal.dart';
import '../../domain/services/smart_markdown_engine.dart';
import 'inventory_controller.dart';

class MarkdownState {
  final List<MarkdownProposal> proposals;
  final Set<String> appliedItemIds;
  final double totalPreventedLoss;
  final double totalRecoveredRevenue;
  final bool isProcessing;

  const MarkdownState({
    this.proposals = const [],
    this.appliedItemIds = const {},
    this.totalPreventedLoss = 0.0,
    this.totalRecoveredRevenue = 0.0,
    this.isProcessing = false,
  });

  int get pendingCount => proposals.length;
  int get criticalCount => proposals.where((p) => p.urgency == MarkdownUrgency.critical).length;

  MarkdownState copyWith({
    List<MarkdownProposal>? proposals,
    Set<String>? appliedItemIds,
    double? totalPreventedLoss,
    double? totalRecoveredRevenue,
    bool? isProcessing,
  }) {
    return MarkdownState(
      proposals: proposals ?? this.proposals,
      appliedItemIds: appliedItemIds ?? this.appliedItemIds,
      totalPreventedLoss: totalPreventedLoss ?? this.totalPreventedLoss,
      totalRecoveredRevenue: totalRecoveredRevenue ?? this.totalRecoveredRevenue,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class MarkdownNotifier extends Notifier<MarkdownState> {
  @override
  MarkdownState build() {
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final items = inventoryAsync.value?.allItems ?? [];
    final proposals = SmartMarkdownEngine.generateProposals(items);

    return MarkdownState(
      proposals: proposals,
      totalPreventedLoss: proposals.fold(0.0, (sum, p) => sum + p.projectedWasteLoss),
      totalRecoveredRevenue: proposals.fold(0.0, (sum, p) => sum + p.potentialRecoveredRevenue),
    );
  }

  Future<void> applyMarkdown(MarkdownProposal proposal) async {
    final repo = ref.read(produceRepositoryProvider);
    final item = await repo.getProduceById(proposal.produceId);
    if (item == null) return;

    final updated = item.copyWith(
      sellingPrice: proposal.recommendedPrice,
      originalPrice: item.originalPrice ?? proposal.currentSellingPrice,
      isMarkdownActive: true,
      discountPercentage: proposal.discountPercent,
    );

    await repo.updateProduce(updated);

    final newApplied = Set<String>.from(state.appliedItemIds)..add(proposal.produceId);
    state = state.copyWith(
      appliedItemIds: newApplied,
      proposals: state.proposals.where((p) => p.produceId != proposal.produceId).toList(),
    );

    ref.invalidate(inventoryNotifierProvider);
  }

  Future<void> removeMarkdown(String produceId) async {
    final repo = ref.read(produceRepositoryProvider);
    final item = await repo.getProduceById(produceId);
    if (item == null) return;

    final updated = item.copyWith(
      sellingPrice: item.originalPrice ?? item.sellingPrice,
      originalPrice: null,
      isMarkdownActive: false,
      discountPercentage: 0.0,
    );

    await repo.updateProduce(updated);

    final newApplied = Set<String>.from(state.appliedItemIds)..remove(produceId);
    state = state.copyWith(appliedItemIds: newApplied);

    ref.invalidate(inventoryNotifierProvider);
  }

  Future<void> applyAllProposals() async {
    state = state.copyWith(isProcessing: true);
    final list = List<MarkdownProposal>.from(state.proposals);
    for (final proposal in list) {
      await applyMarkdown(proposal);
    }
    state = state.copyWith(isProcessing: false);
  }
}

final markdownNotifierProvider = NotifierProvider<MarkdownNotifier, MarkdownState>(
  MarkdownNotifier.new,
);
