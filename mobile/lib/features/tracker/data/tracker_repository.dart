import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import 'models/application_model.dart';

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TrackerRepository(apiClient: apiClient);
});

class TrackerRepository {
  final ApiClient _apiClient;

  TrackerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<ApiResponse<List<ApplicationModel>>> getApplications() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.applications);
      final rawList = response.data as List;
      final apps = rawList
          .map((item) => ApplicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(apps);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to load applications';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ApplicationModel>> updateApplication(
    String id, {
    String? status,
    String? notes,
    String? contactPerson,
    DateTime? interviewDate,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (status != null) updateData['status'] = status;
      if (notes != null) updateData['notes'] = notes;
      if (contactPerson != null) updateData['contactPerson'] = contactPerson;
      if (interviewDate != null) {
        updateData['interviewDate'] = interviewDate.toIso8601String();
      }

      final response = await _apiClient.put(
        ApiEndpoints.applicationDetail(id),
        data: updateData,
      );

      final app = ApplicationModel.fromJson(response.data as Map<String, dynamic>);
      return ApiResponse.success(app);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to update application';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ApplicationModel>> createOpportunity({
    required String title,
    required String company,
    String? location,
    String? salary,
    String? sourceUrl,
    String status = "applied",
  }) async {
    try {
      // 1. Create the Job record first
      final jobResponse = await _apiClient.post(
        ApiEndpoints.jobs,
        data: {
          'title': title.trim(),
          'company': company.trim(),
          if (location != null && location.isNotEmpty) 'location': location.trim(),
          if (salary != null && salary.isNotEmpty) 'salary': salary.trim(),
          if (sourceUrl != null && sourceUrl.isNotEmpty) 'sourceUrl': sourceUrl.trim(),
          'source': 'mobile_tracker',
        },
      );

      final jobData = jobResponse.data as Map<String, dynamic>;
      final jobId = jobData['id'] as String;

      // 2. Create the Application record linked to the job
      final appResponse = await _apiClient.post(
        ApiEndpoints.applications,
        data: {
          'jobId': jobId,
          'status': status,
        },
      );

      final appData = appResponse.data as Map<String, dynamic>;
      final app = ApplicationModel.fromJson(appData);
      return ApiResponse.success(app, 201);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to add opportunity';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<bool>> deleteApplication(String id) async {
    try {
      await _apiClient.delete(ApiEndpoints.applicationDetail(id));
      return ApiResponse.success(true);
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ??
          e.message ??
          'Failed to delete application';
      return ApiResponse.error(msg, e.response?.statusCode);
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
