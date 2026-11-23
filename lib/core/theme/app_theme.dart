import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.tomato,
      primary: AppColors.tomato,
      surface: AppColors.cream,
    ),
    textTheme: GoogleFonts.nunitoTextTheme(),
  );
}