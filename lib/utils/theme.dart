import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors - minimal and clean with warm accents
  static const Color primaryColor = Color(0xFFFF9800); // Warm orange accent
  static const Color secondaryColor = Color(0xFFFFC107); // Golden yellow accent
  static const Color accentColor = Color(0xFFFFB300); // Amber accent
  
  // Neutral colors - clean white and black
  static const Color backgroundColor = Colors.white; // Pure white
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Color(0xFFFAFAFA); // Off-white for subtle distinction
  static const Color textPrimaryColor = Color(0xFF000000); // Pure black
  static const Color textSecondaryColor = Color(0xFF000000); // Black (changed from gray for better visibility)
  static const Color dividerColor = Color(0xFFE0E0E0); // Light gray
  
  // Status colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color infoColor = Color(0xFF2196F3);

  // Light theme - clean and minimal
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: textPrimaryColor,
      selectionColor: textSecondaryColor,
      selectionHandleColor: primaryColor,
    ),
    iconTheme: const IconThemeData(
      color: textPrimaryColor,
    ),
    primaryIconTheme: const IconThemeData(
      color: textPrimaryColor,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: textPrimaryColor,
      onSurface: textPrimaryColor,
      onBackground: textPrimaryColor,
      onError: Colors.white,
      // Container colors for Material 3 - light tints with dark text
      primaryContainer: Color(0xFFFFE0B2), // Light orange tint
      onPrimaryContainer: textPrimaryColor, // Black text on light container
      secondaryContainer: Color(0xFFFFF9C4), // Light yellow tint
      onSecondaryContainer: textPrimaryColor, // Black text on light container
      tertiaryContainer: Color(0xFFFFF8E1), // Light amber tint
      onTertiaryContainer: textPrimaryColor, // Black text on light container
      surfaceVariant: cardColor,
      onSurfaceVariant: textPrimaryColor,
    ),
    
    // App Bar Theme - clean and minimal
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Colors.white,
      foregroundColor: textPrimaryColor,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: textPrimaryColor, size: 24),
      titleTextStyle: TextStyle(
        color: textPrimaryColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),

    // Card Theme - minimal with subtle shadows
    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: surfaceColor,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    ),

    // Button Themes - clean and minimal
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: textPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        side: const BorderSide(color: textPrimaryColor, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: textPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),

    // Input Decoration Theme - clean lines
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: textPrimaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: const TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: const TextStyle(
        color: textPrimaryColor,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        color: textSecondaryColor,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Text Theme - clean and readable
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.2,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.3,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        height: 1.4,
        letterSpacing: -0.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryColor,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondaryColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimaryColor,
        letterSpacing: 0.5,
      ),
    ),
  );

  // Dark theme - minimal and clean
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF000000),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      surface: Color(0xFF1A1A1A),
      background: Color(0xFF000000),
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF000000),
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white, size: 24),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    ),
  );
}

