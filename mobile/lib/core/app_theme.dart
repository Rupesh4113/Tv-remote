import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF121418);
  static const Color darkSurface = Color(0xFF1E222B);
  static const Color darkSurfaceVariant = Color(0xFF282E3A);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentOrange = Color(0xFFFF9100);
  static const Color accentRed = Color(0xFFFF3D00);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentYellow = Color(0xFFFFD600);
  static const Color accentBlue = Color(0xFF2979FF);

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: accentCyan,
      secondary: accentOrange,
      surface: darkSurface,
      background: darkBackground,
      error: accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCyan,
        foregroundColor: Colors.black,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF4F6F9),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00838F),
      secondary: accentOrange,
      surface: Colors.white,
      background: Color(0xFFF4F6F9),
      error: accentRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0.5,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
