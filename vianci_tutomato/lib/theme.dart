import 'package:flutter/material.dart';

class AppColors {
  static const cream = Color(0xFFFFF3E7);
  static const card = Color(0xFFFFFAF4);
  static const peach = Color(0xFFFFDFCF);
  static const red = Color(0xFFE13D2C);
  static const brown = Color(0xFF51230F);
  static const muted = Color(0xFF805C4F);
  static const border = Color(0xFFE3C0AD);
  static const green = Color(0xFF4F8738);
  static const greenSoft = Color(0xFFE8F0D8);
  static const white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const title = TextStyle(
    color: AppColors.brown,
    fontSize: 21,
    height: 1.15,
    fontWeight: FontWeight.w800,
    fontFamily: 'sans-serif-rounded',
  );

  static const heading = TextStyle(
    color: AppColors.brown,
    fontSize: 29,
    height: 1.15,
    fontWeight: FontWeight.w800,
    fontFamily: 'sans-serif-rounded',
  );

  static const body = TextStyle(
    color: AppColors.muted,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );
}

class AppTheme {
  static final light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.cream,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.red,
      primary: AppColors.red,
      secondary: AppColors.green,
      surface: AppColors.cream,
      onSurface: AppColors.brown,
    ),
    fontFamily: 'sans-serif-rounded',
    textTheme: const TextTheme(
      bodyMedium: AppTextStyles.body,
      bodyLarge: AppTextStyles.body,
      titleMedium: AppTextStyles.title,
      headlineMedium: AppTextStyles.heading,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.brown,
      contentTextStyle: TextStyle(color: AppColors.cream),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
