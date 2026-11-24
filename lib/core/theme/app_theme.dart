import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    final baseTextTheme = GoogleFonts.fredokaTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.tomato,
        primary: AppColors.tomato,
        surface: AppColors.cream,
      ),
      fontFamily: GoogleFonts.fredoka().fontFamily,
      textTheme: baseTextTheme.apply(
        bodyColor: AppColors.brownSoft,
        displayColor: AppColors.brown,
      ),
    );
  }
}