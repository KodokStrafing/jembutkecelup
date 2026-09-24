import '../models/account_model.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../../core/services/database_service.dart';

class ExpenseRepository {
  final _db = DatabaseService.instance;

  Future<List<AccountModel>> getAccounts() async {
    final db = await _db.database;
    return (await db.query('accounts')).map(AccountModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final db = await _db.database;
    return (await db.query('categories')).map(CategoryModel.fromMap).toList();
  }

  Future<List<TransactionModel>> getTransactions() async {
    final db = await _db.database;
    return (await db.query('transactions', orderBy: 'date DESC'))
        .map(TransactionModel.fromMap).toList();
  }

  Future<List<BudgetModel>> getBudgets() async {
    final db = await _db.database;
    return (await db.query('budgets')).map(BudgetModel.fromMap).toList();
  }

  // ──────────────────────────────────────────────────────────── transactions

  Future<int> addTransaction(TransactionModel t) async {
    final db = await _db.database;
    final id = await db.insert('transactions', t.toInsertMap());
    await _adjustBalance(db, t.accountId, t.amount);
    return id;
  }

  Future<void> deleteTransaction(int id) async {
    final db = await _db.database;
    final rows = await db.query('transactions', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return;
    final tx = TransactionModel.fromMap(rows.first);
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
    // Reverse the balance effect when deleting a completed transaction.
    if (!tx.isScheduled) await _adjustBalance(db, tx.accountId, -tx.amount);
  }

  /// Called on app-load: finds every scheduled transaction whose target date
  /// is ≤ today AND (for recurring ones) hasn't been executed in this cycle.
  /// Applies amount to account, logs a completed copy, then advances the
  /// date on recurring ones.
  Future<List<TransactionModel>> executeOverdueScheduled() async {
    final db = await _db.database;
    final now = DateTime.now();
    final rows = await db.query('transactions', where: 'isScheduled = 1');
    final executed = <TransactionModel>[];

    for (final row in rows) {
      final tx = TransactionModel.fromMap(row);
      final isDue = !tx.date.isAfter(now);
      final alreadyRanToday = tx.lastExecuted != null &&
          _sameDay(tx.lastExecuted!, now);
      if (!isDue || alreadyRanToday) continue;

      // 1. Apply to balance.
      await _adjustBalance(db, tx.accountId, tx.amount);

      // 2. Log a completed copy.
      await db.insert('transactions', {
        ...tx.toInsertMap(),
        'isScheduled': 0,
        'recurrence': 'none',
        'date': now.toIso8601String(),
        'title': tx.title,
        'subtitle': 'Auto: ${tx.title}',
      });

      // 3. Advance or remove.
      if (tx.recurrence == 'none') {
        await db.delete('transactions', where: 'id = ?', whereArgs: [tx.id]);
      } else {
        final nextDate = _advance(tx.date, tx.recurrence);
        await db.update('transactions', {
          'date': nextDate.toIso8601String(),
          'lastExecuted': now.toIso8601String(),
        }, where: 'id = ?', whereArgs: [tx.id]);
      }
      executed.add(tx);
    }
    return executed;
  }

  DateTime _advance(DateTime from, String recurrence) {
    switch (recurrence) {
      case 'daily': return from.add(const Duration(days: 1));
      case 'weekly': return from.add(const Duration(days: 7));
      default: return DateTime(from.year, from.month + 1, from.day);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _adjustBalance(dynamic db, int? accountId, double delta) async {
    if (accountId == null) return;
    final rows = await db.query('accounts', where: 'id = ?', whereArgs: [accountId]);
    if (rows.isEmpty) return;
    final current = (rows.first['balance'] as num).toDouble();
    await db.update('accounts', {'balance': current + delta},
        where: 'id = ?', whereArgs: [accountId]);
  }

  // ────────────────────────────────────────────────────────────── accounts

  Future<int> addAccount(AccountModel a) async {
    final db = await _db.database;
    return db.insert('accounts', a.toInsertMap());
  }

  Future<void> deleteAccount(int id) async {
    final db = await _db.database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
    // Nullify accountId on all transactions that referenced this account
    // so they still appear in history without crashing.
    await db.update('transactions', {'accountId': null},
        where: 'accountId = ?', whereArgs: [id]);
  }

  // ────────────────────────────────────────────────────────────── budgets

  Future<int> addBudget(BudgetModel b) async {
    final db = await _db.database;
    return db.insert('budgets', b.toInsertMap());
  }

  Future<void> deleteBudget(int id) async {
    final db = await _db.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> setBudget(BudgetModel b) async {
    final db = await _db.database;
    final existing = await db.query('budgets',
        where: 'categoryId = ?', whereArgs: [b.categoryId]);
    if (existing.isNotEmpty) {
      await db.update('budgets', {'amount': b.amount, 'label': b.label},
          where: 'id = ?', whereArgs: [existing.first['id']]);
      return existing.first['id'] as int;
    }
    return db.insert('budgets', b.toInsertMap());
  }

  // ────────────────────────────────────────────────────────── categories

  Future<int> addCategory(CategoryModel c) async {
    final db = await _db.database;
    return db.insert('categories', c.toInsertMap());
  }

  Future<void> updateCategory(int id, String name) async {
    final db = await _db.database;
    await db.update('categories', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCategory(int id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
