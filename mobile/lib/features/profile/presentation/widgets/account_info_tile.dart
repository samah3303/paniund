import 'package:flutter/material.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/nordic_card.dart';

class AccountInfoTile extends StatelessWidget {
  final String name;
  final String email;
  final int? atsScore;

  const AccountInfoTile({
    super.key,
    required this.name,
    required this.email,
    this.atsScore,
  });

  @override
  Widget build(BuildContext context) {
    final initial = (name.isNotEmpty ? name[0] : (email.isNotEmpty ? email[0] : "P")).toUpperCase();

    return NordicCard(
      leftAccentColor: atsScore != null && atsScore! > 0 ? NordicColors.getScoreColor(atsScore!) : NordicColors.navy,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: NordicColors.navy,
            child: Text(
              initial,
              style: NordicTypography.h1.copyWith(
                fontSize: 22,
                color: NordicColors.textInverse,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : "Candidate",
                  style: NordicTypography.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: NordicTypography.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: NordicColors.scoreHighBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Verified Candidate",
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: NordicColors.scoreHigh,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (atsScore != null && atsScore! > 0)
            ScoreBadge(score: atsScore!),
        ],
      ),
    );
  }
}
