import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF027BFF);
  static const Color grey = Color(0xFF363636);
  static const Color softBlue = Color(0xFFE1F0FF);
  
  // Additional colors for better theming
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Semantic colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53E3E);
  
  // Text colors
  static const Color textPrimary = Color(0xFF363636);
  static const Color textSecondary = Color(0xFF6B7280);
  
  // Opacity variations
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);
  static Color greyWithOpacity(double opacity) => grey.withOpacity(opacity);
  static Color softBlueWithOpacity(double opacity) => softBlue.withOpacity(opacity);
} 