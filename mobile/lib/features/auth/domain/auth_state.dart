import '../data/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        token = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        token = null,
        errorMessage = null;

  const AuthState.authenticated({
    required UserModel user,
    required String token,
  })  : status = AuthStatus.authenticated,
        user = user,
        token = token,
        errorMessage = null;

  const AuthState.unauthenticated([String? message])
      : status = AuthStatus.unauthenticated,
        user = null,
        token = null,
        errorMessage = message;

  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        token = null,
        errorMessage = message;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}
