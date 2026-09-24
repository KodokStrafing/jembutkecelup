import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/accounts/accounts_screen.dart';
import 'presentation/screens/budgets/budgets_screen.dart';
import 'presentation/screens/dashboard/home_screen.dart';
import 'presentation/screens/settings/more_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spendee Liquid Glass',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell();

  static const _screens = [
    HomeScreen(),
    AccountsScreen(),
    BudgetsScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(navIndexProvider);
    return IndexedStack(index: index, children: _screens);
  }
}
