import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/clipped_job_model.dart';

final jobClipperRepositoryProvider = Provider<JobClipperRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return JobClipperRepository(apiClient: apiClient);
});

class JobClipperRepository {
  final ApiClient _apiClient;

  JobClipperRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<ClippedJobModel>> parseJobUrl(String url) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.jobsParseUrl,
        data: {'url': url.trim()},
      );

      final data = response.data as Map<String, dynamic>;
      final parsed = ClippedJobModel.fromParsedJson(
        json: data,
        url: url,
      );

      return ApiResponse.success(parsed);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to scrape job URL';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ClippedJobModel>> clipJob({
    required String url,
    required String title,
    required String company,
    String? location,
    String? salary,
    String? description,
    String? requirements,
    String status = "wishlist",
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/extension/clip',
        data: {
          'url': url.trim(),
          'title': title.trim(),
          'company': company.trim(),
          if (location != null && location.isNotEmpty) 'location': location.trim(),
          if (salary != null && salary.isNotEmpty) 'salary': salary.trim(),
          if (description != null) 'description': description,
          if (requirements != null) 'requirements': requirements,
          'source': ClippedJobModel.detectSource(url),
          'status': status,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final clipped = ClippedJobModel.fromClipApiResponse(
        json: data,
        url: url,
      );

      return ApiResponse.success(clipped, 201);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to clip job to pipeline';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
