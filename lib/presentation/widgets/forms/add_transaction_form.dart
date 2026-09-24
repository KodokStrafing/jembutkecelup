import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_localizations.dart';
import '../../../core/constants/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/app_providers.dart';
import '../glass/glass_button.dart';
import '../glass/glass_container.dart';

class AddTransactionForm extends ConsumerStatefulWidget {
  const AddTransactionForm({super.key});

  @override
  ConsumerState<AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends ConsumerState<AddTransactionForm> {
  final _descCtrl = TextEditingController();
  final _amtCtrl  = TextEditingController();

  String _type        = 'expense'; // expense | income
  bool   _isScheduled = false;
  String _recurrence  = 'none';    // none | daily | weekly | monthly
  DateTime _date      = DateTime.now();
  int? _categoryId;
  int? _accountId;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    _amtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appDataProvider);
    final lang = ref.watch(settingsProvider).language;
    final cats = data.categories.where((c) => c.type == _type).toList();

    if (_categoryId == null || !cats.any((c) => c.id == _categoryId)) {
      _categoryId = cats.isNotEmpty ? cats.first.id : null;
    }
    if (_accountId == null || !data.accounts.any((a) => a.id == _accountId)) {
      _accountId = data.accounts.isNotEmpty ? data.accounts.first.id : null;
    }

    return GlassContainer(
      borderRadius: 20, depthLayer: 2, padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.t(lang, 'addTransaction'), style: AppTypography.titleLarge),
          const SizedBox(height: 14),

          // Expense / Income
          Row(children: [
            Expanded(child: _chip(AppLocalizations.t(lang, 'expense'), _type == 'expense',
                const Color(0xFFFF6B6B), () => setState(() { _type = 'expense'; _categoryId = null; }))),
            const SizedBox(width: 10),
            Expanded(child: _chip(AppLocalizations.t(lang, 'income'), _type == 'income',
                const Color(0xFF6EE7B7), () => setState(() { _type = 'income'; _categoryId = null; }))),
          ]),
          const SizedBox(height: 10),

          // Normal / Scheduled
          Row(children: [
            Expanded(child: _chip('Normal', !_isScheduled, const Color(0xFF10B981),
                () => setState(() { _isScheduled = false; _recurrence = 'none'; }))),
            const SizedBox(width: 10),
            Expanded(child: _chip('Scheduled', _isScheduled, const Color(0xFF10B981),
                () => setState(() => _isScheduled = true))),
          ]),

          // Recurrence — only visible when Scheduled is selected
          if (_isScheduled) ...[
            const SizedBox(height: 10),
            Text('Repeat', style: AppTypography.bodySmall),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _chip('Once', _recurrence == 'none', const Color(0xFF818CF8),
                  () => setState(() => _recurrence = 'none'))),
              const SizedBox(width: 6),
              Expanded(child: _chip('Daily', _recurrence == 'daily', const Color(0xFF818CF8),
                  () => setState(() => _recurrence = 'daily'))),
              const SizedBox(width: 6),
              Expanded(child: _chip('Weekly', _recurrence == 'weekly', const Color(0xFF818CF8),
                  () => setState(() => _recurrence = 'weekly'))),
              const SizedBox(width: 6),
              Expanded(child: _chip('Monthly', _recurrence == 'monthly', const Color(0xFF818CF8),
                  () => setState(() => _recurrence = 'monthly'))),
            ]),
          ],
          const SizedBox(height: 14),

          _field(child: TextField(
            controller: _descCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Description', labelStyle: TextStyle(color: Colors.white70),
            ),
          )),
          const SizedBox(height: 10),
          _field(child: TextField(
            controller: _amtCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: 'IDR ', prefixStyle: TextStyle(color: Colors.white70),
              labelText: 'Amount', labelStyle: TextStyle(color: Colors.white70),
            ),
          )),
          const SizedBox(height: 10),
          _field(child: InkWell(
            onTap: _pickDate,
            child: Row(children: [
              const Icon(Icons.calendar_today, color: Colors.white60, size: 16),
              const SizedBox(width: 10),
              Text(DateFormat('EEE, d MMM yyyy').format(_date),
                  style: const TextStyle(color: Colors.white)),
            ]),
          )),
          const SizedBox(height: 10),
          _field(child: DropdownButtonFormField<int>(
            initialValue: _categoryId,
            dropdownColor: const Color(0xFF1E1B4B),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(border: InputBorder.none,
                labelText: 'Category', labelStyle: TextStyle(color: Colors.white70)),
            items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (v) => setState(() => _categoryId = v),
          )),
          const SizedBox(height: 10),
          _field(child: DropdownButtonFormField<int>(
            initialValue: _accountId,
            dropdownColor: const Color(0xFF1E1B4B),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(border: InputBorder.none,
                labelText: 'Source / Account', labelStyle: TextStyle(color: Colors.white70)),
            items: data.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
            onChanged: (v) => setState(() => _accountId = v),
          )),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12)),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: GlassButton(
              tint: const Color(0xFF10B981), onPressed: _submit,
              child: Center(child: Text(AppLocalizations.t(lang, 'addTransaction'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({required Widget child}) => GlassContainer(
    depthLayer: 1, borderRadius: 14,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: child,
  );

  Widget _chip(String label, bool selected, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: selected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: selected ? color : Colors.white.withValues(alpha: 0.12)),
          ),
          child: Center(child: Text(label, style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 13,
          ))),
        ),
      );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _date,
      firstDate: DateTime(2020), lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final desc   = _descCtrl.text.trim();
    final amount = double.tryParse(_amtCtrl.text.trim());
    if (desc.isEmpty)          { setState(() => _error = 'Description is required.'); return; }
    if (amount == null || amount <= 0) { setState(() => _error = 'Enter a valid amount.'); return; }
    if (_categoryId == null)   { setState(() => _error = 'Select a category.'); return; }
    if (_accountId  == null)   { setState(() => _error = 'Select a source/account.'); return; }

    final signed = _type == 'expense' ? -amount.abs() : amount.abs();
    ref.read(appDataProvider.notifier).addTransaction(TransactionModel(
      id: 0, title: desc, subtitle: desc, amount: signed, type: _type,
      categoryId: _categoryId, accountId: _accountId, date: _date,
      isScheduled: _isScheduled, recurrence: _recurrence,
    ));

    setState(() {
      _descCtrl.clear(); _amtCtrl.clear();
      _date = DateTime.now(); _isScheduled = false; _recurrence = 'none'; _error = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF1E1B4B),
      content: Text('Transaction added.'),
    ));
  }
}
