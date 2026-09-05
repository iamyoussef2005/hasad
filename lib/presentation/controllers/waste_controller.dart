import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/waste_record.dart';
import 'inventory_controller.dart';

class WasteState {
  final List<WasteRecord> records;
  final bool isLoading;

  const WasteState({
    required this.records,
    this.isLoading = false,
  });

  double get totalFinancialLoss => records.fold(0.0, (sum, r) => sum + r.financialLoss);
  double get totalQuantityWasted => records.fold(0.0, (sum, r) => sum + r.quantityWasted);

  Map<WasteReason, double> get lossByReason {
    final map = <WasteReason, double>{};
    for (final r in records) {
      map[r.reason] = (map[r.reason] ?? 0.0) + r.financialLoss;
    }
    return map;
  }

  WasteState copyWith({
    List<WasteRecord>? records,
    bool? isLoading,
  }) {
    return WasteState(
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WasteNotifier extends AsyncNotifier<WasteState> {
  @override
  Future<WasteState> build() async {
    final repo = ref.read(produceRepositoryProvider);
    final records = await repo.getAllWasteRecords();
    return WasteState(records: records);
  }

  Future<void> recordWaste(WasteRecord record) async {
    final repo = ref.read(produceRepositoryProvider);
    await repo.recordWaste(record);
    final records = await repo.getAllWasteRecords();
    state = AsyncData(state.value!.copyWith(records: records));
    // Refresh inventory state as stock was reduced
    ref.invalidate(inventoryNotifierProvider);
  }
}

final wasteNotifierProvider = AsyncNotifierProvider<WasteNotifier, WasteState>(
  WasteNotifier.new,
);
