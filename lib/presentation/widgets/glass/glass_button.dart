import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderRadius;
  final Color? tint;
  final EdgeInsetsGeometry padding;

  const GlassButton({
    super.key, required this.onPressed, required this.child,
    this.borderRadius = 16, this.tint,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedOpacity(
        opacity: _pressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 60),
        child: GlassContainer(
          borderRadius: widget.borderRadius, depthLayer: 1,
          tint: widget.tint, padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}
