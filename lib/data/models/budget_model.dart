class BudgetModel {
  final int id;
  final int? categoryId;
  final String label;
  final double amount;
  final String period;
  final DateTime startDate;
  final String? description;

  BudgetModel({
    required this.id, this.categoryId, required this.label,
    required this.amount, this.period = 'monthly',
    required this.startDate, this.description,
  });

  factory BudgetModel.fromMap(Map<String, dynamic> map) => BudgetModel(
        id: map['id'] as int, categoryId: map['categoryId'] as int?,
        label: map['label'] as String, amount: (map['amount'] as num).toDouble(),
        period: (map['period'] as String?) ?? 'monthly',
        startDate: map['startDate'] != null
            ? DateTime.parse(map['startDate'] as String) : DateTime.now(),
        description: map['description'] as String?,
      );

  Map<String, dynamic> toInsertMap() => {
        'categoryId': categoryId, 'label': label, 'amount': amount,
        'period': period, 'startDate': startDate.toIso8601String(),
        'description': description,
      };

  DateTime _advance(DateTime from) {
    switch (period) {
      case 'daily': return from.add(const Duration(days: 1));
      case 'weekly': return from.add(const Duration(days: 7));
      default: return DateTime(from.year, from.month + 1, from.day);
    }
  }

  DateTime currentPeriodStart([DateTime? now]) {
    final n = now ?? DateTime.now();
    DateTime s = startDate;
    DateTime e = _advance(s);
    for (var i = 0; e.isBefore(n) && i < 10000; i++) { s = e; e = _advance(s); }
    return s;
  }

  DateTime currentPeriodEnd([DateTime? now]) => _advance(currentPeriodStart(now));

  int daysRemaining([DateTime? now]) {
    final n = now ?? DateTime.now();
    return currentPeriodEnd(n).difference(n).inDays.clamp(0, 1 << 30);
  }
}
