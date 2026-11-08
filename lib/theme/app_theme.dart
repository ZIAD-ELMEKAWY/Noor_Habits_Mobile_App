import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const emerald = Color(0xFF1B7A5E);
  static const sage = Color(0xFF8FBCA6);
  static const gold = Color(0xFFE8A33D);
  static const navy = Color(0xFF0E1B2C);
  static const charcoal = Color(0xFF161D27);

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness b) {
    final dark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: emerald,
      brightness: b,
      primary: emerald,
      secondary: gold,
      surface: dark ? charcoal : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? navy : const Color(0xFFF4F6F5),
      textTheme: GoogleFonts.tajawalTextTheme(
        ThemeData(brightness: b).textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: dark ? Colors.white : charcoal,
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? charcoal : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? charcoal : Colors.white,
        indicatorColor: emerald.withOpacity(.15),
      ),
    );
  }
}
