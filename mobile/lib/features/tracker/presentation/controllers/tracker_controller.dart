import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/application_model.dart';
import '../../data/tracker_repository.dart';

class TrackerState {
  final bool isLoading;
  final List<ApplicationModel> applications;
  final int selectedStageIndex;
  final String searchQuery;
  final String? errorMessage;

  const TrackerState({
    this.isLoading = false,
    this.applications = const [],
    this.selectedStageIndex = 0,
    this.searchQuery = "",
    this.errorMessage,
  });

  static const List<String> stages = [
    "wishlist",
    "applied",
    "screening",
    "interview",
    "offer",
    "archived",
  ];

  static const List<String> stageLabels = [
    "Wishlist",
    "Applied",
    "Screening",
    "Interview",
    "Offer",
    "Archived",
  ];

  String get currentStageKey => stages[selectedStageIndex];

  List<ApplicationModel> get filteredApplications {
    return applications.where((app) {
      final matchesStage = app.normalizedStage == currentStageKey;
      if (!matchesStage) return false;

      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      final title = app.job.title.toLowerCase();
      final company = (app.job.company ?? "").toLowerCase();
      return title.contains(q) || company.contains(q);
    }).toList();
  }

  int countForStage(String stageKey) {
    return applications.where((app) => app.normalizedStage == stageKey).length;
  }

  // Funnel Metrics
  int get totalActive => applications.where((app) => app.normalizedStage != "archived").length;
  int get appliedCount => applications.where((app) => app.normalizedStage == "applied").length;
  int get interviewCount => applications.where((app) => app.normalizedStage == "interview").length;
  int get offerCount => applications.where((app) => app.normalizedStage == "offer").length;

  int get interviewRate {
    final totalSubmitted = applications.where((a) => a.normalizedStage != "wishlist").length;
    if (totalSubmitted == 0) return 0;
    final interviewedOrBetter = applications.where((a) =>
        a.normalizedStage == "interview" || a.normalizedStage == "offer").length;
    return ((interviewedOrBetter / totalSubmitted) * 100).toInt();
  }

  TrackerState copyWith({
    bool? isLoading,
    List<ApplicationModel>? applications,
    int? selectedStageIndex,
    String? searchQuery,
    String? errorMessage,
  }) {
    return TrackerState(
      isLoading: isLoading ?? this.isLoading,
      applications: applications ?? this.applications,
      selectedStageIndex: selectedStageIndex ?? this.selectedStageIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage,
    );
  }
}

final trackerControllerProvider =
    StateNotifierProvider<TrackerController, TrackerState>((ref) {
  final repository = ref.watch(trackerRepositoryProvider);
  return TrackerController(repository: repository)..loadApplications();
});

class TrackerController extends StateNotifier<TrackerState> {
  final TrackerRepository _repository;

  TrackerController({required TrackerRepository repository})
      : _repository = repository,
        super(const TrackerState());

  Future<void> loadApplications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _repository.getApplications();
    if (res.success && res.data != null) {
      state = state.copyWith(
        isLoading: false,
        applications: res.data!,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.error,
      );
    }
  }

  void setStageIndex(int index) {
    if (index >= 0 && index < TrackerState.stages.length) {
      state = state.copyWith(selectedStageIndex: index);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<bool> updateStage(String applicationId, String newStatus) async {
    // 1. Optimistic local update
    final previousList = state.applications;
    final updatedList = state.applications.map((app) {
      if (app.id == applicationId) {
        return app.copyWith(status: newStatus);
      }
      return app;
    }).toList();

    state = state.copyWith(applications: updatedList);

    // 2. Server sync
    final res = await _repository.updateApplication(applicationId, status: newStatus);
    if (!res.success) {
      // Revert on failure
      state = state.copyWith(
        applications: previousList,
        errorMessage: res.error,
      );
      return false;
    }

    return true;
  }

  Future<bool> scheduleInterview(String applicationId, DateTime interviewDate) async {
    final previousList = state.applications;
    final updatedList = state.applications.map((app) {
      if (app.id == applicationId) {
        return app.copyWith(interviewDate: interviewDate);
      }
      return app;
    }).toList();

    state = state.copyWith(applications: updatedList);

    final res = await _repository.updateApplication(
      applicationId,
      interviewDate: interviewDate,
    );

    if (!res.success) {
      state = state.copyWith(
        applications: previousList,
        errorMessage: res.error,
      );
      return false;
    }

    return true;
  }

  Future<bool> updateDetails({
    required String applicationId,
    String? notes,
    String? contactPerson,
    DateTime? interviewDate,
  }) async {
    final res = await _repository.updateApplication(
      applicationId,
      notes: notes,
      contactPerson: contactPerson,
      interviewDate: interviewDate,
    );

    if (res.success && res.data != null) {
      final updatedList = state.applications.map((app) {
        return app.id == applicationId ? res.data! : app;
      }).toList();
      state = state.copyWith(applications: updatedList);
      return true;
    }

    return false;
  }

  Future<bool> addOpportunity({
    required String title,
    required String company,
    String? location,
    String? salary,
    String? sourceUrl,
    String status = "applied",
  }) async {
    state = state.copyWith(isLoading: true);

    final res = await _repository.createOpportunity(
      title: title,
      company: company,
      location: location,
      salary: salary,
      sourceUrl: sourceUrl,
      status: status,
    );

    if (res.success && res.data != null) {
      state = state.copyWith(
        isLoading: false,
        applications: [res.data!, ...state.applications],
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.error,
      );
      return false;
    }
  }

  Future<bool> deleteOpportunity(String applicationId) async {
    final previousList = state.applications;
    state = state.copyWith(
      applications: state.applications.where((a) => a.id != applicationId).toList(),
    );

    final res = await _repository.deleteApplication(applicationId);
    if (!res.success) {
      state = state.copyWith(
        applications: previousList,
        errorMessage: res.error,
      );
      return false;
    }

    return true;
  }
}
