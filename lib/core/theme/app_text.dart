import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static const h1 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.brown,
    height: 1.15,
  );

  static const h2 = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.brown,
  );

  static const title = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.brown,
  );

  static const body = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.brownSoft,
  );

  static const small = TextStyle(
    fontFamily: 'Fredoka',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.brownSoft,
  );

  static TextStyle brandStyle({
    double fontSize = 28,
    Color color = AppColors.tomato,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}