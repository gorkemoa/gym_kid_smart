import 'package:flutter/material.dart';
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
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: SizeTokens.f18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: SizeTokens.f32, color: textPrimary),
        displayMedium: TextStyle(fontSize: SizeTokens.f24, color: textPrimary),
        titleLarge: TextStyle(fontSize: SizeTokens.f20, color: textPrimary),
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
          textStyle: TextStyle(fontSize: SizeTokens.f16),
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
