import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/ats_audit_model.dart';
import 'models/profile_model.dart';

final resumeRepositoryProvider = Provider<ResumeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ResumeRepository(apiClient: apiClient);
});

class ResumeRepository {
  final ApiClient _apiClient;

  ResumeRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<ProfileModel>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      final profile = ProfileModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(profile);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to fetch candidate profile.';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<({ProfileModel profile, AtsAuditModel audit})>> uploadResume({
    required String filePath,
    required String fileName,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dio.post(
        ApiEndpoints.resumeUpload,
        data: formData,
        onSendProgress: onSendProgress,
      );

      final data = response.data as Map<String, dynamic>;
      final profileData = data['profile'] as Map<String, dynamic>? ?? {};
      final analysisData = data['analysis'] as Map<String, dynamic>? ?? {};

      final profile = ProfileModel.fromJson(profileData);
      final audit = AtsAuditModel.fromJson(analysisData);

      return ApiResponse.success((profile: profile, audit: audit));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to upload and parse resume.';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<AtsAuditModel>> analyzeCurrentResume() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.resumeAnalyze);
      final data = response.data as Map<String, dynamic>;
      final audit = AtsAuditModel.fromJson(data);
      return ApiResponse.success(audit);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to re-analyze resume.';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
