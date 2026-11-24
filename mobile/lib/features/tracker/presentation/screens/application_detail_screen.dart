import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/ats_score_meter.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../../shared/widgets/nordic_text_field.dart';
import '../../../../shared/widgets/status_pill.dart';
import '../../data/models/application_model.dart';
import '../controllers/tracker_controller.dart';
import '../widgets/interview_date_dialog.dart';
import '../widgets/stage_picker_bottom_sheet.dart';

class ApplicationDetailScreen extends ConsumerStatefulWidget {
  final ApplicationModel application;

  const ApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  ConsumerState<ApplicationDetailScreen> createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends ConsumerState<ApplicationDetailScreen> {
  late ApplicationModel _app;
  final _notesController = TextEditingController();
  final _contactController = TextEditingController();
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _app = widget.application;
    _notesController.text = _app.notes ?? "";
    _contactController.text = _app.contactPerson ?? "";
  }

  @override
  void dispose() {
    _notesController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _openStagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StagePickerBottomSheet(
        currentStatus: _app.status,
        onSelectStage: (newStatus) async {
          setState(() {
            _app = _app.copyWith(status: newStatus);
          });
          await ref.read(trackerControllerProvider.notifier).updateStage(_app.id, newStatus);
        },
      ),
    );
  }

  Future<void> _pickInterviewDate() async {
    final picked = await InterviewDateDialog.pick(
      context,
      initialDate: _app.interviewDate,
    );

    if (picked != null) {
      setState(() {
        _app = _app.copyWith(interviewDate: picked);
      });
      await ref.read(trackerControllerProvider.notifier).scheduleInterview(_app.id, picked);
    }
  }

  Future<void> _saveNotes() async {
    setState(() => _isSavingNotes = true);
    await ref.read(trackerControllerProvider.notifier).updateDetails(
          applicationId: _app.id,
          notes: _notesController.text.trim(),
          contactPerson: _contactController.text.trim(),
        );
    if (mounted) {
      setState(() => _isSavingNotes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Application details saved."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Application"),
        content: Text("Are you sure you want to remove '${_app.job.title}' from your pipeline?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: NordicColors.scoreLow,
              foregroundColor: NordicColors.textInverse,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(trackerControllerProvider.notifier).deleteOpportunity(_app.id);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = _app.job;

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: Text(job.company ?? "Application Detail"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: "Delete",
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Overview Card
            NordicCard(
              leftAccentColor: NordicColors.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job.title, style: NordicTypography.h2),
                            const SizedBox(height: 4),
                            Text(
                              job.company ?? "Unknown Company",
                              style: const TextStyle(fontSize: 14, color: NordicColors.textMuted, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      if (_app.atsScore != null && _app.atsScore! > 0)
                        ScoreBadge(score: _app.atsScore!),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Stage selector button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hiring Stage:",
                        style: NordicTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                      ),
                      GestureDetector(
                        onTap: _openStagePicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusPill(status: _app.status),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down_rounded, color: NordicColors.navy),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interview Scheduler Section
            NordicCard(
              leftAccentColor: _app.interviewDate != null ? NordicColors.yellow : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.event_note_rounded, size: 18, color: NordicColors.navy),
                          const SizedBox(width: 8),
                          Text("Interview Round", style: NordicTypography.h3),
                        ],
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          side: const BorderSide(color: NordicColors.navy),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: _pickInterviewDate,
                        child: Text(
                          _app.interviewDate == null ? "Schedule Date" : "Change Date",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: NordicColors.navy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_app.interviewDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _app.isInterviewSoon ? NordicColors.yellowLight : const Color(0xFFF0F4FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.alarm_on_rounded,
                            size: 16,
                            color: _app.isInterviewSoon ? NordicColors.navyDark : NordicColors.navy,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat("EEEE, MMMM d, y 'at' h:mm a").format(_app.interviewDate!),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _app.isInterviewSoon ? NordicColors.navyDark : NordicColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      "No upcoming interview set for this application.",
                      style: NordicTypography.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Recruiter Contact & Prep Notes
            NordicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recruiter & Notes", style: NordicTypography.h3),
                  const SizedBox(height: 12),
                  NordicTextField(
                    label: "Recruiter / Hiring Contact",
                    hint: "e.g. Sarah Jenkins (sarah.j@company.com)",
                    controller: _contactController,
                    prefixIcon: const Icon(Icons.person_pin_outlined, size: 18, color: NordicColors.navy),
                  ),
                  const SizedBox(height: 14),
                  NordicTextField(
                    label: "Interview Prep & Notes",
                    hint: "Questions to ask, salary discussion notes, referral names...",
                    controller: _notesController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NordicButton(
                      label: "Save Notes",
                      variant: NordicButtonVariant.navy,
                      isLoading: _isSavingNotes,
                      onPressed: _saveNotes,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Linked AI Actions
            Text("AI Acceleration Actions", style: NordicTypography.h3),
            const SizedBox(height: 10),
            NordicCard(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: NordicColors.yellowLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.mail_outline_rounded, color: NordicColors.navyDark, size: 20),
                    ),
                    title: const Text("Generate Cover Letter"),
                    subtitle: const Text("Tailored for this company and role", style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go(RouteNames.generator),
                  ),
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E7FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.send_outlined, color: NordicColors.navy, size: 20),
                    ),
                    title: const Text("Draft Follow-up Email"),
                    subtitle: const Text("After interview or application submission", style: TextStyle(fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go(RouteNames.generator),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
