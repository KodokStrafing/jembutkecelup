import 'package:flutter/material.dart';

class LiquidGlass {
  LiquidGlass._();
  static const double blurSigma = 14.0;
  static const double opacity = 0.12;
  static const double borderOpacity = 0.25;

  static List<BoxShadow> depth(int layer) {
    switch (layer) {
      case 1:
        return const [
          BoxShadow(color: Color(0x20FFFFFF), blurRadius: 8, spreadRadius: -2, offset: Offset(0, -1)),
          BoxShadow(color: Color(0x30000000), blurRadius: 16, offset: Offset(0, 4)),
        ];
      case 2:
        return const [
          BoxShadow(color: Color(0x25FFFFFF), blurRadius: 12, spreadRadius: -4, offset: Offset(0, -2)),
          BoxShadow(color: Color(0x40000000), blurRadius: 24, spreadRadius: 2, offset: Offset(0, 8)),
        ];
      case 3:
        return const [
          BoxShadow(color: Color(0x30FFFFFF), blurRadius: 16, spreadRadius: -6, offset: Offset(0, -4)),
          BoxShadow(color: Color(0x50000000), blurRadius: 40, spreadRadius: 4, offset: Offset(0, 12)),
        ];
      default:
        return const [];
    }
  }

  static const Gradient thicknessGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x35FFFFFF), Color(0x08FFFFFF), Color(0x15FFFFFF)],
    stops: [0.0, 0.5, 1.0],
  );
}

class AppBackgrounds {
  AppBackgrounds._();
  static const Gradient emeraldDepth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF064E3B), Color(0xFF0F172A), Color(0xFF1E1B4B)],
    stops: [0.0, 0.5, 1.0],
  );
  static const Gradient duskLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D6FC4), Color(0xFF9D7FE0), Color(0xFFE79FC4)],
    stops: [0.0, 0.5, 1.0],
  );
}

class AppColors {
  AppColors._();
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldSoft = Color(0xFF6EE7B7);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFBBF24);
}