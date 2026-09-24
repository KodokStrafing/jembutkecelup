import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_theme.dart';
import '../../../data/models/account_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_scaffold.dart';
import '../../widgets/orbital/orbital_icon.dart';

const _accountPresets = [
  {'name': 'BCA',       'type': 'bank',    'icon': 'bank',   'color': 0xFF3B82F6},
  {'name': 'BNI',       'type': 'bank',    'icon': 'bank',   'color': 0xFFF97316},
  {'name': 'GoPay',     'type': 'ewallet', 'icon': 'wallet', 'color': 0xFF00AED6},
  {'name': 'DANA',      'type': 'ewallet', 'icon': 'wallet', 'color': 0xFF118EEA},
  {'name': 'ShopeePay', 'type': 'ewallet', 'icon': 'wallet', 'color': 0xFFEE4D2D},
  {'name': 'Cash',      'type': 'cash',    'icon': 'wallet', 'color': 0xFFFF8A50},
];

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(appDataProvider);
    if (data.isLoading) {
      return const GlassScaffold(body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text('Accounts', style: AppTypography.displayMedium),
          const SizedBox(height: 14),
          Text('Total Wealth', style: AppTypography.bodyMedium),
          const SizedBox(height: 4),
          Text(formatIdr(data.totalWealth), style: AppTypography.displayLarge),
          const SizedBox(height: 16),

          SizedBox(width: double.infinity,
            child: GlassButton(
              tint: const Color(0xFF10B981),
              onPressed: () => _showAddAccountSheet(context, ref),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Add Bank / E-Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(height: 24),

          if (data.banks.isNotEmpty) ...[
            Text('Banks', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            for (final a in data.banks) _AccountCard(account: a, ref: ref),
            const SizedBox(height: 14),
          ],
          if (data.ewallets.isNotEmpty) ...[
            Text('E-Wallets', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            for (final a in data.ewallets) _AccountCard(account: a, ref: ref),
            const SizedBox(height: 14),
          ],
          if (data.cashAccounts.isNotEmpty) ...[
            Text('Cash', style: AppTypography.titleLarge),
            const SizedBox(height: 8),
            for (final a in data.cashAccounts) _AccountCard(account: a, ref: ref),
            const SizedBox(height: 14),
          ],

          const SizedBox(height: 4),
          Text('Transaction Logs', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          if (data.allSortedNewestFirst.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No transactions yet.', style: AppTypography.bodyMedium),
            )
          else
            for (final t in data.allSortedNewestFirst)
              _LogRow(transaction: t, data: data, ref: ref),
        ],
      ),
    );
  }

  void _showAddAccountSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final balCtrl  = TextEditingController();
    final descCtrl = TextEditingController();
    String type = 'bank'; String icon = 'bank'; int colorValue = 0xFF3B82F6;

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Add Bank / E-Wallet', style: AppTypography.titleLarge),
                const SizedBox(height: 14),
                Wrap(spacing: 8, runSpacing: 8,
                  children: _accountPresets.map((p) => GestureDetector(
                    onTap: () {
                      nameCtrl.text = p['name'] as String;
                      setS(() { type = p['type'] as String; icon = p['icon'] as String; colorValue = p['color'] as int; });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withValues(alpha: 0.08),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 14),
                TextField(controller: nameCtrl, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Account name', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 12),
                Row(children: [
                  for (final t in [('Bank', 'bank'), ('E-Wallet', 'ewallet'), ('Cash', 'cash')]) ...[
                    Expanded(child: _typeChip(t.$1, type == t.$2, () => setS(() => type = t.$2))),
                    if (t.$2 != 'cash') const SizedBox(width: 8),
                  ],
                ]),
                const SizedBox(height: 12),
                TextField(controller: balCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(prefixText: 'IDR ', prefixStyle: TextStyle(color: Colors.white70),
                        labelText: 'Initial balance', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Description (optional)', labelStyle: TextStyle(color: Colors.white70))),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity,
                  child: GlassButton(
                    tint: const Color(0xFF10B981),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) { ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Name required.'))); return; }
                      ref.read(appDataProvider.notifier).addAccount(AccountModel(
                        id: 0, name: name, type: type,
                        balance: double.tryParse(balCtrl.text.trim()) ?? 0,
                        icon: icon, colorValue: colorValue,
                        description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                    },
                    child: const Center(child: Text('Save Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  Widget _typeChip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected ? const Color(0xFF10B981).withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: selected ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13))),
      ));
}

class _AccountCard extends StatelessWidget {
  final AccountModel account;
  final WidgetRef ref;
  const _AccountCard({required this.account, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('account_${account.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ref.read(appDataProvider.notifier).deleteAccount(account.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), color: const Color(0xFFFF6B6B).withValues(alpha: 0.25)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
      ),
      child: GlassContainer(
        depthLayer: 1, borderRadius: 18,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          OrbitalIcon(icon: iconForKey(account.icon), size: 44, color: Color(account.colorValue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(account.name, style: AppTypography.titleMedium),
            Text(account.description?.isNotEmpty == true ? account.description!
                : account.normalizedType == 'bank' ? 'Bank'
                : account.normalizedType == 'ewallet' ? 'E-Wallet' : 'Cash',
                style: AppTypography.bodyMedium),
          ])),
          Text(formatIdr(account.balance), style: AppTypography.amountMedium()),
        ]),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: Text('Delete "${account.name}"?', style: const TextStyle(color: Colors.white)),
      content: const Text("This can't be undone. Total Wealth will be recalculated.",
          style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B)))),
      ],
    ),
  );
}

/// Full transaction log row with swipe-to-delete.
/// Deleting reverses the balance effect automatically (handled in repository).
class _LogRow extends StatelessWidget {
  final TransactionModel transaction;
  final AppData data;
  final WidgetRef ref;
  const _LogRow({required this.transaction, required this.data, required this.ref});

  @override
  Widget build(BuildContext context) {
    final category  = data.categoryFor(transaction.categoryId);
    final account   = data.accountFor(transaction.accountId);
    final isExpense = transaction.isExpense;

    return Dismissible(
      key: ValueKey('tx_${transaction.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => ref.read(appDataProvider.notifier).deleteTransaction(transaction.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xFFFF6B6B).withValues(alpha: 0.22)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 18),
        child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
      ),
      child: GlassContainer(
        depthLayer: 1, borderRadius: 16,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(transaction.title, style: AppTypography.titleMedium),
            Text(
              [
                DateFormat('d MMM yyyy').format(transaction.date),
                if (category != null) category.name,
                if (account  != null) account.name,
                if (transaction.isScheduled) 'Scheduled',
                if (transaction.recurrence != 'none') transaction.recurrence,
              ].join(' · '),
              style: AppTypography.bodySmall,
            ),
          ])),
          Text('${isExpense ? '-' : ''}${formatIdr(transaction.amount)}',
              style: AppTypography.amountMedium(isExpense: isExpense)),
        ]),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1E1B4B),
      title: const Text('Delete transaction?', style: TextStyle(color: Colors.white)),
      content: const Text("Account balance will be reversed.", style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFFF6B6B)))),
      ],
    ),
  );
}
