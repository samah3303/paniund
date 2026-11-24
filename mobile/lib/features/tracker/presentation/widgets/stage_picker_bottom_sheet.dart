import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/status_pill.dart';

class StagePickerBottomSheet extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onSelectStage;

  const StagePickerBottomSheet({
    super.key,
    required this.currentStatus,
    required this.onSelectStage,
  });

  static const List<({String value, String label, IconData icon})> stages = [
    (value: "wishlist", label: "Wishlist / Saved", icon: Icons.bookmark_border_rounded),
    (value: "applied", label: "Applied", icon: Icons.send_rounded),
    (value: "phone_screen", label: "Screening / Recruiter Call", icon: Icons.phone_in_talk_rounded),
    (value: "interview", label: "Interview Rounds", icon: Icons.group_rounded),
    (value: "offer", label: "Job Offer Received", icon: Icons.celebration_rounded),
    (value: "rejected", label: "Archived / Closed", icon: Icons.archive_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: NordicColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NordicColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Update Application Stage", style: NordicTypography.h2),
            const SizedBox(height: 4),
            Text(
              "Keep your career pipeline organized across hiring milestones.",
              style: NordicTypography.bodySmall,
            ),
            const SizedBox(height: 16),

            ...stages.map((stage) {
              final isCurrent = currentStatus.toLowerCase() == stage.value ||
                  (stage.value == "phone_screen" && currentStatus.toLowerCase() == "screening") ||
                  (stage.value == "rejected" && currentStatus.toLowerCase() == "archived");

              final meta = StatusPill.getStatusMeta(stage.value);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isCurrent ? meta.bg : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onSelectStage(stage.value);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(stage.icon, size: 20, color: meta.fg),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              stage.label,
                              style: GoogleFonts.notoSans(
                                fontSize: 14,
                                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                                color: isCurrent ? NordicColors.textDark : NordicColors.textDark,
                              ),
                            ),
                          ),
                          if (isCurrent)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: NordicColors.navy,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
