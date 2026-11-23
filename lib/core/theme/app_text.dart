import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static final h1 = GoogleFonts.fredoka(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.brown,
    height: 1.1,
  );

  static final h2 = GoogleFonts.fredoka(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.brown,
  );

  static final title = GoogleFonts.fredoka(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.brown,
  );

  static final body = GoogleFonts.fredoka(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.brownSoft,
  );

  static final small = GoogleFonts.fredoka(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.brownSoft,
  );

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