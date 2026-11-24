import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient: apiClient);
});

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<({String token, UserModel user})>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.mobileLogin,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      return ApiResponse.success((token: token, user: user));
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to sign in. Please verify your credentials.';
      return ApiResponse.error(errorMsg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<({String token, UserModel user})>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.mobileRegister,
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name.trim(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      return ApiResponse.success((token: token, user: user), 201);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to create account.';
      return ApiResponse.error(errorMsg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> forgotPassword({required String email}) async {
    try {
      final response = await _apiClient.post(
        '/api/auth/forgot-password',
        data: {'email': email.trim().toLowerCase()},
      );
      final msg = response.data?['message'] as String? ??
          'If an account exists with this email, a reset link has been dispatched.';
      return ApiResponse.success(msg);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to dispatch reset email.';
      return ApiResponse.error(errorMsg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
