class SubTransaction {
  final int id;
  final int transactionId;
  final String title;
  final double amount;
  final String date;
  final String? notes;

  SubTransaction({
    required this.id,
    required this.transactionId,
    required this.title,
    required this.amount,
    required this.date,
    this.notes,
  });

  factory SubTransaction.fromJson(Map<String, dynamic> json) {
    return SubTransaction(
      id: json['id'],
      transactionId: json['transaction_id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: json['date'],
      notes: json['notes'],
    );
  }
} 