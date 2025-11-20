import 'package:flutter/material.dart';

class AppTheme {
  static const Color accent = Color(0xFFBFBFBF);
  static const Color lightBackground = Color(0xFFF2F2F2);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFD9D9D9);
  static const Color darkBackground = Color(0xFF202020);
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF202020);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: accent,
    colorScheme: const ColorScheme.light(
      primary: accent,
      secondary: accent,
      background: lightBackground,
      surface: lightSurface,
      onPrimary: Color(0xFF202020),
      onSecondary: Color(0xFF202020),
      onSurface: Color(0xFF202020),
      onBackground: Color(0xFF202020),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      foregroundColor: Color(0xFF202020),
      elevation: 0,
    ),
    cardColor: lightSurface,
    dividerColor: lightBorder,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: accent,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accent,
      background: darkBackground,
      surface: darkSurface,
      onPrimary: black,
      onSecondary: black,
      onSurface: white,
      onBackground: white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: white,
      elevation: 0,
    ),
    cardColor: darkSurface,
    dividerColor: Colors.white24,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    ),
  );
}

