import 'package:flutter/material.dart';

class GlassProgressBar extends StatelessWidget {
  final double progress;
  const GlassProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final isOver = progress > 1.0;
    final color = isOver ? const Color(0xFFFF6B6B)
        : progress >= 0.8 ? const Color(0xFFFBBF24)
        : const Color(0xFF6EE7B7);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 8,
        color: Colors.white.withValues(alpha: 0.1),
        child: LayoutBuilder(
          builder: (context, box) => Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              width: box.maxWidth * progress.clamp(0.0, 1.0),
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: color,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 6)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
