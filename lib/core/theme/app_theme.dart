import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const navy = Color(0xFF0A192F);
  static const emerald = Color(0xFF10B981);
  static const surface = Color(0xFFF3F5F6);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: navy,
      scaffoldBackgroundColor: Colors.white,
      textTheme: GoogleFonts.manropeTextTheme(),
      colorScheme: ColorScheme.fromSeed(
        seedColor: navy,
        primary: navy,
        secondary: emerald,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 20),
      ),
    );
  }
}