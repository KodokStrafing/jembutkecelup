import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_localizations.dart';
import '../../../core/constants/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/cards/transaction_item.dart';
import '../../widgets/glass/glass_container.dart';
import '../../widgets/glass/glass_scaffold.dart';
import '../../widgets/glass/glass_toggle.dart';
import '../../widgets/orbital/orbital_icon.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});
  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  bool _passcode  = true;
  bool _hideShake = false;
  bool _biometric = true;

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1B4B), content: Text(msg)),
  );

  void _showLanguagePicker(String current) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.t(current, 'language'), style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          for (final entry in AppLocalizations.languageLabels.entries)
            ListTile(
              onTap: () {
                ref.read(settingsProvider.notifier).setLanguage(entry.key);
                Navigator.pop(context);
              },
              title: Text(entry.value, style: AppTypography.bodyLarge),
              trailing: entry.key == current
                  ? const Icon(Icons.check, color: Color(0xFF10B981))
                  : null,
            ),
        ]),
      ),
    );
  }

  void _showCategories(AppData data) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Categories', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          ...data.categories.map((c) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              OrbitalIcon(icon: iconForKey(c.icon), size: 32, color: Color(c.colorValue)),
              const SizedBox(width: 12),
              Expanded(child: Text(c.name, style: AppTypography.bodyLarge)),
              Text(c.type, style: AppTypography.bodySmall),
            ]),
          )),
        ]),
      ),
    );
  }

  void _showScheduled(AppData data) {
    showModalBottomSheet(
      context: context, backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Scheduled Transactions', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          if (data.scheduled.isEmpty)
            Text('None scheduled.', style: AppTypography.bodyMedium)
          else
            ...data.scheduled.map((t) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                Expanded(child: Text(t.title, style: AppTypography.bodyLarge)),
                Text(formatIdr(t.amount), style: AppTypography.amountMedium(isExpense: t.isExpense)),
              ]),
            )),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data     = ref.watch(appDataProvider);
    final settings = ref.watch(settingsProvider);
    final lang     = settings.language;

    return GlassScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          Text(AppLocalizations.t(lang, 'navMore'), style: AppTypography.displayMedium),
          const SizedBox(height: 20),

          // Management
          _group(children: [
            _row(icon: Icons.grid_view,
                title: 'Categories',
                value: '${data.categories.length}',
                trailing: true,
                onTap: () => _showCategories(data)),
            _row(icon: Icons.label,
                title: 'Labels',
                trailing: true,
                onTap: () => _toast('Labels — coming soon.')),
            _row(icon: Icons.attach_money,
                title: 'Main Currency',
                value: 'IDR',
                trailing: true,
                onTap: () => _toast('Currency switching — coming soon.')),
          ]),
          const SizedBox(height: 14),

          // Financial
          _group(children: [
            _row(icon: Icons.account_balance_wallet,
                title: 'Wallets',
                value: '${data.accounts.where((a) => a.normalizedType == 'cash').length}',
                trailing: true,
                onTap: () => ref.read(navIndexProvider.notifier).state = 1),
            _row(icon: Icons.credit_card,
                title: 'Bank Accounts',
                value: 'Manage',
                trailing: true,
                onTap: () => ref.read(navIndexProvider.notifier).state = 1),
            _row(icon: Icons.schedule,
                title: 'Scheduled Transactions',
                value: '${data.scheduled.length}',
                trailing: true,
                onTap: () => _showScheduled(data)),
          ]),
          const SizedBox(height: 14),

          // Preferences
          _group(children: [
            _row(
              icon: Icons.language,
              title: AppLocalizations.t(lang, 'language'),
              value: AppLocalizations.languageLabels[lang],
              trailing: true,
              onTap: () => _showLanguagePicker(lang),
            ),
            _row(
              icon: settings.darkMode ? Icons.dark_mode : Icons.light_mode,
              title: AppLocalizations.t(lang, 'appearance'),
              toggle: GlassToggle(
                value: settings.darkMode,
                onChanged: (v) => ref.read(settingsProvider.notifier).setDarkMode(v),
              ),
            ),
            _row(icon: Icons.file_download,
                title: 'Export',
                trailing: true,
                onTap: () => _toast('CSV/JSON export — coming soon.')),
            _row(icon: Icons.lock,
                title: 'Passcode',
                toggle: GlassToggle(value: _passcode, onChanged: (v) => setState(() => _passcode = v))),
            _row(icon: Icons.visibility_off,
                title: 'Hide amounts on shake',
                toggle: GlassToggle(value: _hideShake, onChanged: (v) => setState(() => _hideShake = v))),
            _row(icon: Icons.face,
                title: 'Touch / Face ID',
                toggle: GlassToggle(value: _biometric, onChanged: (v) => setState(() => _biometric = v))),
          ]),
          const SizedBox(height: 14),

          // Support
          _group(children: [
            _row(icon: Icons.help, title: 'Help Center', trailing: true, onTap: () => _toast('Help Center — coming soon.')),
            _row(icon: Icons.question_answer, title: 'Contact Support', trailing: true, onTap: () => _toast('Contact Support — coming soon.')),
            _row(icon: Icons.description, title: 'Terms and Policies', trailing: true, onTap: () => _toast('Terms and Policies — coming soon.')),
          ]),
          const SizedBox(height: 24),
          Center(child: Text('Version 1.0.0', style: AppTypography.bodySmall)),
        ],
      ),
    );
  }

  Widget _group({required List<Widget> children}) {
    return GlassContainer(
      borderRadius: 20, depthLayer: 2, padding: const EdgeInsets.all(4),
      child: Column(children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1)
            Divider(color: Colors.white.withValues(alpha: 0.1), height: 1),
        ],
      ]),
    );
  }

  Widget _row({
    required IconData icon,
    required String title,
    Color iconColor = Colors.white70,
    String? value,
    bool trailing = false,
    Widget? toggle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTypography.bodyLarge)),
          if (value != null) ...[
            Text(value, style: AppTypography.bodyMedium),
            const SizedBox(width: 4),
          ],
          if (toggle != null) toggle,
          if (trailing) Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 18),
        ]),
      ),
    );
  }
}
