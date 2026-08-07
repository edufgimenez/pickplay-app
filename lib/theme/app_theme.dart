import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta Neon Dark Romantic
  static const Color backgroundDeep = Color(0xFF100720);
  static const Color backgroundCard = Color(0xFF1C1035);
  static const Color backgroundCardLight = Color(0xFF2A184E);
  
  static const Color primaryPink = Color(0xFFFF2975);
  static const Color primaryPurple = Color(0xFF8C1EFF);
  static const Color accentCyan = Color(0xFF00F2FE);
  static const Color accentGold = Color(0xFFFFC837);
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8A9D9);
  static const Color textMuted = Color(0xFF7A68A6);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryPink, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF140A28), Color(0xFF0A0318)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDeep,
      primaryColor: primaryPink,
      colorScheme: const ColorScheme.dark(
        primary: primaryPink,
        secondary: primaryPurple,
        surface: backgroundCard,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.fredoka(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.fredoka(color: textPrimary, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.poppins(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.poppins(color: textPrimary),
        bodyMedium: GoogleFonts.poppins(color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 6,
        shadowColor: primaryPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      useMaterial3: true,
    );
  }
}
