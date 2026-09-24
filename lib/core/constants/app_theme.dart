import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xF2FFFFFF),
        shadows: const [Shadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 2))]);

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w700, color: const Color(0xF2FFFFFF),
        shadows: const [Shadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 1))]);

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w600, color: const Color(0xF2FFFFFF));

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xF2FFFFFF));

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xE6FFFFFF));

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xB3FFFFFF));

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0x80FFFFFF));

  static TextStyle get amountLarge => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w700, color: const Color(0xF2FFFFFF),
        shadows: const [Shadow(color: Color(0x60000000), blurRadius: 12, offset: Offset(0, 2))]);

  static TextStyle amountMedium({bool isExpense = false}) => GoogleFonts.inter(
        fontSize: 15, fontWeight: FontWeight.w600,
        color: isExpense ? const Color(0xFFFF6B6B) : const Color(0xFF6EE7B7));
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    fontFamily: GoogleFonts.inter().fontFamily,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981), brightness: Brightness.dark),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF10B981))),
    ),
    datePickerTheme: const DatePickerThemeData(backgroundColor: Color(0xFF1E1B4B)),
  );
}
