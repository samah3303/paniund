import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../share_intent/presentation/controllers/share_intent_controller.dart';
import '../../../share_intent/presentation/widgets/job_clip_preview_sheet.dart';
import '../../../share_intent/services/share_intent_service.dart';
import '../controllers/tracker_controller.dart';
import '../widgets/add_application_modal.dart';
import '../widgets/application_card.dart';
import '../widgets/stage_picker_bottom_sheet.dart';
import '../widgets/stage_segmented_bar.dart';
import 'application_detail_screen.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key});

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddApplicationModal(
        onAdd: ref.read(trackerControllerProvider.notifier).addOpportunity,
      ),
    );
  }

  void _openClipUrlDialog() {
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Clip Job from URL"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Paste a job listing link from LinkedIn, Indeed, or any career site:",
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                hintText: "https://linkedin.com/jobs/view/...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NordicColors.yellow,
              foregroundColor: NordicColors.textDark,
            ),
            onPressed: () {
              final raw = urlController.text.trim();
              final extracted = ShareIntentService.extractUrl(raw);
              Navigator.pop(ctx);
              if (extracted != null) {
                ref.read(shareIntentControllerProvider.notifier).handleIncomingUrl(extracted);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const JobClipPreviewSheet(),
                );
              }
            },
            child: const Text("Clip & Analyze"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackerControllerProvider);
    final counts = TrackerState.stages.map((s) => state.countForStage(s)).toList();
    final filtered = state.filteredApplications;

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("Application Pipeline"),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: "Clip Job from URL",
            onPressed: _openClipUrlDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Pipeline",
            onPressed: () => ref.read(trackerControllerProvider.notifier).loadApplications(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: NordicColors.yellow,
        foregroundColor: NordicColors.textDark,
        elevation: 3,
        onPressed: _openAddModal,
        tooltip: "Track New Application",
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: Column(
        children: [
          // 1. Funnel Analytics Bar
          Container(
            color: NordicColors.surfaceWhite,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: "Active Pipeline",
                    value: "${state.totalActive}",
                    color: NordicColors.navy,
                  ),
                ),
                Container(width: 1, height: 30, color: NordicColors.borderLight),
                Expanded(
                  child: _MetricItem(
                    label: "Interview Rate",
                    value: "${state.interviewRate}%",
                    color: NordicColors.scoreMed,
                  ),
                ),
                Container(width: 1, height: 30, color: NordicColors.borderLight),
                Expanded(
                  child: _MetricItem(
                    label: "Active Offers",
                    value: "${state.offerCount}",
                    color: NordicColors.scoreHigh,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 2. 6-Stage Segmented Bar
          StageSegmentedBar(
            selectedIndex: state.selectedStageIndex,
            stageLabels: TrackerState.stageLabels,
            counts: counts,
            onStageSelected: (index) {
              ref.read(trackerControllerProvider.notifier).setStageIndex(index);
            },
          ),
          const SizedBox(height: 10),

          // 3. Search Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                onChanged: ref.read(trackerControllerProvider.notifier).setSearchQuery,
                decoration: InputDecoration(
                  hintText: "Search company or title...",
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: NordicColors.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(trackerControllerProvider.notifier).setSearchQuery("");
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: NordicColors.surfaceWhite,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: NordicColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: NordicColors.borderLight),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // 4. Application Cards List
          Expanded(
            child: state.isLoading && state.applications.isEmpty
                ? const LoadingIndicator(message: "Loading application pipeline...")
                : RefreshIndicator(
                    color: NordicColors.navy,
                    onRefresh: () => ref.read(trackerControllerProvider.notifier).loadApplications(),
                    child: filtered.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.inbox_outlined, size: 48, color: NordicColors.textMuted),
                                      const SizedBox(height: 12),
                                      Text(
                                        "No applications in ${TrackerState.stageLabels[state.selectedStageIndex]}",
                                        style: NordicTypography.h3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Tap the + button below to log a new opportunity.",
                                        style: NordicTypography.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final app = filtered[index];
                              return ApplicationCard(
                                application: app,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ApplicationDetailScreen(application: app),
                                    ),
                                  );
                                },
                                onQuickStageChange: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => StagePickerBottomSheet(
                                      currentStatus: app.status,
                                      onSelectStage: (newStatus) {
                                        ref
                                            .read(trackerControllerProvider.notifier)
                                            .updateStage(app.id, newStatus);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: NordicTypography.scoreMetric.copyWith(
            fontSize: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: NordicTypography.bodySmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
