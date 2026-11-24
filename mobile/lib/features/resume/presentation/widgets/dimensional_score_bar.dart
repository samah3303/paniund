import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';

class DimensionalScoreBar extends StatelessWidget {
  final String label;
  final int score;
  final String weightDescription;
  final IconData? icon;

  const DimensionalScoreBar({
    super.key,
    required this.label,
    required this.score,
    required this.weightDescription,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final clampedScore = score.clamp(0, 100);
    final color = NordicColors.getScoreColor(clampedScore);
    final bgColor = NordicColors.getScoreBgColor(clampedScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: NordicColors.navy),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: NordicColors.textDark,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "$clampedScore",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  "/100",
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: NordicColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 7,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: clampedScore / 100.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: bgColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          weightDescription,
          style: GoogleFonts.notoSans(
            fontSize: 10.5,
            color: NordicColors.textMuted,
          ),
        ),
      ],
    );
  }
}
