import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tracker/presentation/controllers/tracker_controller.dart';
import '../../data/job_clipper_repository.dart';
import '../../data/models/clipped_job_model.dart';

class ShareIntentState {
  final bool isAnalyzing;
  final bool isSaving;
  final ClippedJobModel? clippedJob;
  final String? errorMessage;
  final String? sharedUrl;

  const ShareIntentState({
    this.isAnalyzing = false,
    this.isSaving = false,
    this.clippedJob,
    this.errorMessage,
    this.sharedUrl,
  });

  ShareIntentState copyWith({
    bool? isAnalyzing,
    bool? isSaving,
    ClippedJobModel? clippedJob,
    String? errorMessage,
    String? sharedUrl,
  }) {
    return ShareIntentState(
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isSaving: isSaving ?? this.isSaving,
      clippedJob: clippedJob ?? this.clippedJob,
      errorMessage: errorMessage,
      sharedUrl: sharedUrl ?? this.sharedUrl,
    );
  }
}

final shareIntentControllerProvider =
    StateNotifierProvider<ShareIntentController, ShareIntentState>((ref) {
  final repository = ref.watch(jobClipperRepositoryProvider);
  final trackerNotifier = ref.read(trackerControllerProvider.notifier);

  return ShareIntentController(
    repository: repository,
    onJobClipped: () => trackerNotifier.loadApplications(),
  );
});

class ShareIntentController extends StateNotifier<ShareIntentState> {
  final JobClipperRepository _repository;
  final void Function()? _onJobClipped;

  ShareIntentController({
    required JobClipperRepository repository,
    void Function()? onJobClipped,
  })  : _repository = repository,
        _onJobClipped = onJobClipped,
        super(const ShareIntentState());

  Future<bool> handleIncomingUrl(String url) async {
    state = state.copyWith(
      isAnalyzing: true,
      sharedUrl: url,
      errorMessage: null,
      clippedJob: null,
    );

    // 1. Scrape listing URL
    final parseRes = await _repository.parseJobUrl(url);
    if (!parseRes.success || parseRes.data == null) {
      state = state.copyWith(
        isAnalyzing: false,
        errorMessage: parseRes.error ?? "Could not parse job listing details.",
      );
      return false;
    }

    final parsed = parseRes.data!;

    // 2. Compute ATS match score & extract skills by clipping to wishlist
    final clipRes = await _repository.clipJob(
      url: url,
      title: parsed.title,
      company: parsed.company,
      location: parsed.location,
      salary: parsed.salary,
      description: parsed.description,
      requirements: parsed.requirements,
      status: "wishlist",
    );

    if (clipRes.success && clipRes.data != null) {
      state = state.copyWith(
        isAnalyzing: false,
        clippedJob: clipRes.data,
      );
      _onJobClipped?.call();
      return true;
    } else {
      // If clip failed, still show parsed info with fallback score
      state = state.copyWith(
        isAnalyzing: false,
        clippedJob: parsed,
      );
      return true;
    }
  }

  Future<bool> saveWithStatus(String status) async {
    if (state.clippedJob == null || state.sharedUrl == null) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final job = state.clippedJob!;
    final res = await _repository.clipJob(
      url: state.sharedUrl!,
      title: job.title,
      company: job.company,
      location: job.location,
      salary: job.salary,
      description: job.description,
      requirements: job.requirements,
      status: status,
    );

    if (res.success && res.data != null) {
      state = state.copyWith(
        isSaving: false,
        clippedJob: res.data,
      );
      _onJobClipped?.call();
      return true;
    } else {
      state = state.copyWith(
        isSaving: false,
        errorMessage: res.error ?? "Failed to save job to pipeline.",
      );
      return false;
    }
  }

  void reset() {
    state = const ShareIntentState();
  }
}
