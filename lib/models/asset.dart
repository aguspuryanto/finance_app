class Asset {
  final int? id;
  final String name;
  final double purchaseValue;
  final double? creditValue;
  final double currentValue;
  final String purchaseDate;
  final String status;
  final String? notes;

  Asset({
    this.id,
    required this.name,
    required this.purchaseValue,
    this.creditValue,
    required this.currentValue,
    required this.purchaseDate,
    required this.status,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchase_value': purchaseValue,
      'credit_value': creditValue,
      'current_value': currentValue,
      'purchase_date': purchaseDate,
      'status': status,
      'notes': notes,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      name: map['name'],
      purchaseValue: map['purchase_value'],
      creditValue: map['credit_value'],
      currentValue: map['current_value'],
      purchaseDate: map['purchase_date'],
      status: map['status'] ?? 'Lunas',
      notes: map['notes'],
    );
  }
} 