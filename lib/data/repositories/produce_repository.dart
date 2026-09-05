import '../models/produce_item.dart';
import '../models/produce_category.dart';
import '../models/waste_record.dart';
import '../models/batch_item.dart';
import 'mock_produce_data.dart';

abstract class ProduceRepository {
  Future<List<ProduceItem>> getAllProduce();
  Future<List<ProduceItem>> getProduceByCategory(ProduceCategory category);
  Future<ProduceItem?> getProduceById(String id);
  Future<void> addProduce(ProduceItem item);
  Future<void> updateProduce(ProduceItem item);
  Future<void> deleteProduce(String id);
  Future<void> recordWaste(WasteRecord wasteRecord);
  Future<List<WasteRecord>> getAllWasteRecords();
  Future<void> processSale(String produceId, double quantitySold);
  Future<void> addBatch(String produceId, BatchItem batch);
}

class InMemoryProduceRepository implements ProduceRepository {
  final List<ProduceItem> _items = MockProduceData.getInitialProduce();
  final List<WasteRecord> _wasteRecords = MockProduceData.getInitialWasteRecords();

  @override
  Future<List<ProduceItem>> getAllProduce() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<List<ProduceItem>> getProduceByCategory(ProduceCategory category) async {
    if (category == ProduceCategory.all) return List.unmodifiable(_items);
    return _items.where((i) => i.category == category).toList();
  }

  @override
  Future<ProduceItem?> getProduceById(String id) async {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addProduce(ProduceItem item) async {
    _items.insert(0, item);
  }

  @override
  Future<void> updateProduce(ProduceItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
    }
  }

  @override
  Future<void> deleteProduce(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> recordWaste(WasteRecord wasteRecord) async {
    _wasteRecords.insert(0, wasteRecord);
    final index = _items.indexWhere((i) => i.id == wasteRecord.produceId);
    if (index != -1) {
      final current = _items[index];
      final newStock = (current.currentStock - wasteRecord.quantityWasted).clamp(0.0, 99999.0);
      _items[index] = current.copyWith(currentStock: newStock);
    }
  }

  @override
  Future<List<WasteRecord>> getAllWasteRecords() async {
    return List.unmodifiable(_wasteRecords);
  }

  @override
  Future<void> processSale(String produceId, double quantitySold) async {
    final index = _items.indexWhere((i) => i.id == produceId);
    if (index != -1) {
      final current = _items[index];
      final newStock = (current.currentStock - quantitySold).clamp(0.0, 99999.0);
      _items[index] = current.copyWith(currentStock: newStock);
    }
  }

  @override
  Future<void> addBatch(String produceId, BatchItem batch) async {
    final index = _items.indexWhere((i) => i.id == produceId);
    if (index != -1) {
      final current = _items[index];
      final updatedBatches = List<BatchItem>.from(current.batches)..insert(0, batch);
      final newStock = current.currentStock + batch.quantityReceived;
      _items[index] = current.copyWith(
        currentStock: newStock,
        batches: updatedBatches,
      );
    }
  }
}
