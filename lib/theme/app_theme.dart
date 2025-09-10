import 'package:flutter/material.dart';

class AppTheme {
  // Font Family - Montserrat only
  static const String fontFamily = 'Montserrat';
  
  // 4 Font Sizes - Based on analysis of the app
  static const double fontSizeSmall = 12.0;    // Captions, labels, small text
  static const double fontSizeMedium = 14.0;   // Body text, buttons, form fields
  static const double fontSizeLarge = 16.0;    // Headings, important text
  static const double fontSizeXLarge = 18.0;   // Large headings, titles
  
  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // Color Palette - All colors used in the app
  static const Color primary = Color(0xFF027BFF);
  static const Color primaryLight = Color(0xFFE1F0FF);
  static const Color primaryDark = Color(0xFF0056CC);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF363636);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFD1D5DB);
  
  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  static const Color backgroundTertiary = Color(0xFFF3F4F6);
  static const Color backgroundCard = Color(0xFFF8FAFC);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  // Accent Colors
  static const Color orange = Color(0xFFFF9800);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF3E8FF);
  static const Color green = Color(0xFF4CAF50);
  static const Color greenLight = Color(0xFFE8F5E8);
  static const Color blue = Color(0xFF2196F3);
  static const Color blueLight = Color(0xFFE3F2FD);
  static const Color indigo = Color(0xFF6366F1);
  static const Color indigoLight = Color(0xFFEEF2FF);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  
  // Text Styles - 4 sizes with Montserrat font
  static const TextStyle textSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: textSecondary,
  );
  
  static const TextStyle textMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeMedium,
    fontWeight: fontWeightRegular,
    color: textPrimary,
  );
  
  static const TextStyle textLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLarge,
    fontWeight: fontWeightMedium,
    color: textPrimary,
  );
  
  static const TextStyle textXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXLarge,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  // Heading Styles
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeMedium,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLarge,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static const TextStyle headingXLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeXLarge,
    fontWeight: fontWeightBold,
    color: textPrimary,
  );
  
  // Button Styles
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: white,
  );
  
  static const TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeMedium,
    fontWeight: fontWeightSemiBold,
    color: white,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLarge,
    fontWeight: fontWeightSemiBold,
    color: white,
  );
  
  // Status Text Styles
  static const TextStyle statusSuccess = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: success,
  );
  
  static const TextStyle statusWarning = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: warning,
  );
  
  static const TextStyle statusError = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: error,
  );
  
  static const TextStyle statusInfo = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: info,
  );
  
  // Form Field Styles
  static const TextStyle formLabel = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightMedium,
    color: textSecondary,
  );
  
  static const TextStyle formHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: textTertiary,
  );
  
  static const TextStyle formInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeMedium,
    fontWeight: fontWeightRegular,
    color: textPrimary,
  );
  
  // Card Styles
  static const TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeLarge,
    fontWeight: fontWeightSemiBold,
    color: textPrimary,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeMedium,
    fontWeight: fontWeightRegular,
    color: textSecondary,
  );
  
  static const TextStyle cardCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSizeSmall,
    fontWeight: fontWeightRegular,
    color: textTertiary,
  );
  
  // Theme Components
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: background,
    foregroundColor: textPrimary,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: headingLarge,
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),
  );
  
  static BottomNavigationBarThemeData get bottomNavigationBarTheme => BottomNavigationBarThemeData(
    backgroundColor: background,
    selectedItemColor: primary,
    unselectedItemColor: textTertiary,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: textSmall.copyWith(
      color: primary,
      fontWeight: fontWeightSemiBold,
    ),
    unselectedLabelStyle: textSmall.copyWith(
      color: textTertiary,
    ),
  );
  
  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: backgroundSecondary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: error, width: 2),
    ),
    labelStyle: formLabel,
    hintStyle: formHint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
  
  static CardThemeData get cardTheme => CardThemeData(
    color: background,
    elevation: 2,
    shadowColor: black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
  
  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: white,
      elevation: 2,
      shadowColor: primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: buttonMedium,
    ),
  );
  
  static OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: const BorderSide(color: primary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: buttonMedium,
    ),
  );
  
  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      textStyle: textMedium.copyWith(
        color: primary,
        fontWeight: fontWeightMedium,
      ),
    ),
  );
  
  // Main Theme Data
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryLight,
      surface: background,
      background: background,
      onPrimary: white,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onBackground: textPrimary,
      error: error,
      onError: white,
    ),
    textTheme: const TextTheme(
      displayLarge: headingXLarge,
      displayMedium: headingLarge,
      displaySmall: headingMedium,
      headlineLarge: headingXLarge,
      headlineMedium: headingLarge,
      headlineSmall: headingMedium,
      titleLarge: headingLarge,
      titleMedium: headingMedium,
      titleSmall: headingSmall,
      bodyLarge: textLarge,
      bodyMedium: textMedium,
      bodySmall: textSmall,
      labelLarge: buttonMedium,
      labelMedium: textMedium,
      labelSmall: textSmall,
    ),
    appBarTheme: appBarTheme,
    bottomNavigationBarTheme: bottomNavigationBarTheme,
    inputDecorationTheme: inputDecorationTheme,
    cardTheme: cardTheme,
    elevatedButtonTheme: elevatedButtonTheme,
    outlinedButtonTheme: outlinedButtonTheme,
    textButtonTheme: textButtonTheme,
    scaffoldBackgroundColor: background,
  );
  
  // Helper methods for dynamic theming
  static TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize ?? fontSizeMedium,
      fontWeight: fontWeight ?? fontWeightRegular,
      color: color ?? textPrimary,
      decoration: decoration,
    );
  }
  
  static BoxDecoration getCardDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? background,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null ? Border.all(color: borderColor) : null,
      boxShadow: boxShadow ?? [
        BoxShadow(
          color: black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  static BoxDecoration getStatusDecoration({
    required Color backgroundColor,
    required Color borderColor,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1),
    );
  }
} 