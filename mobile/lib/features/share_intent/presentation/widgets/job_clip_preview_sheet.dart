import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../controllers/share_intent_controller.dart';
import 'clip_skill_match_chips.dart';

class JobClipPreviewSheet extends ConsumerWidget {
  const JobClipPreviewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shareIntentControllerProvider);
    final job = state.clippedJob;

    if (state.isAnalyzing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        decoration: const BoxDecoration(
          color: NordicColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingIndicator(
                message: "Clipping job listing & calculating ATS score against your resume...",
              ),
            ],
          ),
        ),
      );
    }

    if (state.errorMessage != null && job == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: const BoxDecoration(
          color: NordicColors.surfaceWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: NordicColors.scoreLow, size: 42),
              const SizedBox(height: 12),
              Text("Could Not Clip Listing", style: NordicTypography.h3),
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                style: NordicTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              NordicButton(
                label: "Dismiss",
                variant: NordicButtonVariant.navy,
                fullWidth: true,
                onPressed: () {
                  ref.read(shareIntentControllerProvider.notifier).reset();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (job == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: NordicColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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

              // Header Badge & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: NordicColors.yellowLight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: NordicColors.yellowHover.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.share_rounded, size: 12, color: NordicColors.navyDark),
                        const SizedBox(width: 4),
                        Text(
                          "Clipped from ${job.source}",
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: NordicColors.navyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: NordicColors.textMuted),
                    onPressed: () {
                      ref.read(shareIntentControllerProvider.notifier).reset();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),

              Text(job.title, style: NordicTypography.h2),
              const SizedBox(height: 2),
              Text(
                job.company,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: NordicColors.textMuted),
              ),
              const SizedBox(height: 16),

              // ATS Match Score Gauge
              NordicCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                leftAccentColor: NordicColors.getScoreColor(job.matchScore),
                child: Row(
                  children: [
                    AtsScoreMeter(
                      score: job.matchScore,
                      size: 90,
                      label: "Match",
                      showTierLabel: false,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.matchScore >= 80
                                ? "Strong Algorithm Match"
                                : job.matchScore >= 60
                                    ? "Moderate Compatibility"
                                    : "High ATS Risk",
                            style: NordicTypography.h3.copyWith(
                              color: NordicColors.getScoreColor(job.matchScore),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Based on active skills and experience in your primary resume.",
                            style: NordicTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Matched vs Missing Skills Chips
              if (job.matchedSkills.isNotEmpty || job.missingSkills.isNotEmpty) ...[
                NordicCard(
                  child: ClipSkillMatchChips(
                    matchedSkills: job.matchedSkills,
                    missingSkills: job.missingSkills,
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // Action Buttons
              NordicButton(
                label: "Save as Applied",
                icon: const Icon(Icons.check_rounded, size: 18),
                variant: NordicButtonVariant.primary,
                fullWidth: true,
                isLoading: state.isSaving,
                onPressed: () async {
                  final success = await ref
                      .read(shareIntentControllerProvider.notifier)
                      .saveWithStatus("applied");
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Saved '${job.title}' to Applied pipeline!"),
                        backgroundColor: NordicColors.navy,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: NordicButton(
                      label: "Save to Wishlist",
                      variant: NordicButtonVariant.outline,
                      isLoading: state.isSaving,
                      onPressed: () async {
                        final success = await ref
                            .read(shareIntentControllerProvider.notifier)
                            .saveWithStatus("wishlist");
                        if (success && context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Saved '${job.title}' to Wishlist!"),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: NordicButton(
                      label: "Draft Letter",
                      variant: NordicButtonVariant.navy,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(RouteNames.generator);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
