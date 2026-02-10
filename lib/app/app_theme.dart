import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive/size_tokens.dart';

class AppTheme {
  // Colors (Inspired by the provided screenshots and dryfix style)
  static const Color primaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryColor = Color(0xFF5C6BC0); // Indigo/Blue
  static const Color backgroundColor = Color(0xFFFF9800);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: TextStyle(
          fontSize: SizeTokens.f32,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        displayMedium: TextStyle(
          fontSize: SizeTokens.f24,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        titleLarge: TextStyle(
          fontSize: SizeTokens.f20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: SizeTokens.f16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: SizeTokens.f14, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButtonStyleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: textWhite,
          minimumSize: Size(double.infinity, SizeTokens.h52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeTokens.r12),
          ),
          textStyle: TextStyle(
            fontSize: SizeTokens.f16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
      ),
    );
  }

  static ButtonStyle ElevatedButtonStyleFrom({
    required Color backgroundColor,
    required Color foregroundColor,
    required Size minimumSize,
    required OutlinedBorder shape,
    required TextStyle textStyle,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: minimumSize,
      shape: shape,
      textStyle: textStyle,
    );
  }
}
