import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  static TextStyle get h1 => GoogleFonts.fredoka(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: AppColors.brown,
        height: 1.15,
      );

  static TextStyle get h2 => GoogleFonts.fredoka(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.brown,
      );

  static TextStyle get title => GoogleFonts.fredoka(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.brown,
      );

  static TextStyle get body => GoogleFonts.fredoka(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.brownSoft,
      );

  static TextStyle get small => GoogleFonts.fredoka(
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