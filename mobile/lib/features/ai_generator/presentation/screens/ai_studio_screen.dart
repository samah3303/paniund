import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../../../../shared/widgets/nordic_text_field.dart';
import '../../../tracker/presentation/controllers/tracker_controller.dart';
import '../../data/models/generation_request_model.dart';
import '../controllers/ai_generator_controller.dart';
import '../widgets/generated_result_card.dart';
import '../widgets/generation_type_selector.dart';

class AiStudioScreen extends ConsumerStatefulWidget {
  const AiStudioScreen({super.key});

  @override
  ConsumerState<AiStudioScreen> createState() => _AiStudioScreenState();
}

class _AiStudioScreenState extends ConsumerState<AiStudioScreen> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descController = TextEditingController();

  String _linkedinType = "connection_request";
  String _followupContext = "post_interview";

  @override
  void initState() {
    super.initState();
    final state = ref.read(aiGeneratorControllerProvider);
    _titleController.text = state.targetJobTitle;
    _companyController.text = state.targetCompany;
    _descController.text = state.targetDescription;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onGenerate() {
    final title = _titleController.text.trim();
    final company = _companyController.text.trim();

    if (title.isEmpty || company.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a Target Job Title and Company."),
          backgroundColor: NordicColors.scoreLow,
        ),
      );
      return;
    }

    ref.read(aiGeneratorControllerProvider.notifier).generate(
          title: title,
          company: company,
          description: _descController.text.trim(),
          linkedinType: _linkedinType,
          followupContext: _followupContext,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiGeneratorControllerProvider);
    final trackerState = ref.watch(trackerControllerProvider);
    final applications = trackerState.applications;

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("AI Application Suite"),
        actions: [
          if (state.generatedContent != null)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              tooltip: "New Generation",
              onPressed: () {
                ref.read(aiGeneratorControllerProvider.notifier).clearContent();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Mode Selector
            GenerationTypeSelector(
              selectedType: state.selectedType,
              onSelect: (type) {
                ref.read(aiGeneratorControllerProvider.notifier).setType(type);
              },
            ),
            const SizedBox(height: 16),

            // If generated, show Output Card
            if (state.generatedContent != null) ...[
              GeneratedResultCard(
                title: "${_titleController.text} at ${_companyController.text}",
                content: state.generatedContent!,
                onRegenerate: _onGenerate,
              ),
              const SizedBox(height: 24),
            ],

            // Input Form Card
            NordicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Target Opportunity", style: NordicTypography.h3),
                  const SizedBox(height: 10),

                  // Pre-fill from active pipeline if available
                  if (applications.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Auto-fill from Pipeline",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      hint: const Text("Select a tracked job..."),
                      items: applications.map((app) {
                        return DropdownMenuItem(
                          value: app.id,
                          child: Text(
                            "${app.job.title} • ${app.job.company ?? 'Unknown'}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                      onChanged: (appId) {
                        if (appId == null) return;
                        final app = applications.firstWhere((a) => a.id == appId);
                        setState(() {
                          _titleController.text = app.job.title;
                          _companyController.text = app.job.company ?? "";
                          _descController.text = app.job.description ?? "";
                        });
                        ref.read(aiGeneratorControllerProvider.notifier).prefillJob(
                              jobId: app.job.id,
                              title: app.job.title,
                              company: app.job.company ?? "",
                              description: app.job.description,
                            );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  NordicTextField(
                    label: "Job Title *",
                    hint: "e.g. Lead Mobile Architect",
                    controller: _titleController,
                  ),
                  const SizedBox(height: 12),

                  NordicTextField(
                    label: "Company *",
                    hint: "e.g. Spotify",
                    controller: _companyController,
                  ),
                  const SizedBox(height: 12),

                  NordicTextField(
                    label: "Job Description / Requirements",
                    hint: "Paste key responsibilities or qualifications to tailor narrative...",
                    controller: _descController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  // Mode-specific options
                  if (state.selectedType == GenerationType.linkedinOutreach) ...[
                    Text("Outreach Message Format", style: NordicTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _linkedinType,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "connection_request", child: Text("Connection Note (< 300 chars)")),
                        DropdownMenuItem(value: "inmail", child: Text("InMail Pitch Message")),
                        DropdownMenuItem(value: "referral_request", child: Text("Referral Request Note")),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _linkedinType = v);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (state.selectedType == GenerationType.followupEmail) ...[
                    Text("Follow-Up Context", style: NordicTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _followupContext,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "post_interview", child: Text("Thank-You After Interview")),
                        DropdownMenuItem(value: "post_application", child: Text("Status Check After 1 Week")),
                        DropdownMenuItem(value: "status_inquiry", child: Text("Checking In on Offer Timeline")),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _followupContext = v);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Tone Selector
                  Text("Writing Tone", style: NordicTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: GenerationTone.values.map((tone) {
                      final isSelected = state.selectedTone == tone;
                      return ChoiceChip(
                        label: Text(
                          tone.name[0].toUpperCase() + tone.name.substring(1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? NordicColors.navyDark : NordicColors.textDark,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: NordicColors.yellow,
                        backgroundColor: NordicColors.canvasLight,
                        onSelected: (_) {
                          ref.read(aiGeneratorControllerProvider.notifier).setTone(tone);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  if (state.isGenerating) ...[
                    const LoadingIndicator(
                      message: "Synthesizing candidate profile with job requirements...",
                    ),
                    const SizedBox(height: 16),
                  ],

                  NordicButton(
                    label: state.isGenerating
                        ? "Generating..."
                        : switch (state.selectedType) {
                            GenerationType.coverLetter => "Draft Tailored Cover Letter",
                            GenerationType.bulletUpgrade => "Optimize Experience Bullets",
                            GenerationType.linkedinOutreach => "Generate LinkedIn Outreach",
                            GenerationType.followupEmail => "Draft Follow-Up Email",
                          },
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    variant: NordicButtonVariant.primary,
                    isLoading: state.isGenerating,
                    onPressed: state.isGenerating ? null : _onGenerate,
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
