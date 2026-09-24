import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/liquid_glass.dart';

/// A small circular glass icon button. Tap feedback is a subtle, instant
/// opacity dim — no bounce, no scale spring.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool showBadge;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 44,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: LiquidGlass.depth(1),
                ),
                child: Icon(icon, color: Colors.white, size: size * 0.4),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
