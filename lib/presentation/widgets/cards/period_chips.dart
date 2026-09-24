import 'package:flutter/material.dart';

import '../glass/glass_container.dart';

class PeriodChips extends StatelessWidget {
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PeriodChips({
    super.key,
    required this.periods,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(periods.length, (index) {
        final isActive = index == selectedIndex;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedScale(
              scale: isActive ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: isActive
                  ? GlassContainer(
                      depthLayer: 1,
                      borderRadius: 16,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        periods[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        periods[index],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }
}
