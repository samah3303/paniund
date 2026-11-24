import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';

class ClipSkillMatchChips extends StatelessWidget {
  final List<String> matchedSkills;
  final List<String> missingSkills;

  const ClipSkillMatchChips({
    super.key,
    required this.matchedSkills,
    required this.missingSkills,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (matchedSkills.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 14, color: NordicColors.scoreHigh),
              const SizedBox(width: 6),
              Text(
                "Matched Resume Skills (${matchedSkills.length})",
                style: GoogleFonts.notoSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: NordicColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: matchedSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NordicColors.scoreHighBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NordicColors.scoreHigh.withOpacity(0.3)),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.jetbrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NordicColors.scoreHigh,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
        ],

        if (missingSkills.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 14, color: NordicColors.scoreMed),
              const SizedBox(width: 6),
              Text(
                "Missing Keywords in Resume (${missingSkills.length})",
                style: GoogleFonts.notoSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: NordicColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: missingSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: NordicColors.scoreMedBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: NordicColors.scoreMed.withOpacity(0.3)),
                ),
                child: Text(
                  skill,
                  style: GoogleFonts.jetbrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: NordicColors.scoreMed,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
