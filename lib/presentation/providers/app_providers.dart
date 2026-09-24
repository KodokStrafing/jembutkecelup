import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/prefs_service.dart';
import '../../data/models/account_model.dart';
import '../../data/models/budget_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/expense_repository.dart';

final repositoryProvider = Provider<ExpenseRepository>((_) => ExpenseRepository());

const _transferKeywords = ['top up', 'topup', 'transfer', 'isi ulang', 'recharge'];

class AppData {
  final List<AccountModel> accounts;
  final List<CategoryModel> categories;
  final List<TransactionModel> transactions;
  final List<BudgetModel> budgets;
  final bool isLoading;

  const AppData({
    this.accounts = const [], this.categories = const [],
    this.transactions = const [], this.budgets = const [],
    this.isLoading = true,
  });

  AppData copyWith({List<AccountModel>? accounts, List<CategoryModel>? categories,
      List<TransactionModel>? transactions, List<BudgetModel>? budgets, bool? isLoading}) =>
      AppData(
        accounts: accounts ?? this.accounts, categories: categories ?? this.categories,
        transactions: transactions ?? this.transactions, budgets: budgets ?? this.budgets,
        isLoading: isLoading ?? this.isLoading,
      );

  // ── groupings ────────────────────────────────────────────────────────────
  double get totalWealth => accounts.fold(0.0, (s, a) => s + a.balance);
  double get netWorth => totalWealth;

  List<AccountModel> get banks => accounts.where((a) => a.normalizedType == 'bank').toList();
  List<AccountModel> get ewallets => accounts.where((a) => a.normalizedType == 'ewallet').toList();
  List<AccountModel> get cashAccounts => accounts.where((a) => a.normalizedType == 'cash').toList();

  List<TransactionModel> get nonScheduled => transactions.where((t) => !t.isScheduled).toList();
  List<TransactionModel> get scheduled => transactions.where((t) => t.isScheduled).toList();

  List<TransactionModel> get allSortedNewestFirst {
    final l = List<TransactionModel>.from(transactions);
    l.sort((a, b) => b.date.compareTo(a.date));
    return l;
  }

  List<TransactionModel> get lastFive {
    final l = List<TransactionModel>.from(nonScheduled);
    l.sort((a, b) => b.date.compareTo(a.date));
    return l.take(5).toList();
  }

  bool isTransfer(TransactionModel t) {
    final text = '${t.title} ${t.subtitle ?? ''} ${t.note ?? ''}'.toLowerCase();
    return _transferKeywords.any(text.contains);
  }

  double get monthIncome => nonScheduled
      .where((t) => t.type == 'income')
      .fold(0.0, (s, t) => s + t.amount);

  double get monthExpense => nonScheduled
      .where((t) => t.type == 'expense' && !isTransfer(t))
      .fold(0.0, (s, t) => s + t.amount.abs());

  double get cashFlow => monthIncome - monthExpense;

  CategoryModel? categoryFor(int? id) {
    if (id == null) return null;
    for (final c in categories) { if (c.id == id) return c; }
    return null;
  }

  AccountModel? accountFor(int? id) {
    if (id == null) return null;
    for (final a in accounts) { if (a.id == id) return a; }
    return null;
  }

  double spentOnBudget(BudgetModel budget) {
    final start = budget.currentPeriodStart();
    final end = budget.currentPeriodEnd();
    double spent = 0;
    for (final t in nonScheduled) {
      if (t.categoryId != budget.categoryId) continue;
      if (!t.isExpense || isTransfer(t)) continue;
      if (t.date.isBefore(start) || !t.date.isBefore(end)) continue;
      spent += t.amount.abs();
    }
    return spent;
  }
}

class AppDataNotifier extends StateNotifier<AppData> {
  final ExpenseRepository repository;
  AppDataNotifier(this.repository) : super(const AppData()) { _init(); }

  Future<void> _init() async {
    // Execute overdue scheduled transactions first, then load fresh state.
    await repository.executeOverdueScheduled();
    await refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final accounts = await repository.getAccounts();
    final categories = await repository.getCategories();
    final transactions = await repository.getTransactions();
    final budgets = await repository.getBudgets();
    state = AppData(
      accounts: accounts, categories: categories,
      transactions: transactions, budgets: budgets, isLoading: false,
    );
  }

  Future<void> addTransaction(TransactionModel t) async {
    await repository.addTransaction(t); await refresh();
  }

  Future<void> deleteTransaction(int id) async {
    await repository.deleteTransaction(id); await refresh();
  }

  Future<void> addAccount(AccountModel a) async {
    await repository.addAccount(a); await refresh();
  }

  Future<void> deleteAccount(int id) async {
    await repository.deleteAccount(id); await refresh();
  }

  Future<void> addBudget(BudgetModel b) async {
    await repository.addBudget(b); await refresh();
  }

  Future<void> setBudget(BudgetModel b) async {
    await repository.setBudget(b); await refresh();
  }

  Future<void> deleteBudget(int id) async {
    await repository.deleteBudget(id); await refresh();
  }

  Future<void> addCategory(CategoryModel c) async {
    await repository.addCategory(c); await refresh();
  }

  Future<void> updateCategory(int id, String name) async {
    await repository.updateCategory(id, name); await refresh();
  }

  Future<void> deleteCategory(int id) async {
    await repository.deleteCategory(id); await refresh();
  }
}

final appDataProvider = StateNotifierProvider<AppDataNotifier, AppData>(
    (ref) => AppDataNotifier(ref.watch(repositoryProvider)));

final navIndexProvider = StateProvider<int>((_) => 0);

// ── Settings ─────────────────────────────────────────────────────────────

class SettingsState {
  final bool darkMode;
  final String language;
  final double budgetLimit;
  final double savingsTarget;
  final double currentSavings;
  final bool isLoading;

  const SettingsState({
    this.darkMode = true, this.language = 'en', this.budgetLimit = 2000000,
    this.savingsTarget = 5000000, this.currentSavings = 0, this.isLoading = true,
  });

  SettingsState copyWith({bool? darkMode, String? language, double? budgetLimit,
      double? savingsTarget, double? currentSavings, bool? isLoading}) =>
      SettingsState(
        darkMode: darkMode ?? this.darkMode, language: language ?? this.language,
        budgetLimit: budgetLimit ?? this.budgetLimit, savingsTarget: savingsTarget ?? this.savingsTarget,
        currentSavings: currentSavings ?? this.currentSavings, isLoading: isLoading ?? this.isLoading,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final _p = PrefsService.instance;
  SettingsNotifier() : super(const SettingsState()) { _load(); }

  Future<void> _load() async {
    state = SettingsState(
      darkMode: await _p.getDarkMode(), language: await _p.getLanguage(),
      budgetLimit: await _p.getBudgetLimit(), savingsTarget: await _p.getSavingsTarget(),
      currentSavings: await _p.getCurrentSavings(), isLoading: false,
    );
  }

  Future<void> setDarkMode(bool v) async { state = state.copyWith(darkMode: v); await _p.setDarkMode(v); }
  Future<void> setLanguage(String v) async { state = state.copyWith(language: v); await _p.setLanguage(v); }
  Future<void> setBudgetLimit(double v) async { state = state.copyWith(budgetLimit: v); await _p.setBudgetLimit(v); }
  Future<void> setSavingsTarget(double v) async { state = state.copyWith(savingsTarget: v); await _p.setSavingsTarget(v); }
  Future<void> setCurrentSavings(double v) async { state = state.copyWith(currentSavings: v); await _p.setCurrentSavings(v); }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
    (_) => SettingsNotifier());
