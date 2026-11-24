import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../controllers/resume_controller.dart';
import '../widgets/dimensional_score_bar.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/skills_wrap.dart';

class ResumeOverviewScreen extends ConsumerWidget {
  const ResumeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeControllerProvider);
    final audit = resumeState.audit;
    final profile = resumeState.profile;

    if (resumeState.isLoading && audit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("ATS Resume Audit")),
        body: const LoadingIndicator(message: "Loading ATS analysis..."),
      );
    }

    if (audit == null || audit.overallScore == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text("ATS Resume Audit")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_outlined, size: 56, color: NordicColors.textMuted),
                const SizedBox(height: 16),
                Text("No Resume Uploaded", style: NordicTypography.h2),
                const SizedBox(height: 6),
                Text(
                  "Upload your resume to receive a comprehensive ATS match audit and algorithmic optimization tips.",
                  style: NordicTypography.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                NordicButton(
                  label: "Upload Resume Now",
                  variant: NordicButtonVariant.primary,
                  onPressed: () => context.push(RouteNames.resumeUpload),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("ATS Audit Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Re-analyze",
            onPressed: () => ref.read(resumeControllerProvider.notifier).reAnalyze(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Master ATS Score Gauge Card
            NordicCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              leftAccentColor: NordicColors.getScoreColor(audit.overallScore),
              child: Column(
                children: [
                  AtsScoreMeter(
                    score: audit.overallScore,
                    size: 150,
                  ),
                  const SizedBox(height: 14),
                  if (profile?.resumeFileName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F4FA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attach_file_rounded, size: 14, color: NordicColors.navy),
                          const SizedBox(width: 4),
                          Text(
                            profile!.resumeFileName!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: NordicColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Dimensional Breakdown
            Text("Dimensional Breakdown", style: NordicTypography.h3),
            const SizedBox(height: 10),
            NordicCard(
              child: Column(
                children: [
                  DimensionalScoreBar(
                    label: "Domain Keywords & Coverage",
                    score: audit.keywordScore,
                    weightDescription: "35% of overall score • Industry-specific terminology",
                    icon: Icons.key_rounded,
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 14),
                  DimensionalScoreBar(
                    label: "Structural & Format Compliance",
                    score: audit.formatScore,
                    weightDescription: "25% of overall score • Parser readability & standard headers",
                    icon: Icons.view_headline_rounded,
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 14),
                  DimensionalScoreBar(
                    label: "Action Verbs & Seniority Impact",
                    score: audit.impactScore,
                    weightDescription: "25% of overall score • Dynamic verbs & leadership syntax",
                    icon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 14),
                  DimensionalScoreBar(
                    label: "Quantification & Measurable Metrics",
                    score: audit.quantificationScore,
                    weightDescription: "15% of overall score • Data-backed results ($/%, counts)",
                    icon: Icons.query_stats_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Actionable Recommendations
            if (audit.recommendations.isNotEmpty) ...[
              Text("Prioritized Recommendations", style: NordicTypography.h3),
              const SizedBox(height: 10),
              ...audit.recommendations.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RecommendationCard(
                    text: entry.value,
                    index: entry.key,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Skills & Keywords Cloud
            if (profile != null && profile.skills.isNotEmpty) ...[
              NordicCard(
                child: SkillsWrap(
                  skills: profile.skills,
                  title: "Extracted Candidate Skills",
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (audit.missingKeywords.isNotEmpty) ...[
              NordicCard(
                child: SkillsWrap(
                  skills: audit.missingKeywords,
                  title: "Missing High-Value Keywords",
                  isMissing: true,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Bottom Action Bar
            Row(
              children: [
                Expanded(
                  child: NordicButton(
                    label: "Upload New Version",
                    variant: NordicButtonVariant.outline,
                    icon: const Icon(Icons.upload_rounded, size: 18),
                    onPressed: () => context.push(RouteNames.resumeUpload),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NordicButton(
                    label: "Optimize with AI",
                    variant: NordicButtonVariant.primary,
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    onPressed: () => context.go(RouteNames.generator),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
