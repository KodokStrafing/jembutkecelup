import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/liquid_glass.dart';
import '../../providers/app_providers.dart';
import 'glass_nav_bar.dart';

class GlassScaffold extends ConsumerWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const GlassScaffold({super.key, required this.body, this.floatingActionButton});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsProvider).darkMode;
    final bg = isDark ? AppBackgrounds.emeraldDepth : AppBackgrounds.duskLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      // extendBody: false ensures the nav bar never overlaps content.
      extendBody: false,
      body: Container(
        decoration: BoxDecoration(gradient: bg),
        child: SafeArea(bottom: false, child: body),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const GlassNavBar(),
    );
  }
}
