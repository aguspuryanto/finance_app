class SavingsDetail {
  final int id;
  final int savingsId;
  final double targetAmount;
  final int durationMonths;
  final double monthlyAmount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavingsDetail({
    required this.id,
    required this.savingsId,
    required this.targetAmount,
    required this.durationMonths,
    required this.monthlyAmount,
    this.createdAt,
    this.updatedAt,
  });

  factory SavingsDetail.fromJson(Map<String, dynamic> json) {
    return SavingsDetail(
      id: json['id'],
      savingsId: json['savings_id'],
      targetAmount: (json['target_amount'] ?? 0).toDouble(),
      durationMonths: json['duration_months'] ?? 0,
      monthlyAmount: (json['monthly_amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'savings_id': savingsId,
    'target_amount': targetAmount,
    'duration_months': durationMonths,
    'monthly_amount': monthlyAmount,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  static List<int> get availableDurations => [6, 12, 24, 36, 48];
} 