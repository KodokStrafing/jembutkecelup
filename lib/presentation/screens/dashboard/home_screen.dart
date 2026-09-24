import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_localizations.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/forms/add_transaction_form.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_progress_bar.dart';
import '../../widgets/glass/glass_scaffold.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data     = ref.watch(appDataProvider);
    final settings = ref.watch(settingsProvider);
    final lang     = settings.language;

    if (data.isLoading || settings.isLoading) {
      return const GlassScaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final monthlySpent    = data.monthExpense;
    final monthlyLimit    = settings.budgetLimit;
    final monthlyProgress = monthlyLimit == 0 ? 0.0 : monthlySpent / monthlyLimit;

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text(AppLocalizations.t(lang, 'navHome'), style: AppTypography.displayMedium),
          const SizedBox(height: 16),

          // 1 ── Cash Flow ───────────────────────────────────────────────
          GlassContainer(
            borderRadius: 22, depthLayer: 2,
            padding: const EdgeInsets.all(22),
            margin: const EdgeInsets.only(bottom: 14),
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.t(lang, 'cashFlow'), style: AppTypography.bodyMedium),
              const SizedBox(height: 8),
              Text(formatIdr(data.cashFlow), style: AppTypography.displayLarge,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              Wrap(spacing: 20, runSpacing: 6, children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_upward, color: Color(0xFF6EE7B7), size: 15),
                  const SizedBox(width: 4),
                  Text(formatIdr(data.monthIncome), style: AppTypography.amountMedium()),
                ]),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_downward, color: Color(0xFFFF6B6B), size: 15),
                  const SizedBox(width: 4),
                  Text('-${formatIdr(data.monthExpense)}',
                      style: AppTypography.amountMedium(isExpense: true)),
                ]),
              ]),
            ]),
          ),

          // 2 ── Net Worth ───────────────────────────────────────────────
          GlassContainer(
            borderRadius: 22, depthLayer: 2,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Net Worth', style: AppTypography.bodyMedium),
                  const SizedBox(height: 4),
                  Text(formatIdr(data.netWorth), style: AppTypography.displayMedium),
                ]),
                Text('${data.accounts.length} account${data.accounts.length == 1 ? '' : 's'}',
                    style: AppTypography.bodySmall),
              ],
            ),
          ),

          // 3 ── Monthly Budget ──────────────────────────────────────────
          GlassContainer(
            borderRadius: 22, depthLayer: 2,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('My Monthly Budget', style: AppTypography.bodyMedium),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(
                  child: Text(
                    '${formatIdr(monthlySpent)} / ${formatIdr(monthlyLimit)}',
                    style: AppTypography.titleMedium.copyWith(
                        color: monthlyProgress > 1 ? const Color(0xFFFF6B6B) : Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${formatIdr((monthlyLimit - monthlySpent).clamp(0, monthlyLimit))} left',
                  style: AppTypography.bodySmall,
                ),
              ]),
              const SizedBox(height: 8),
              GlassProgressBar(progress: monthlyProgress),
            ]),
          ),

          // Budget reminders
          if (data.budgets.isNotEmpty) ...[
            Text('Budget Reminders', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            for (final b in data.budgets) _BudgetReminderCard(budget: b, data: data),
            const SizedBox(height: 4),
          ],

          // 4 ── Last 5 Transactions ─────────────────────────────────────
          Text('Last 5 Transactions', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          if (data.lastFive.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No transactions yet.', style: AppTypography.bodyMedium),
            )
          else
            for (final t in data.lastFive)
              GlassTransactionItem(
                transaction: t, category: data.categoryFor(t.categoryId),
                onLongPress: () => _confirmDelete(context, ref, t.id),
              ),

          const SizedBox(height: 6),

          // 5 ── Add Transaction ─────────────────────────────────────────
          const AddTransactionForm(),
          const SizedBox(height: 20),

          // 6 ── Scheduled Transactions ──────────────────────────────────
          Text(AppLocalizations.t(lang, 'scheduled'), style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          if (data.scheduled.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No scheduled transactions.', style: AppTypography.bodyMedium),
            )
          else
            for (final t in data.scheduled)
              _ScheduledRow(transaction: t, data: data, ref: ref),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    final lang = ref.read(settingsProvider).language;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: Text(AppLocalizations.t(lang, 'deleteTransactionTitle'),
            style: const TextStyle(color: Colors.white)),
        content: Text(AppLocalizations.t(lang, 'deleteTransactionBody'),
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.t(lang, 'cancel'))),
          TextButton(
            onPressed: () {
              ref.read(appDataProvider.notifier).deleteTransaction(id);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.t(lang, 'delete'),
                style: const TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}

class _BudgetReminderCard extends StatelessWidget {
  final BudgetModel budget;
  final AppData data;
  const _BudgetReminderCard({required this.budget, required this.data});

  @override
  Widget build(BuildContext context) {
    final spent     = data.spentOnBudget(budget);
    final remaining = budget.amount - spent;
    final progress  = budget.amount == 0 ? 0.0 : spent / budget.amount;
    final daysLeft  = budget.daysRemaining();
    final Color col = progress > 1.0 ? const Color(0xFFFF6B6B)
        : progress >= 0.8 ? const Color(0xFFFBBF24) : const Color(0xFF6EE7B7);

    return GlassContainer(
      borderRadius: 18, depthLayer: 1,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(budget.label, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
                color: col.withValues(alpha: 0.2)),
            child: Text(progress > 1.0 ? 'Exceeded' : progress >= 0.8 ? 'Close' : 'On track',
                style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 4),
        Text(
          '${formatIdr(remaining.abs())} ${remaining >= 0 ? 'remaining' : 'over'}  ·  ${formatIdr(spent)} / ${formatIdr(budget.amount)} spent  ·  $daysLeft days left',
          style: AppTypography.bodySmall,
        ),
        const SizedBox(height: 8),
        GlassProgressBar(progress: progress),
      ]),
    );
  }
}

class _ScheduledRow extends StatelessWidget {
  final TransactionModel transaction;
  final AppData data;
  final WidgetRef ref;
  const _ScheduledRow({required this.transaction, required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    final account  = data.accountFor(transaction.accountId);
    final isExpense = transaction.isExpense;
    final recLabel = _recLabel(transaction.recurrence);

    return GlassContainer(
      depthLayer: 1, borderRadius: 18,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(transaction.title, style: AppTypography.titleMedium),
            Text(
              '${DateFormat('d MMM yyyy').format(transaction.date)}'
              '${account != null ? '  ·  ${account.name}' : ''}'
              '${recLabel.isNotEmpty ? '  ·  $recLabel' : ''}',
              style: AppTypography.bodySmall,
            ),
          ]),
        ),
        const SizedBox(width: 8),
        Text(
          '${isExpense ? '-' : ''}${formatIdr(transaction.amount)}',
          style: AppTypography.amountMedium(isExpense: isExpense),
        ),
        const SizedBox(width: 6),
        // ✕ DELETE button — previously non-functional; now wired to deleteTransaction.
        GestureDetector(
          onTap: () => _confirmDelete(context),
          child: Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.2),
            ),
            child: const Icon(Icons.close, color: Colors.redAccent, size: 16),
          ),
        ),
      ]),
    );
  }

  String _recLabel(String r) {
    switch (r) {
      case 'daily':   return 'Daily';
      case 'weekly':  return 'Weekly';
      case 'monthly': return 'Monthly';
      default:        return '';
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1B4B),
        title: const Text('Delete scheduled transaction?', style: TextStyle(color: Colors.white)),
        content: const Text("This can't be undone.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(appDataProvider.notifier).deleteTransaction(transaction.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B))),
          ),
        ],
      ),
    );
  }
}
