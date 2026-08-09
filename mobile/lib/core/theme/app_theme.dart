import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Charte FretCorridor : rouge du logo en couleur primaire, fond gris tres
/// clair, cartes blanches - coherent avec les maquettes existantes.
class AppColors {
  AppColors._();

  static const primary = Color(0xFFC62828);
  static const background = Color(0xFFF5F5F5);
  static const errorBackground = Color(0xFFFCE8E8);
  static const errorBorder = Color(0xFFF3B8B8);
  static const success = Color(0xFF2E7D32);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.black87,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
