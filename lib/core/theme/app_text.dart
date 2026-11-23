import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static const h1 = TextStyle(
      fontSize: 34, fontWeight: FontWeight.w800, color: AppColors.brown, height: 1.1);
  static const h2 =
  TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.brown);
  static const title =
  TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.brown);
  static const body = TextStyle(fontSize: 15, color: AppColors.brownSoft);
  static const small = TextStyle(fontSize: 13, color: AppColors.brownSoft);

  static TextStyle brandStyle({
    double fontSize = 30,
    Color color = AppColors.tomato,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return GoogleFonts.fredoka(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}