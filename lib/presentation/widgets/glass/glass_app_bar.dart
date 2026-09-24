import 'package:flutter/material.dart';

import '../../../core/constants/app_theme.dart';
import 'glass_container.dart';
import 'glass_icon_button.dart';

class GlassAppBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final VoidCallback? onFilterTap;

  const GlassAppBar({super.key, this.onNotificationTap, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassContainer(
        depthLayer: 2,
        borderRadius: 32,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            GlassIconButton(
              icon: Icons.notifications_outlined,
              onPressed: onNotificationTap ?? () {},
              size: 44,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                depthLayer: 1,
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white.withValues(alpha: 0.6), size: 20),
                    const SizedBox(width: 8),
                    Text('Search', style: AppTypography.bodyMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            GlassIconButton(
              icon: Icons.menu,
              onPressed: onFilterTap ?? () {},
              size: 44,
            ),
          ],
        ),
      ),
    );
  }
}
