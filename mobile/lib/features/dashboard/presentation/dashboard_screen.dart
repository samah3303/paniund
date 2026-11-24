import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../resume/presentation/controllers/resume_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeControllerProvider);
    final audit = resumeState.audit;
    final profile = resumeState.profile;
    final score = audit?.overallScore ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("paniund"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Profile",
            onPressed: () => ref.read(resumeControllerProvider.notifier).loadProfile(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate Welcome Banner
            NordicCard(
              leftAccentColor: score > 0 ? NordicColors.getScoreColor(score) : NordicColors.yellow,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Resume ATS Health",
                              style: NordicTypography.h2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.resumeFileName != null
                                  ? "File: ${profile!.resumeFileName}"
                                  : "Upload your resume to pass algorithmic recruiter filters.",
                              style: NordicTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: AtsScoreMeter(
                      score: score,
                      size: 135,
                      showTierLabel: score > 0,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: NordicButton(
                          label: score > 0 ? "Re-upload Resume" : "Upload Resume",
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          variant: NordicButtonVariant.primary,
                          onPressed: () => context.push(RouteNames.resumeUpload),
                        ),
                      ),
                      if (score > 0) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: NordicButton(
                            label: "Audit Report",
                            icon: const Icon(Icons.analytics_outlined, size: 18),
                            variant: NordicButtonVariant.outline,
                            onPressed: () => context.push(RouteNames.resumeAudit),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Stats
            Text("Active Pipeline", style: NordicTypography.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NordicCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("12", style: NordicTypography.scoreMetric.copyWith(fontSize: 24, color: NordicColors.navy)),
                        const SizedBox(height: 2),
                        Text("Applied", style: NordicTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NordicCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("3", style: NordicTypography.scoreMetric.copyWith(fontSize: 24, color: NordicColors.scoreMed)),
                        const SizedBox(height: 2),
                        Text("Interviewing", style: NordicTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NordicCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("1", style: NordicTypography.scoreMetric.copyWith(fontSize: 24, color: NordicColors.scoreHigh)),
                        const SizedBox(height: 2),
                        Text("Offer", style: NordicTypography.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
