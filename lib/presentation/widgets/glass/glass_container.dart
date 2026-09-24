import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/constants/liquid_glass.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final int depthLayer;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? tint;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key, required this.child, this.borderRadius = 20,
    this.depthLayer = 2, this.padding, this.margin, this.tint,
    this.width, this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin, width: width, height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: LiquidGlass.depth(depthLayer),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: LiquidGlass.blurSigma, sigmaY: LiquidGlass.blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: (tint ?? Colors.white).withValues(alpha: LiquidGlass.opacity),
              border: Border.all(color: Colors.white.withValues(alpha: LiquidGlass.borderOpacity)),
              gradient: LiquidGlass.thicknessGradient,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
