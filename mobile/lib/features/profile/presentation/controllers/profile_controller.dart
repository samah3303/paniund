import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../resume/data/models/profile_model.dart';
import '../data/profile_repository.dart';

class ProfileState {
  final bool isLoading;
  final bool isUpdating;
  final bool isRegeneratingToken;
  final ProfileModel? profile;
  final String? apiToken;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.isRegeneratingToken = false,
    this.profile,
    this.apiToken,
    this.errorMessage,
  });

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isRegeneratingToken,
    ProfileModel? profile,
    String? apiToken,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isRegeneratingToken: isRegeneratingToken ?? this.isRegeneratingToken,
      profile: profile ?? this.profile,
      apiToken: apiToken ?? this.apiToken,
      errorMessage: errorMessage,
    );
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository: repository)..load();
});

class ProfileController extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileController({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final results = await Future.wait([
      _repository.getProfile(),
      _repository.getApiToken(),
    ]);

    final profileRes = results[0];
    final tokenRes = results[1];

    state = state.copyWith(
      isLoading: false,
      profile: profileRes.success ? profileRes.data as ProfileModel? : state.profile,
      apiToken: tokenRes.success ? tokenRes.data as String? : state.apiToken,
      errorMessage: !profileRes.success ? profileRes.error : null,
    );
  }

  Future<bool> updateRoles(List<String> targetRoles) async {
    state = state.copyWith(isUpdating: true);
    final res = await _repository.updateProfile({'targetRoles': targetRoles});

    if (res.success && res.data != null) {
      state = state.copyWith(
        isUpdating: false,
        profile: res.data,
      );
      return true;
    } else {
      state = state.copyWith(
        isUpdating: false,
        errorMessage: res.error ?? "Failed to update target roles",
      );
      return false;
    }
  }

  Future<bool> regenerateToken() async {
    state = state.copyWith(isRegeneratingToken: true);
    final res = await _repository.regenerateApiToken();

    if (res.success && res.data != null) {
      state = state.copyWith(
        isRegeneratingToken: false,
        apiToken: res.data,
      );
      return true;
    } else {
      state = state.copyWith(
        isRegeneratingToken: false,
        errorMessage: res.error ?? "Failed to regenerate token",
      );
      return false;
    }
  }
}
