import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../domain/auth_state.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageServiceProvider);
  final apiClient = ref.watch(apiClientProvider);

  return AuthController(
    repository: repository,
    storage: storage,
    apiClient: apiClient,
  )..initialize();
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _storage;
  final ApiClient _apiClient;

  AuthController({
    required AuthRepository repository,
    required SecureStorageService storage,
    required ApiClient apiClient,
  })  : _repository = repository,
        _storage = storage,
        _apiClient = apiClient,
        super(const AuthState.initial());

  Future<void> initialize() async {
    state = const AuthState.loading();
    try {
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) {
        state = const AuthState.unauthenticated();
        return;
      }

      final userData = await _storage.getUserData();
      final id = userData['id'];
      final email = userData['email'];

      if (id != null && email != null) {
        // Validate session with server
        try {
          final res = await _apiClient.get('/api/profile');
          if (res.statusCode == 200) {
            final user = UserModel(
              id: id,
              email: email,
              name: userData['name'],
              role: userData['role'] ?? 'user',
            );
            state = AuthState.authenticated(user: user, token: token);
            return;
          }
        } catch (_) {
          // If offline or network error, trust stored credentials temporarily
          final user = UserModel(
            id: id,
            email: email,
            name: userData['name'],
            role: userData['role'] ?? 'user',
          );
          state = AuthState.authenticated(user: user, token: token);
          return;
        }
      }

      await _storage.clearAll();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final result = await _repository.login(email: email, password: password);

    if (result.success && result.data != null) {
      final token = result.data!.token;
      final user = result.data!.user;

      await _storage.saveToken(token);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      );

      state = AuthState.authenticated(user: user, token: token);
      return true;
    } else {
      state = AuthState.error(result.error ?? 'Invalid email or password');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AuthState.loading();
    final result = await _repository.register(
      email: email,
      password: password,
      name: name,
    );

    if (result.success && result.data != null) {
      final token = result.data!.token;
      final user = result.data!.user;

      await _storage.saveToken(token);
      await _storage.saveUserData(
        id: user.id,
        email: user.email,
        name: user.name,
        role: user.role,
      );

      state = AuthState.authenticated(user: user, token: token);
      return true;
    } else {
      state = AuthState.error(result.error ?? 'Registration failed');
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }
}
