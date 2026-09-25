import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_localizations.dart';
import '../../../core/constants/liquid_glass.dart';
import '../../providers/app_providers.dart';
import 'glass_container.dart';

/// Fixed, always-visible iOS-style tab bar.
///
/// Bug fixes applied vs the previous version:
/// - Removed `tint: Colors.black` — that was the source of the ugly
///   solid black container with hard borders. The glass system's own
///   dark tinted blur now shows through naturally, matching the rest of
///   the app's surfaces.
/// - Removed all outer Padding that was adding extra top/bottom margins
///   around the bar and causing it to float disconnected from the bottom
///   edge. The bar now sits flush against the system nav area.
/// - `SafeArea` handles the bottom inset; no hardcoded pixel offsets.
class GlassNavBar extends ConsumerWidget {
  const GlassNavBar({super.key});

  static const _icons = [
    Icons.home_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.bar_chart_rounded,
    Icons.more_horiz_rounded,
  ];
  static const _labelKeys = ['navHome', 'navAccounts', 'navBudgets', 'navMore'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);
    final lang = ref.watch(settingsProvider).language;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          // Transparent so the blur shows through — no solid black fill.
          color: Colors.black.withValues(alpha: 0.25),
          child: SafeArea(
            top: false,
            child: Container(
              // Top border line only — clean separator from content.
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: List.generate(_icons.length, (index) {
                  final isActive = index == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => ref.read(navIndexProvider.notifier).state = index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _icons[index],
                              color: isActive ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.45),
                              size: 24,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppLocalizations.t(lang, _labelKeys[index]),
                              style: TextStyle(
                                color: isActive ? const Color(0xFF10B981) : Colors.white.withValues(alpha: 0.45),
                                fontSize: 10,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
