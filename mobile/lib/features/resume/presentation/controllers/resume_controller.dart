import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ats_audit_model.dart';
import '../../data/models/profile_model.dart';
import '../../data/resume_repository.dart';

class ResumeState {
  final bool isLoading;
  final bool isUploading;
  final double uploadProgress;
  final ProfileModel? profile;
  final AtsAuditModel? audit;
  final String? errorMessage;

  const ResumeState({
    this.isLoading = false,
    this.isUploading = false,
    this.uploadProgress = 0.0,
    this.profile,
    this.audit,
    this.errorMessage,
  });

  ResumeState copyWith({
    bool? isLoading,
    bool? isUploading,
    double? uploadProgress,
    ProfileModel? profile,
    AtsAuditModel? audit,
    String? errorMessage,
  }) {
    return ResumeState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      profile: profile ?? this.profile,
      audit: audit ?? this.audit,
      errorMessage: errorMessage,
    );
  }
}

final resumeControllerProvider =
    StateNotifierProvider<ResumeController, ResumeState>((ref) {
  final repository = ref.watch(resumeRepositoryProvider);
  return ResumeController(repository: repository)..loadProfile();
});

class ResumeController extends StateNotifier<ResumeState> {
  final ResumeRepository _repository;

  ResumeController({required ResumeRepository repository})
      : _repository = repository,
        super(const ResumeState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _repository.getProfile();
    if (res.success && res.data != null) {
      final profile = res.data!;
      final audit = AtsAuditModel.fromProfileData(
        atsScore: profile.atsScore,
        atsBreakdown: profile.atsBreakdown,
        recommendations: profile.recommendations,
      );

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        audit: audit,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.error,
      );
    }
  }

  Future<bool> uploadResume({
    required String filePath,
    required String fileName,
  }) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0.05,
      errorMessage: null,
    );

    final res = await _repository.uploadResume(
      filePath: filePath,
      fileName: fileName,
      onSendProgress: (sent, total) {
        if (total > 0) {
          final progress = sent / total;
          state = state.copyWith(uploadProgress: progress);
        }
      },
    );

    if (res.success && res.data != null) {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 1.0,
        profile: res.data!.profile,
        audit: res.data!.audit,
      );
      return true;
    } else {
      state = state.copyWith(
        isUploading: false,
        uploadProgress: 0.0,
        errorMessage: res.error ?? "Failed to upload resume",
      );
      return false;
    }
  }

  Future<void> reAnalyze() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final res = await _repository.analyzeCurrentResume();

    if (res.success && res.data != null) {
      state = state.copyWith(
        isLoading: false,
        audit: res.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.error,
      );
    }
  }
}
