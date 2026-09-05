class BatchItem {
  final String id;
  final DateTime receivedDate;
  final double quantityReceived;
  final double quantityRemaining;
  final String supplierName;
  final double costPerUnit;

  const BatchItem({
    required this.id,
    required this.receivedDate,
    required this.quantityReceived,
    required this.quantityRemaining,
    required this.supplierName,
    required this.costPerUnit,
  });

  BatchItem copyWith({
    String? id,
    DateTime? receivedDate,
    double? quantityReceived,
    double? quantityRemaining,
    String? supplierName,
    double? costPerUnit,
  }) {
    return BatchItem(
      id: id ?? this.id,
      receivedDate: receivedDate ?? this.receivedDate,
      quantityReceived: quantityReceived ?? this.quantityReceived,
      quantityRemaining: quantityRemaining ?? this.quantityRemaining,
      supplierName: supplierName ?? this.supplierName,
      costPerUnit: costPerUnit ?? this.costPerUnit,
    );
  }
}
