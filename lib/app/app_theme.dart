import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/responsive/size_tokens.dart';
import '../core/utils/color_utils.dart';

class AppTheme {
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Colors.white;

  static ThemeData getTheme({String? mainColor, String? otherColor}) {
    final Color primary = ColorUtils.fromHex(mainColor ?? '#f9991c');
    final Color secondary = ColorUtils.fromHex(otherColor ?? '#028ab2');

    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9F9F9),
      useMaterial3: true,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: TextStyle(
          fontSize: SizeTokens.f32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: SizeTokens.f24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
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
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
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
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeTokens.r12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}
