import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/nordic_colors.dart';

/// Large circular ATS Score Meter with animation
class AtsScoreMeter extends StatelessWidget {
  final int score;
  final double size;
  final String? label;
  final bool showTierLabel;

  const AtsScoreMeter({
    super.key,
    required this.score,
    this.size = 140.0,
    this.label = "ATS Score",
    this.showTierLabel = true,
  });

  String get tierLabel {
    if (score >= 80) return "Excellent Match";
    if (score >= 60) return "Moderate Match";
    return "Needs Improvement";
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = NordicColors.getScoreColor(score);
    final scoreBgColor = NordicColors.getScoreBgColor(score);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: (score.clamp(0, 100)) / 100.0),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Outer track
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreBgColor),
                    ),
                  ),
                  // Progress indicator
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    ),
                  ),
                  // Centered score value
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(value * 100).toInt()}",
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: size * 0.28,
                          fontWeight: FontWeight.w800,
                          color: NordicColors.textDark,
                          letterSpacing: -1.0,
                        ),
                      ),
                      if (label != null)
                        Text(
                          label!,
                          style: GoogleFonts.notoSans(
                            fontSize: size * 0.08,
                            fontWeight: FontWeight.w600,
                            color: NordicColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        if (showTierLabel) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scoreBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: scoreColor.withOpacity(0.3)),
            ),
            child: Text(
              tierLabel,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact badge for list tiles and job cards
class ScoreBadge extends StatelessWidget {
  final int score;
  final bool compact;

  const ScoreBadge({
    super.key,
    required this.score,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = NordicColors.getScoreColor(score);
    final bgColor = NordicColors.getScoreBgColor(score);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.speed_rounded,
            size: compact ? 12 : 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            "$score%",
            style: GoogleFonts.jetBrainsMono(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
