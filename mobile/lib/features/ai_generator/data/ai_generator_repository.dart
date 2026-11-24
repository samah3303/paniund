import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/generation_request_model.dart';

final aiGeneratorRepositoryProvider = Provider<AiGeneratorRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiGeneratorRepository(apiClient: apiClient);
});

class AiGeneratorRepository {
  final ApiClient _apiClient;

  AiGeneratorRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<String> _ensureJobId({
    String? existingJobId,
    required String title,
    required String company,
    String? description,
  }) async {
    if (existingJobId != null && existingJobId.isNotEmpty) {
      return existingJobId;
    }

    final res = await _apiClient.post(
      ApiEndpoints.jobs,
      data: {
        'title': title.trim(),
        'company': company.trim(),
        if (description != null && description.isNotEmpty)
          'description': description.trim(),
        'source': 'ai_studio',
      },
    );

    final data = res.data as Map<String, dynamic>;
    return data['id'] as String;
  }

  Future<ApiResponse<String>> generateCoverLetter(GenerationRequestModel request) async {
    try {
      final effectiveJobId = await _ensureJobId(
        existingJobId: request.jobId,
        title: request.jobTitle,
        company: request.company,
        description: request.jobDescription,
      );

      final response = await _apiClient.post(
        ApiEndpoints.generateCoverLetter,
        data: {
          'jobId': effectiveJobId,
          'tone': request.toneString,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? data['coverLetter'] as String? ?? "";
      return ApiResponse.success(content);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to generate cover letter';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> generateBulletUpgrades(GenerationRequestModel request) async {
    try {
      final effectiveJobId = await _ensureJobId(
        existingJobId: request.jobId,
        title: request.jobTitle,
        company: request.company,
        description: request.jobDescription,
      );

      final response = await _apiClient.post(
        ApiEndpoints.generateResumeUpdates,
        data: {
          'jobId': effectiveJobId,
          'tone': request.toneString,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? data['resumeUpdates'] as String? ?? "";
      return ApiResponse.success(content);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to optimize resume bullets';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> generateLinkedInOutreach(GenerationRequestModel request) async {
    try {
      final effectiveJobId = await _ensureJobId(
        existingJobId: request.jobId,
        title: request.jobTitle,
        company: request.company,
        description: request.jobDescription,
      );

      final response = await _apiClient.post(
        ApiEndpoints.generateLinkedinMessage,
        data: {
          'jobId': effectiveJobId,
          'messageType': request.linkedinMessageType ?? "connection_request",
          'tone': request.toneString,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? data['message'] as String? ?? "";
      return ApiResponse.success(content);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to draft LinkedIn outreach';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<String>> generateFollowupEmail(GenerationRequestModel request) async {
    try {
      final effectiveJobId = await _ensureJobId(
        existingJobId: request.jobId,
        title: request.jobTitle,
        company: request.company,
        description: request.jobDescription,
      );

      final response = await _apiClient.post(
        ApiEndpoints.generateFollowupEmail,
        data: {
          'jobId': effectiveJobId,
          'context': request.followupContext ?? "post_interview",
          'tone': request.toneString,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final content = data['content'] as String? ?? data['email'] as String? ?? "";
      return ApiResponse.success(content);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to draft follow-up email';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
