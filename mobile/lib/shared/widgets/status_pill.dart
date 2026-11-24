import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/nordic_colors.dart';

class StatusPill extends StatelessWidget {
  final String status;
  final VoidCallback? onTap;

  const StatusPill({
    super.key,
    required this.status,
    this.onTap,
  });

  static ({Color fg, Color bg, String label}) getStatusMeta(String rawStatus) {
    final s = rawStatus.toLowerCase().trim();
    switch (s) {
      case "saved":
      case "wishlist":
        return (
          fg: NordicColors.statusSaved,
          bg: const Color(0xFFF3F4F6),
          label: "Saved",
        );
      case "applied":
        return (
          fg: NordicColors.statusApplied,
          bg: const Color(0xFFE0F2FE),
          label: "Applied",
        );
      case "screening":
      case "review":
        return (
          fg: NordicColors.statusScreening,
          bg: const Color(0xFFF3E8FF),
          label: "Screening",
        );
      case "interviewing":
      case "interview":
        return (
          fg: NordicColors.statusInterviewing,
          bg: const Color(0xFFFEF3C7),
          label: "Interviewing",
        );
      case "offer":
      case "offered":
        return (
          fg: NordicColors.statusOffer,
          bg: const Color(0xFFDCFCE7),
          label: "Offer",
        );
      case "rejected":
        return (
          fg: NordicColors.statusRejected,
          bg: const Color(0xFFFEE2E2),
          label: "Rejected",
        );
      default:
        return (
          fg: NordicColors.textMuted,
          bg: NordicColors.borderLight,
          label: rawStatus,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meta = getStatusMeta(status);

    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: meta.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: meta.fg.withOpacity(0.25), width: 1),
      ),
      child: Text(
        meta.label,
        style: GoogleFonts.jetbrainsMono(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: meta.fg,
          letterSpacing: 0.1,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: pill,
      );
    }

    return pill;
  }
}
