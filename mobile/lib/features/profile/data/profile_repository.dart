import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../../resume/data/models/profile_model.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      final profile = ProfileModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(profile);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to load profile';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ProfileModel>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put(
        ApiEndpoints.profile,
        data: data,
      );
      final profile = ProfileModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(profile);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to update profile';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> getApiToken() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.apiToken);
      final data = response.data as Map<String, dynamic>;
      final token = data['apiToken'] as String? ?? "";
      return ApiResponse.success(token);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to fetch API token';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> regenerateApiToken() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.apiToken);
      final data = response.data as Map<String, dynamic>;
      final token = data['apiToken'] as String? ?? "";
      return ApiResponse.success(token);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to regenerate API token';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
