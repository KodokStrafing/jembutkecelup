import 'package:flutter/material.dart';
import '../../../core/constants/liquid_glass.dart';

class GlassToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const GlassToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 52, height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? const Color(0xFF10B981).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle, color: Colors.white,
              boxShadow: LiquidGlass.depth(1),
            ),
            child: value ? const Icon(Icons.check, size: 14, color: Color(0xFF10B981)) : null,
          ),
        ),
      ),
    );
  }
}
