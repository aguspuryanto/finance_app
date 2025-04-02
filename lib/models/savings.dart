class Savings {
  final int id;
  final String type;
  final double amount;
  final String date;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Savings({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Savings.fromJson(Map<String, dynamic> json) {
    return Savings(
      id: json['id'],
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'amount': amount,
    'date': date,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
} 