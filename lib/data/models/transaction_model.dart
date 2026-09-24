class TransactionModel {
  final int id;
  final String title;
  final String? subtitle;
  final double amount;
  final String type;
  final int? categoryId;
  final int? accountId;
  final DateTime date;
  final String? note;
  final bool isScheduled;
  /// 'none' | 'daily' | 'weekly' | 'monthly'
  final String recurrence;
  /// When auto-execution last fired for this scheduled transaction.
  final DateTime? lastExecuted;

  TransactionModel({
    required this.id, required this.title, this.subtitle,
    required this.amount, required this.type,
    this.categoryId, this.accountId, required this.date,
    this.note, this.isScheduled = false,
    this.recurrence = 'none', this.lastExecuted,
  });

  bool get isExpense => type == 'expense';

  factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
        id: map['id'] as int, title: map['title'] as String,
        subtitle: map['subtitle'] as String?, amount: (map['amount'] as num).toDouble(),
        type: map['type'] as String, categoryId: map['categoryId'] as int?,
        accountId: map['accountId'] as int?, date: DateTime.parse(map['date'] as String),
        note: map['note'] as String?, isScheduled: (map['isScheduled'] as int) == 1,
        recurrence: (map['recurrence'] as String?) ?? 'none',
        lastExecuted: map['lastExecuted'] != null
            ? DateTime.parse(map['lastExecuted'] as String) : null,
      );

  Map<String, dynamic> toInsertMap() => {
        'title': title, 'subtitle': subtitle, 'amount': amount, 'type': type,
        'categoryId': categoryId, 'accountId': accountId,
        'date': date.toIso8601String(), 'note': note,
        'isScheduled': isScheduled ? 1 : 0,
        'recurrence': recurrence,
        'lastExecuted': lastExecuted?.toIso8601String(),
      };

  TransactionModel copyWith({DateTime? lastExecuted}) => TransactionModel(
        id: id, title: title, subtitle: subtitle, amount: amount, type: type,
        categoryId: categoryId, accountId: accountId, date: date, note: note,
        isScheduled: isScheduled, recurrence: recurrence,
        lastExecuted: lastExecuted ?? this.lastExecuted,
      );
}
