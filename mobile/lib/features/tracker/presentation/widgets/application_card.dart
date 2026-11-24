import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../data/models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onTap;
  final VoidCallback onQuickStageChange;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.onQuickStageChange,
  });

  String _formatDate(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat("MMM d, y").format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final job = application.job;
    final hasInterview = application.interviewDate != null;
    final isInterviewSoon = application.isInterviewSoon;

    return NordicCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      leftAccentColor: hasInterview
          ? (isInterviewSoon ? NordicColors.yellow : NordicColors.statusInterviewing)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Role & ATS Score
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: NordicTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.company ?? "Unknown Company",
                      style: GoogleFonts.notoSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: NordicColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (application.atsScore != null && application.atsScore! > 0)
                ScoreBadge(score: application.atsScore!),
            ],
          ),
          const SizedBox(height: 10),

          // Location & Salary
          if (job.location != null || job.salary != null) ...[
            Row(
              children: [
                if (job.location != null) ...[
                  const Icon(Icons.location_on_outlined, size: 13, color: NordicColors.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    job.location!,
                    style: const TextStyle(fontSize: 11.5, color: NordicColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                ],
                if (job.salary != null) ...[
                  const Icon(Icons.attach_money_rounded, size: 13, color: NordicColors.textMuted),
                  Text(
                    job.salary!,
                    style: const TextStyle(fontSize: 11.5, color: NordicColors.textMuted),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Upcoming Interview Banner
          if (hasInterview) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isInterviewSoon ? NordicColors.yellowLight : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isInterviewSoon ? NordicColors.yellowHover : const Color(0xFFF59E0B),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 14,
                    color: isInterviewSoon ? NordicColors.navyDark : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isInterviewSoon
                        ? "Interview in <48h: ${_formatDate(application.interviewDate)}"
                        : "Interview: ${_formatDate(application.interviewDate)}",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isInterviewSoon ? NordicColors.navyDark : const Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Footer: Status Pill & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusPill(
                status: application.status,
                onTap: onQuickStageChange,
              ),
              if (application.appliedAt != null)
                Text(
                  "Applied ${_formatDate(application.appliedAt)}",
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: NordicColors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
