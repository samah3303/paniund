import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nordic_colors.dart';

class NordicTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.notoSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: NordicColors.navy,
      scaffoldBackgroundColor: NordicColors.canvasLight,
      colorScheme: const ColorScheme.light(
        primary: NordicColors.navy,
        onPrimary: NordicColors.textInverse,
        secondary: NordicColors.yellow,
        onSecondary: NordicColors.textDark,
        surface: NordicColors.surfaceWhite,
        onSurface: NordicColors.textDark,
        error: NordicColors.scoreLow,
        onError: NordicColors.textInverse,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.notoSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: NordicColors.textDark,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NordicColors.textDark,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: NordicColors.textDark,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: NordicColors.textDark,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NordicColors.navy,
        foregroundColor: NordicColors.textInverse,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: NordicColors.textInverse,
          letterSpacing: 0.2,
        ),
        iconTheme: const IconThemeData(color: NordicColors.textInverse),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NordicColors.surfaceWhite,
        selectedItemColor: NordicColors.navy,
        unselectedItemColor: NordicColors.textMuted,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: NordicColors.surfaceWhite,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: NordicColors.borderLight, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NordicColors.surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        hintStyle: GoogleFonts.notoSans(
          fontSize: 13,
          color: NordicColors.textMuted,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NordicColors.borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NordicColors.borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NordicColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: NordicColors.scoreLow, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NordicColors.borderLight,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
