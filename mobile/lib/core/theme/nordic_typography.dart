import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nordic_colors.dart';

class NordicTypography {
  // Heading styles (Noto Sans)
  static TextStyle get h1 => GoogleFonts.notoSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: NordicColors.textDark,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: NordicColors.textDark,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: NordicColors.textDark,
      );

  // Body styles (Noto Sans)
  static TextStyle get bodyLarge => GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: NordicColors.textDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.notoSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: NordicColors.textDark,
        height: 1.4,
      );

  static TextStyle get bodySmall => GoogleFonts.notoSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: NordicColors.textMuted,
      );

  // Monospace styles for ATS Scores, Keywords & Metrics (JetBrains Mono)
  static TextStyle get scoreMetric => GoogleFonts.jetbrainsMono(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      );

  static TextStyle get scoreSmall => GoogleFonts.jetbrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get codeSnippet => GoogleFonts.jetbrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: NordicColors.navyDark,
      );

  static TextStyle get pillLabel => GoogleFonts.jetbrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );
}
