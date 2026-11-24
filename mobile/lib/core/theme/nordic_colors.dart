import 'package:flutter/material.dart';

/// Nordic Yellow Design System Color Palette
class NordicColors {
  // Brand Colors
  static const Color navy = Color(0xFF003399); // Primary Deep Navy
  static const Color navyDark = Color(0xFF002266); // Active / Header
  static const Color navyLight = Color(0xFF1A4DB8); // Accent Navy
  static const Color yellow = Color(0xFFFFDA1A); // Accent Warm Yellow
  static const Color yellowHover = Color(0xFFECC400); // Yellow pressed / hover
  static const Color yellowLight = Color(0xFFFFF9DB); // Subtle yellow tint

  // Surfaces & Backgrounds
  static const Color canvasLight = Color(0xFFF5F5F5); // Background Light
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Card / Sheet surface
  static const Color surfaceSecondary = Color(0xFFFAFAFA); // Muted surface
  static const Color borderLight = Color(0xFFE5E7EB); // Clean border
  static const Color borderSubtle = Color(0xFFD1D5DB); // Neutral border

  // Text & Content
  static const Color textDark = Color(0xFF1A1A1A); // Primary body text
  static const Color textMuted = Color(0xFF6B7280); // Secondary / subtitle text
  static const Color textLight = Color(0xFF9CA3AF); // Inactive text
  static const Color textInverse = Color(0xFFFFFFFF); // On Navy text

  // ATS Score & Status Tiers
  static const Color scoreHigh = Color(0xFF0A8A00); // Score >= 80 (Green)
  static const Color scoreMed = Color(0xFFD97706); // Score 60-79 (Amber)
  static const Color scoreLow = Color(0xFFDC2626); // Score < 60 (Red)
  static const Color scoreHighBg = Color(0xFFE8F5E9);
  static const Color scoreMedBg = Color(0xFFFEF3C7);
  static const Color scoreLowBg = Color(0xFFFEE2E2);

  // Status Colors for Job Tracker CRM
  static const Color statusSaved = Color(0xFF6B7280);
  static const Color statusApplied = Color(0xFF0284C7);
  static const Color statusScreening = Color(0xFF7C3AED);
  static const Color statusInterviewing = Color(0xFFD97706);
  static const Color statusOffer = Color(0xFF0A8A00);
  static const Color statusRejected = Color(0xFFDC2626);

  static Color getScoreColor(int score) {
    if (score >= 80) return scoreHigh;
    if (score >= 60) return scoreMed;
    return scoreLow;
  }

  static Color getScoreBgColor(int score) {
    if (score >= 80) return scoreHighBg;
    if (score >= 60) return scoreMedBg;
    return scoreLowBg;
  }
}
