import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/nordic_colors.dart';
import '../../../../core/theme/nordic_typography.dart';
import '../../../../shared/widgets/nordic_button.dart';
import '../../../../shared/widgets/nordic_card.dart';
import '../controllers/resume_controller.dart';

class ResumeUploadScreen extends ConsumerStatefulWidget {
  const ResumeUploadScreen({super.key});

  @override
  ConsumerState<ResumeUploadScreen> createState() => _ResumeUploadScreenState();
}

class _ResumeUploadScreenState extends ConsumerState<ResumeUploadScreen> {
  PlatformFile? _selectedFile;
  String? _localError;

  Future<void> _pickFile() async {
    setState(() {
      _localError = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'doc', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            _localError = "File must be under 10MB in size.";
          });
          return;
        }
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      setState(() {
        _localError = "Could not select file: $e";
      });
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedFile == null || _selectedFile!.path == null) {
      setState(() {
        _localError = "Please select a resume file first.";
      });
      return;
    }

    final success = await ref.read(resumeControllerProvider.notifier).uploadResume(
          filePath: _selectedFile!.path!,
          fileName: _selectedFile!.name,
        );

    if (success && mounted) {
      context.pushReplacement(RouteNames.resumeAudit);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  @override
  Widget build(BuildContext context) {
    final resumeState = ref.watch(resumeControllerProvider);

    return Scaffold(
      backgroundColor: NordicColors.canvasLight,
      appBar: AppBar(
        title: const Text("Upload Resume"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("ATS Resume Audit", style: NordicTypography.h1),
            const SizedBox(height: 6),
            Text(
              "Upload your existing resume (PDF, DOCX, TXT) to get an immediate algorithm compatibility score and keyword breakdown.",
              style: NordicTypography.bodySmall,
            ),
            const SizedBox(height: 24),

            if (_localError != null || resumeState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: NordicColors.scoreLowBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NordicColors.scoreLow.withOpacity(0.3)),
                ),
                child: Text(
                  _localError ?? resumeState.errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: NordicColors.scoreLow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Upload Box Area
            GestureDetector(
              onTap: resumeState.isUploading ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                decoration: BoxDecoration(
                  color: NordicColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedFile != null ? NordicColors.navy : NordicColors.borderLight,
                    width: _selectedFile != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedFile != null ? NordicColors.yellowLight : const Color(0xFFF0F4FA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectedFile != null ? Icons.description_rounded : Icons.cloud_upload_outlined,
                        size: 36,
                        color: _selectedFile != null ? NordicColors.navyDark : NordicColors.navy,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null ? _selectedFile!.name : "Select or Browse Resume",
                      style: NordicTypography.h3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _selectedFile != null
                          ? _formatFileSize(_selectedFile!.size)
                          : "Supports PDF, DOCX, DOC, or TXT (Max 10MB)",
                      style: NordicTypography.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: NordicColors.navy,
                        side: const BorderSide(color: NordicColors.navy),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: resumeState.isUploading ? null : _pickFile,
                      icon: const Icon(Icons.folder_open_rounded, size: 18),
                      label: Text(_selectedFile != null ? "Change File" : "Browse Files"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Upload Progress Bar
            if (resumeState.isUploading) ...[
              NordicCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Analyzing Document & Extracting Keywords...",
                          style: NordicTypography.h3.copyWith(fontSize: 13),
                        ),
                        Text(
                          "${(resumeState.uploadProgress * 100).toInt()}%",
                          style: const TextStyle(fontWeight: FontWeight.w700, color: NordicColors.navy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: resumeState.uploadProgress,
                        backgroundColor: NordicColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(NordicColors.yellow),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            NordicButton(
              label: "Audit & Score Resume",
              icon: const Icon(Icons.analytics_outlined, size: 18),
              variant: NordicButtonVariant.primary,
              fullWidth: true,
              isLoading: resumeState.isUploading,
              onPressed: _selectedFile != null && !resumeState.isUploading ? _handleUpload : null,
            ),
          ],
        ),
      ),
    );
  }
}
