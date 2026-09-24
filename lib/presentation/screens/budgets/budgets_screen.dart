import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_localizations.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/budget_model.dart';
import '../../../data/models/category_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_progress_bar.dart';
import '../../widgets/glass/glass_scaffold.dart';
import '../../widgets/orbital/orbital_icon.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data     = ref.watch(appDataProvider);
    final settings = ref.watch(settingsProvider);
    final lang     = settings.language;

    if (data.isLoading || settings.isLoading) {
      return const GlassScaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Header row with + button top-right
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppLocalizations.t(lang, 'navBudgets'), style: AppTypography.displayMedium),
            GestureDetector(
              onTap: () => _showCreateBudgetSheet(context, ref, data),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF10B981).withValues(alpha: 0.22),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // Overall monthly budget
          _OverallBudgetCard(data: data, lang: lang),
          const SizedBox(height: 20),

          // Named/period budgets (created via +)
          if (data.budgets.isNotEmpty) ...[
            Text('My Budgets', style: AppTypography.titleLarge),
            const SizedBox(height: 10),
            for (final b in data.budgets) _NamedBudgetCard(budget: b, data: data, ref: ref),
            const SizedBox(height: 14),
          ],

          // Per-category quick-set + category management
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(AppLocalizations.t(lang, 'setABudget'), style: AppTypography.titleLarge),
            TextButton.icon(
              onPressed: () => _showAddCategorySheet(context, ref),
              icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
              label: const Text('Add Category', style: TextStyle(color: Color(0xFF10B981), fontSize: 13)),
            ),
          ]),
          const SizedBox(height: 8),
          GlassContainer(
            borderRadius: 20, depthLayer: 2, padding: const EdgeInsets.all(16),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Category', style: AppTypography.bodySmall),
                Text('Budget / month', style: AppTypography.bodySmall),
              ]),
              const SizedBox(height: 12),
              for (final c in data.categories.where((c) => c.type == 'expense'))
                _CategoryBudgetRow(category: c, data: data, ref: ref),
            ]),
          ),

          const SizedBox(height: 20),
          _SavingsGoalCard(settings: settings, lang: lang),
        ],
      ),
    );
  }

  // ── Create Budget sheet ───────────────────────────────────────────────
  void _showCreateBudgetSheet(BuildContext context, WidgetRef ref, AppData data) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final amtCtrl  = TextEditingController();
    String period  = 'monthly';
    DateTime start = DateTime.now();
    final expCats  = data.categories.where((c) => c.type == 'expense').toList();
    int? catId     = expCats.isNotEmpty ? expCats.first.id : null;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Create Budget', style: AppTypography.titleLarge),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Budget name', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 12),
            if (expCats.isNotEmpty)
              DropdownButtonFormField<int>(
                initialValue: catId, dropdownColor: const Color(0xFF1E1B4B),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.white70)),
                items: expCats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (v) => setS(() => catId = v),
              ),
            const SizedBox(height: 12),
            Text('Period', style: AppTypography.bodySmall),
            const SizedBox(height: 6),
            Row(children: [
              for (final p in [('Daily', 'daily'), ('Weekly', 'weekly'), ('Monthly', 'monthly')]) ...[
                Expanded(child: _periodChip(p.$1, period == p.$2, () => setS(() => period = p.$2))),
                if (p.$2 != 'monthly') const SizedBox(width: 8),
              ],
            ]),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(context: ctx, initialDate: start,
                    firstDate: DateTime(2020), lastDate: DateTime(2100));
                if (picked != null) setS(() => start = picked);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.25)))),
                child: Row(children: [
                  const Icon(Icons.calendar_today, color: Colors.white60, size: 15),
                  const SizedBox(width: 10),
                  Text('Start: ${DateFormat('EEE, d MMM yyyy').format(start)}',
                      style: const TextStyle(color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            TextField(controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(prefixText: 'IDR ', prefixStyle: TextStyle(color: Colors.white70),
                    labelText: 'Amount', labelStyle: TextStyle(color: Colors.white70))),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity,
              child: GlassButton(
                tint: const Color(0xFF10B981), onPressed: () {
                  final name = nameCtrl.text.trim();
                  final amt  = double.tryParse(amtCtrl.text.trim());
                  if (name.isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Name required.'))); return; }
                  if (amt == null || amt <= 0) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Enter a valid amount.'))); return; }
                  ref.read(appDataProvider.notifier).addBudget(BudgetModel(
                    id: 0, categoryId: catId, label: name, amount: amt,
                    period: period, startDate: start, description: descCtrl.text.trim(),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Center(child: Text('Create Budget', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
              ),
            ),
          ])),
        );
      }),
    );
  }

  // ── Add custom expense category sheet ─────────────────────────────────
  void _showAddCategorySheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add Budget Category', style: AppTypography.titleLarge),
          const SizedBox(height: 14),
          TextField(controller: nameCtrl, autofocus: true, style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Category name', labelStyle: TextStyle(color: Colors.white70))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity,
            child: GlassButton(
              tint: const Color(0xFF10B981), onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                ref.read(appDataProvider.notifier).addCategory(CategoryModel(
                  id: 0, name: name, icon: 'category', colorValue: 0xFF10B981, type: 'expense',
                ));
                Navigator.pop(ctx);
              },
              child: const Center(child: Text('Add Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _periodChip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xFF10B981).withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: selected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13))),
      ));
}

// ── Overall monthly budget limit ─────────────────────────────────────────
class _OverallBudgetCard extends ConsumerWidget {
  final AppData data; final String lang;
  const _OverallBudgetCard({required this.data, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final spent = data.monthExpense; final limit = s.budgetLimit;
    final prog  = limit == 0 ? 0.0 : spent / limit;

    return GlassContainer(borderRadius: 20, depthLayer: 2, padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppLocalizations.t(lang, 'overallBudget'), style: AppTypography.bodySmall),
          GestureDetector(
            onTap: () => _editLimit(context, ref, limit),
            child: Row(children: [
              Text('${AppLocalizations.t(lang, 'limit')} ${formatIdr(limit)}', style: AppTypography.bodySmall),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 12, color: Colors.white38),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text('${formatIdr(spent)} / ${formatIdr(limit)} ${AppLocalizations.t(lang, 'spent')}',
            style: AppTypography.titleMedium.copyWith(color: prog > 1 ? const Color(0xFFFF6B6B) : Colors.white)),
        if (prog > 1) Text('⚠ ${AppLocalizations.t(lang, 'overBudget')}',
            style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 11)),
        const SizedBox(height: 10),
        GlassProgressBar(progress: prog),
      ]),
    );
  }

  void _editLimit(BuildContext context, WidgetRef ref, double cur) {
    final ctrl = TextEditingController(text: cur > 0 ? cur.toStringAsFixed(0) : '');
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text(AppLocalizations.t(lang, 'overallBudget'), style: const TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(prefixText: 'IDR ', prefixStyle: TextStyle(color: Colors.white70))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final v = double.tryParse(ctrl.text) ?? 0;
          ref.read(settingsProvider.notifier).setBudgetLimit(v);
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }
}

// ── Named, period-aware budget card ──────────────────────────────────────
class _NamedBudgetCard extends StatelessWidget {
  final BudgetModel budget; final AppData data; final WidgetRef ref;
  const _NamedBudgetCard({required this.budget, required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    final cat      = data.categoryFor(budget.categoryId);
    final spent    = data.spentOnBudget(budget);
    final rem      = budget.amount - spent;
    final prog     = budget.amount == 0 ? 0.0 : spent / budget.amount;
    final daysLeft = budget.daysRemaining();
    final Color col = prog > 1.0 ? const Color(0xFFFF6B6B) : prog >= 0.8 ? const Color(0xFFFBBF24) : const Color(0xFF6EE7B7);

    return GestureDetector(
      onLongPress: () => _confirmDelete(context),
      child: GlassContainer(borderRadius: 18, depthLayer: 1,
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            OrbitalIcon(icon: iconForKey(cat?.icon ?? 'category'), size: 34,
                color: Color(cat?.colorValue ?? 0xFF10B981)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(budget.label, style: AppTypography.titleMedium),
              Text('${_periodLabel(budget.period)} · $daysLeft days left', style: AppTypography.bodySmall),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: col.withValues(alpha: 0.18)),
              child: Text(prog > 1.0 ? 'Exceeded' : prog >= 0.8 ? 'Close' : 'On track',
                  style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text('${formatIdr(rem.abs())} ${rem >= 0 ? 'remaining' : 'over'}  ·  ${formatIdr(spent)} / ${formatIdr(budget.amount)} spent',
              style: AppTypography.bodyMedium),
          const SizedBox(height: 8),
          GlassProgressBar(progress: prog),
        ]),
      ),
    );
  }

  String _periodLabel(String p) => p == 'daily' ? 'Daily' : p == 'weekly' ? 'Weekly' : 'Monthly';

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text('Delete "${budget.label}"?', style: const TextStyle(color: Colors.white)),
      content: const Text("Can't be undone.", style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          ref.read(appDataProvider.notifier).deleteBudget(budget.id);
          Navigator.pop(context);
        }, child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B)))),
      ],
    ));
  }
}

// ── Per-category quick-set row with edit + name edit ─────────────────────
class _CategoryBudgetRow extends StatelessWidget {
  final CategoryModel category; final AppData data; final WidgetRef ref;
  const _CategoryBudgetRow({required this.category, required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    BudgetModel? existing;
    for (final b in data.budgets) {
      if (b.categoryId == category.id) { existing = b; break; }
    }
    final amount = existing?.amount ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        OrbitalIcon(icon: iconForKey(category.icon), size: 32, color: Color(category.colorValue)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => _editCategoryName(context),
            child: Row(children: [
              Flexible(child: Text(category.name, style: AppTypography.titleMedium, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 12, color: Colors.white38),
            ]),
          ),
          Text(formatIdr(amount), style: AppTypography.bodySmall),
        ])),
        const SizedBox(width: 8),
        GlassButton(
          borderRadius: 14, tint: const Color(0xFF10B981),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () => _showSetBudget(context, amount),
          child: const Text('Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }

  void _editCategoryName(BuildContext context) {
    final ctrl = TextEditingController(text: category.name);
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: const Text('Rename category', style: TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, autofocus: true, style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: Colors.white70))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final name = ctrl.text.trim();
          if (name.isNotEmpty) ref.read(appDataProvider.notifier).updateCategory(category.id, name);
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }

  void _showSetBudget(BuildContext context, double cur) {
    final ctrl = TextEditingController(text: cur > 0 ? cur.toStringAsFixed(0) : '');
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text('Budget for ${category.name}', style: const TextStyle(color: Colors.white)),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(prefixText: 'IDR ', prefixStyle: TextStyle(color: Colors.white70),
              labelText: 'Monthly limit', labelStyle: TextStyle(color: Colors.white70))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          final v = double.tryParse(ctrl.text) ?? 0;
          ref.read(appDataProvider.notifier).setBudget(BudgetModel(
            id: 0, categoryId: category.id, label: category.name,
            amount: v, startDate: DateTime.now(),
          ));
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }
}

// ── Savings goal ─────────────────────────────────────────────────────────
class _SavingsGoalCard extends ConsumerWidget {
  final SettingsState settings; final String lang;
  const _SavingsGoalCard({required this.settings, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = settings.savingsTarget; final current = settings.currentSavings;
    final prog   = target == 0 ? 0.0 : (current / target).clamp(0.0, 1.0);
    final pct    = target == 0 ? 0.0 : (current / target) * 100;

    return GlassContainer(borderRadius: 20, depthLayer: 2, padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(AppLocalizations.t(lang, 'savingsGoal'), style: AppTypography.titleLarge),
          GestureDetector(onTap: () => _edit(context, ref),
              child: const Icon(Icons.edit, size: 15, color: Colors.white38)),
        ]),
        const SizedBox(height: 8),
        Text('${formatIdr(current)} / ${formatIdr(target)}', style: AppTypography.titleMedium),
        const SizedBox(height: 8),
        GlassProgressBar(progress: prog),
        const SizedBox(height: 4),
        Text('${pct.toStringAsFixed(1)}% ${AppLocalizations.t(lang, 'completed')}', style: AppTypography.bodySmall),
      ]),
    );
  }

  void _edit(BuildContext context, WidgetRef ref) {
    final tCtrl = TextEditingController(text: settings.savingsTarget > 0 ? settings.savingsTarget.toStringAsFixed(0) : '');
    final cCtrl = TextEditingController(text: settings.currentSavings > 0 ? settings.currentSavings.toStringAsFixed(0) : '');
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text(AppLocalizations.t(lang, 'savingsGoal'), style: const TextStyle(color: Colors.white)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: tCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(prefixText: 'IDR ', labelText: 'Target', labelStyle: TextStyle(color: Colors.white70))),
        const SizedBox(height: 10),
        TextField(controller: cCtrl, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(prefixText: 'IDR ', labelText: 'Current savings', labelStyle: TextStyle(color: Colors.white70))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () {
          ref.read(settingsProvider.notifier).setSavingsTarget(double.tryParse(tCtrl.text) ?? 0);
          ref.read(settingsProvider.notifier).setCurrentSavings(double.tryParse(cCtrl.text) ?? 0);
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }
}
