import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_theme.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/transaction_model.dart';
import '../glass/glass_container.dart';
import '../orbital/orbital_icon.dart';

// ── shared helpers available to every screen ────────────────────────────

IconData iconForKey(String key) {
  switch (key) {
    case 'restaurant': return Icons.restaurant;
    case 'payments':   return Icons.payments;
    case 'directions_car': return Icons.directions_car;
    case 'school':     return Icons.school;
    case 'wallet':     return Icons.account_balance_wallet;
    case 'bank':       return Icons.account_balance;
    default:           return Icons.category;
  }
}

final _fmt = NumberFormat.decimalPattern('id_ID');
String formatIdr(double amount) => 'IDR ${_fmt.format(amount.abs())}';

// ─────────────────────────────────────────────────────────────────────────

class GlassTransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final CategoryModel? category;
  final VoidCallback? onLongPress;

  const GlassTransactionItem({
    super.key, required this.transaction,
    this.category, this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final usd = (transaction.amount.abs() / 17750).toStringAsFixed(2);

    return GestureDetector(
      onLongPress: onLongPress,
      child: GlassContainer(
        depthLayer: 1, borderRadius: 18,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            OrbitalIcon(
              icon: iconForKey(category?.icon ?? 'category'),
              size: 44,
              color: Color(category?.colorValue ?? 0xFF10B981),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: AppTypography.titleMedium),
                  if (transaction.subtitle != null)
                    Text(transaction.subtitle!, style: AppTypography.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : ''}${formatIdr(transaction.amount)}',
                  style: AppTypography.amountMedium(isExpense: isExpense),
                ),
                Text('\$$usd', style: AppTypography.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
