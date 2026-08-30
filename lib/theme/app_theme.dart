import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5148D8);

  static const Color navy = Color(0xFF18245C);
  static const Color darkNavy = Color(0xFF0D1238);

  static const Color cyan = Color(0xFF5BCAFF);
  static const Color orange = Color(0xFFFFA044);

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,

    useMaterial3: true,

    scaffoldBackgroundColor:
        const Color(0xFFF7F8FC),

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: cyan,

      surface: Colors.white,

      onPrimary: Colors.white,
      onSecondary: Colors.white,

      onSurface: Color(0xFF18204A),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: navy,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFE6E8F0),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: navy,
      indicatorColor: primary,

      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF2F3F8),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primary,
          width: 1.5,
        ),
      ),
    ),
  );

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    useMaterial3: true,

    scaffoldBackgroundColor:
        const Color(0xFF0D1028),

    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF8178FF),
      secondary: Color(0xFF5BCAFF),

      surface: Color(0xFF171B3A),

      onPrimary: Colors.white,
      onSecondary: Colors.white,

      onSurface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0D1028),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF171B3A),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF292E50),
    ),

    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF080B20),
      indicatorColor: primary,

      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF171B3A),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF8178FF),
          width: 1.5,
        ),
      ),
    ),
  );
}