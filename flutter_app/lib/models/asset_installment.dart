class AssetInstallment {
  final int? id;
  final int assetId;
  final double amount;
  final String dueDate;
  final bool isPaid;
  final String? paidDate;
  final String? notes;

  AssetInstallment({
    this.id,
    required this.assetId,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.paidDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'asset_id': assetId,
      'amount': amount,
      'due_date': dueDate,
      'is_paid': isPaid,
      'paid_date': paidDate,
      'notes': notes,
    };
  }

  factory AssetInstallment.fromMap(Map<String, dynamic> map) {
    return AssetInstallment(
      id: map['id'],
      assetId: map['asset_id'],
      amount: map['amount'],
      dueDate: map['due_date'],
      isPaid: map['is_paid'] ?? false,
      paidDate: map['paid_date'],
      notes: map['notes'],
    );
  }
} 