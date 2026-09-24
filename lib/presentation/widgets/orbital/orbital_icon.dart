import 'package:flutter/material.dart';

/// A circular icon badge with the glass glow treatment.
/// No floating/motion animation per the design spec.
class OrbitalIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;

  const OrbitalIcon({
    super.key, required this.icon,
    this.size = 48, this.color = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: 0.3), color.withValues(alpha: 0.07),
        ]),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14, spreadRadius: -4)],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.45),
    );
  }
}
