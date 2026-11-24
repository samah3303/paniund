import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ai_generator_repository.dart';
import '../../data/models/generation_request_model.dart';

class AiGeneratorState {
  final bool isGenerating;
  final GenerationType selectedType;
  final GenerationTone selectedTone;
  final String? generatedContent;
  final String? errorMessage;
  final String? targetJobId;
  final String targetJobTitle;
  final String targetCompany;
  final String targetDescription;

  const AiGeneratorState({
    this.isGenerating = false,
    this.selectedType = GenerationType.coverLetter,
    this.selectedTone = GenerationTone.professional,
    this.generatedContent,
    this.errorMessage,
    this.targetJobId,
    this.targetJobTitle = "",
    this.targetCompany = "",
    this.targetDescription = "",
  });

  AiGeneratorState copyWith({
    bool? isGenerating,
    GenerationType? selectedType,
    GenerationTone? selectedTone,
    String? generatedContent,
    String? errorMessage,
    String? targetJobId,
    String? targetJobTitle,
    String? targetCompany,
    String? targetDescription,
  }) {
    return AiGeneratorState(
      isGenerating: isGenerating ?? this.isGenerating,
      selectedType: selectedType ?? this.selectedType,
      selectedTone: selectedTone ?? this.selectedTone,
      generatedContent: generatedContent ?? this.generatedContent,
      errorMessage: errorMessage,
      targetJobId: targetJobId ?? this.targetJobId,
      targetJobTitle: targetJobTitle ?? this.targetJobTitle,
      targetCompany: targetCompany ?? this.targetCompany,
      targetDescription: targetDescription ?? this.targetDescription,
    );
  }
}

final aiGeneratorControllerProvider =
    StateNotifierProvider<AiGeneratorController, AiGeneratorState>((ref) {
  final repository = ref.watch(aiGeneratorRepositoryProvider);
  return AiGeneratorController(repository: repository);
});

class AiGeneratorController extends StateNotifier<AiGeneratorState> {
  final AiGeneratorRepository _repository;

  AiGeneratorController({required AiGeneratorRepository repository})
      : _repository = repository,
        super(const AiGeneratorState());

  void setType(GenerationType type) {
    state = state.copyWith(selectedType: type, errorMessage: null);
  }

  void setTone(GenerationTone tone) {
    state = state.copyWith(selectedTone: tone);
  }

  void prefillJob({
    required String jobId,
    required String title,
    required String company,
    String? description,
  }) {
    state = state.copyWith(
      targetJobId: jobId,
      targetJobTitle: title,
      targetCompany: company,
      targetDescription: description ?? "",
    );
  }

  Future<bool> generate({
    required String title,
    required String company,
    String? description,
    String? linkedinType,
    String? followupContext,
  }) async {
    state = state.copyWith(
      isGenerating: true,
      errorMessage: null,
      targetJobTitle: title,
      targetCompany: company,
      targetDescription: description ?? "",
    );

    final req = GenerationRequestModel(
      type: state.selectedType,
      jobId: state.targetJobId,
      jobTitle: title,
      company: company,
      jobDescription: description,
      tone: state.selectedTone,
      linkedinMessageType: linkedinType ?? "connection_request",
      followupContext: followupContext ?? "post_interview",
    );

    final res = switch (state.selectedType) {
      GenerationType.coverLetter => await _repository.generateCoverLetter(req),
      GenerationType.bulletUpgrade => await _repository.generateBulletUpgrades(req),
      GenerationType.linkedinOutreach => await _repository.generateLinkedInOutreach(req),
      GenerationType.followupEmail => await _repository.generateFollowupEmail(req),
    };

    if (res.success && res.data != null) {
      state = state.copyWith(
        isGenerating: false,
        generatedContent: res.data!,
      );
      return true;
    } else {
      state = state.copyWith(
        isGenerating: false,
        errorMessage: res.error ?? "Failed to generate AI content.",
      );
      return false;
    }
  }

  void clearContent() {
    state = state.copyWith(generatedContent: null, errorMessage: null);
  }
}
