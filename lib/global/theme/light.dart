import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Utils/AppColors/app_colors.dart';

ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primaryGreen,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      primary: AppColors.primaryGreen,
      secondary: AppColors.accentGreen,
      surface: AppColors.cardSurface,
    ),
    fontFamily: GoogleFonts.hindSiliguri().fontFamily,
    textTheme: GoogleFonts.hindSiliguriTextTheme(),
  );
}
