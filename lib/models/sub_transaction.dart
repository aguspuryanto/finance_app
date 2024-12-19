class SubTransaction {
  final int id;
  final int transactionId;
  final String title;
  final double amount;
  final String date;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubTransaction({
    required this.id,
    required this.transactionId,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'transaction_id': transactionId,
        'title': title,
        'amount': amount,
        'date': date,
        'notes': notes,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory SubTransaction.fromJson(Map<String, dynamic> json) => SubTransaction(
        id: json['id'],
        transactionId: json['transaction_id'],
        title: json['title'],
        amount: json['amount'].toDouble(),
        date: json['date'],
        notes: json['notes'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );
} 