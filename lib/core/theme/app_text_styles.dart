import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading = GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
    height: 1.1,
  );

  static TextStyle authHeading = GoogleFonts.poppins(
    fontSize: 42,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
    height: 1.15,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 26,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.labelText,
    letterSpacing: 0.5,
  );

  static TextStyle input = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.darkText,
  );

  static TextStyle hint = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.hintText,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 21,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle link = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  static TextStyle footer = GoogleFonts.poppins(
    fontSize: 19,
    fontWeight: FontWeight.w400,
    color: AppColors.secondaryText,
  );
}