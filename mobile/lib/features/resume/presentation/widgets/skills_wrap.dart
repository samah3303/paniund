import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';

class SkillsWrap extends StatelessWidget {
  final List<String> skills;
  final String title;
  final bool isMissing;

  const SkillsWrap({
    super.key,
    required this.skills,
    this.title = "Detected Keywords & Skills",
    this.isMissing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    final fgColor = isMissing ? NordicColors.scoreLow : NordicColors.navy;
    final bgColor = isMissing ? NordicColors.scoreLowBg : const Color(0xFFF0F4FA);
    final borderColor = isMissing ? NordicColors.scoreLow.withOpacity(0.3) : NordicColors.borderLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: NordicColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMissing ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    size: 13,
                    color: fgColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    skill,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
