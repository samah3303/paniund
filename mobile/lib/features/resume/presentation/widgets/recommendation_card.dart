import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../shared/widgets/nordic_card.dart';

enum RecommendationPriority {
  high,
  medium,
  low,
}

class RecommendationCard extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback? onApply;

  const RecommendationCard({
    super.key,
    required this.text,
    required this.index,
    this.onApply,
  });

  RecommendationPriority get priority {
    if (index == 0 || text.toLowerCase().contains("metric") || text.toLowerCase().contains("quantif")) {
      return RecommendationPriority.high;
    }
    if (index < 3 || text.toLowerCase().contains("keyword") || text.toLowerCase().contains("skill")) {
      return RecommendationPriority.medium;
    }
    return RecommendationPriority.low;
  }

  @override
  Widget build(BuildContext context) {
    Color badgeFg;
    Color badgeBg;
    String badgeLabel;

    switch (priority) {
      case RecommendationPriority.high:
        badgeFg = NordicColors.scoreLow;
        badgeBg = NordicColors.scoreLowBg;
        badgeLabel = "HIGH IMPACT";
        break;
      case RecommendationPriority.medium:
        badgeFg = NordicColors.scoreMed;
        badgeBg = NordicColors.scoreMedBg;
        badgeLabel = "RECOMMENDED";
        break;
      case RecommendationPriority.low:
        badgeFg = NordicColors.navy;
        badgeBg = const Color(0xFFEBF5FF);
        badgeLabel = "OPTIMIZATION";
        break;
    }

    return NordicCard(
      padding: const EdgeInsets.all(14),
      leftAccentColor: badgeFg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.jetbrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: badgeFg,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(Icons.lightbulb_outline_rounded, size: 16, color: badgeFg),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.notoSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: NordicColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
