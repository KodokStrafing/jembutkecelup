import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_theme.dart';
import '../../../core/constants/liquid_glass.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/glass/glass_button.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_icon_button.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  int? _categoryId;
  int? _accountId;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appDataProvider);
    _accountId ??= data.accounts.isNotEmpty ? data.accounts.first.id : null;
    final categories = data.categories.where((c) => c.type == _type).toList();
    if (_categoryId == null && categories.isNotEmpty) {
      _categoryId = categories.first.id;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: ref.watch(settingsProvider).darkMode
              ? AppBackgrounds.emeraldDepth
              : AppBackgrounds.duskLight,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back,
                      onPressed: () => Navigator.of(context).pop(),
                      size: 44,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Add Transaction', style: AppTypography.titleLarge),
                    ),
                    GlassButton(
                      borderRadius: 16,
                      tint: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      onPressed: _save,
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Income / Expense toggle
                    Row(
                      children: [
                        Expanded(child: _typeChip('expense', 'Expense')),
                        const SizedBox(width: 10),
                        Expanded(child: _typeChip('income', 'Income')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _glassField(
                      label: 'Store / Title',
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _glassField(
                      label: 'Amount (IDR)',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _glassField(
                      label: 'Note',
                      controller: _noteController,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 20),

                    Text('Category', style: AppTypography.bodyMedium),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: categories.map((c) {
                        final selected = c.id == _categoryId;
                        return GestureDetector(
                          onTap: () => setState(() => _categoryId = c.id),
                          child: GlassContainer(
                            depthLayer: 1,
                            borderRadius: 16,
                            tint: selected ? const Color(0xFF10B981) : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(iconForKey(c.icon), color: Colors.white, size: 16),
                                const SizedBox(width: 6),
                                Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label) {
    final selected = _type == value;
    return GestureDetector(
      onTap: () => setState(() {
        _type = value;
        _categoryId = null;
      }),
      child: GlassContainer(
        depthLayer: selected ? 2 : 1,
        borderRadius: 18,
        tint: selected ? const Color(0xFF10B981) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return GlassContainer(
      depthLayer: 1,
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelText: label,
          labelStyle: AppTypography.bodyMedium,
        ),
      ),
    );
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount == 0 || _titleController.text.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final signedAmount = _type == 'expense' ? -amount.abs() : amount.abs();

    ref.read(appDataProvider.notifier).addTransaction(
          TransactionModel(
            id: 0,
            title: _titleController.text,
            subtitle: _noteController.text.isEmpty ? null : _noteController.text,
            amount: signedAmount,
            type: _type,
            categoryId: _categoryId,
            accountId: _accountId,
            date: DateTime.now(),
            note: _noteController.text.isEmpty ? null : _noteController.text,
          ),
        );

    Navigator.of(context).pop();
  }
}
