import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiEndpoints {
  // Configurable base URL
  static String get baseUrl {
    if (kReleaseMode) {
      return "https://paniund.com";
    }
    // In local debug mode, map emulator / simulator addresses
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:3000";
    }
    return "http://localhost:3000";
  }

  // Authentication
  static const String mobileLogin = "/api/auth/mobile/login";
  static const String mobileRegister = "/api/auth/mobile/register";

  // Profile & Candidate
  static const String profile = "/api/profile";
  static const String apiToken = "/api/user/api-token";
  static const String dashboardStats = "/api/dashboard/stats";

  // Resume Management
  static const String resumeUpload = "/api/resume/upload";
  static const String resumeAnalyze = "/api/resume/analyze";

  // Job Pipeline CRM
  static const String jobs = "/api/jobs";
  static String jobDetail(String id) => "/api/jobs/$id";
  static const String jobsMatch = "/api/jobs/match";
  static const String jobsParseUrl = "/api/jobs/parse-url";
  static const String jobsAiSearch = "/api/jobs/ai-search";

  // Applications
  static const String applications = "/api/applications";
  static String applicationDetail(String id) => "/api/applications/$id";

  // AI Content Generation Suite
  static const String generateCoverLetter = "/api/generate/cover-letter";
  static const String generateFollowupEmail = "/api/generate/followup-email";
  static const String generateLinkedinMessage = "/api/generate/linkedin-message";
  static const String generateResumeUpdates = "/api/generate/resume-updates";
}
