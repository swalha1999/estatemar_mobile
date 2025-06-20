import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';
import 'text_styles.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.softBlue,
        surface: Colors.white,
        background: Colors.white,
        onPrimary: Colors.white,
        onSecondary: AppColors.grey,
        onSurface: AppColors.grey,
        onBackground: AppColors.grey,
      ),
      textTheme: GoogleFonts.montserratTextTheme(AppTextStyles.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.grey),
        titleTextStyle: AppTextStyles.headline6.copyWith(
          color: AppColors.grey,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          color: AppColors.grey.withOpacity(0.6),
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
    );
  }
} 