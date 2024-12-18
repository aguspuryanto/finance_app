class Asset {
  final int? id;
  final String name;
  final double purchaseValue;
  final double currentValue;
  final String purchaseDate;
  final String? notes;

  Asset({
    this.id,
    required this.name,
    required this.purchaseValue,
    required this.currentValue,
    required this.purchaseDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchase_value': purchaseValue,
      'current_value': currentValue,
      'purchase_date': purchaseDate,
      'notes': notes,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['id'],
      name: map['name'],
      purchaseValue: map['purchase_value'],
      currentValue: map['current_value'],
      purchaseDate: map['purchase_date'],
      notes: map['notes'],
    );
  }
} 