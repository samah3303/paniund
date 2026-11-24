import 'job_model.dart';

class ApplicationModel {
  final String id;
  final String jobId;
  final JobModel job;
  final String status;
  final String? notes;
  final String? contactPerson;
  final DateTime? interviewDate;
  final DateTime? appliedAt;
  final int? atsScore;
  final String? coverLetter;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> statusHistory;

  const ApplicationModel({
    required this.id,
    required this.jobId,
    required this.job,
    required this.status,
    this.notes,
    this.contactPerson,
    this.interviewDate,
    this.appliedAt,
    this.atsScore,
    this.coverLetter,
    this.createdAt,
    this.statusHistory = const [],
  });

  /// Normalizes server status into one of 6 pipeline buckets:
  /// wishlist, applied, screening, interview, offer, archived
  String get normalizedStage {
    final s = status.toLowerCase().trim();
    switch (s) {
      case "wishlist":
      case "saved":
        return "wishlist";
      case "applied":
        return "applied";
      case "screening":
      case "phone_screen":
      case "review":
        return "screening";
      case "interview":
      case "interviewing":
      case "tech_screen":
        return "interview";
      case "offer":
      case "offered":
      case "accepted":
        return "offer";
      case "archived":
      case "rejected":
      case "declined":
        return "archived";
      default:
        return "applied";
    }
  }

  bool get isInterviewSoon {
    if (interviewDate == null) return false;
    final now = DateTime.now();
    final difference = interviewDate!.difference(now);
    return !difference.isNegative && difference.inHours <= 48;
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    JobModel job;
    if (json['job'] is Map<String, dynamic>) {
      job = JobModel.fromJson(json['job'] as Map<String, dynamic>);
    } else {
      job = JobModel(
        id: json['jobId'] as String? ?? '',
        title: 'Untitled Job',
      );
    }

    List<Map<String, dynamic>> history = [];
    if (json['statusHistory'] is List) {
      history = (json['statusHistory'] as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return ApplicationModel(
      id: json['id'] as String,
      jobId: json['jobId'] as String,
      job: job,
      status: json['status'] as String? ?? 'applied',
      notes: json['notes'] as String?,
      contactPerson: json['contactPerson'] as String?,
      interviewDate: json['interviewDate'] != null
          ? DateTime.tryParse(json['interviewDate'] as String)
          : null,
      appliedAt: json['appliedAt'] != null
          ? DateTime.tryParse(json['appliedAt'] as String)
          : null,
      atsScore: (json['atsScore'] as num?)?.toInt() ?? job.matchScore,
      coverLetter: json['coverLetter'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      statusHistory: history,
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    JobModel? job,
    String? status,
    String? notes,
    String? contactPerson,
    DateTime? interviewDate,
    DateTime? appliedAt,
    int? atsScore,
    String? coverLetter,
    DateTime? createdAt,
    List<Map<String, dynamic>>? statusHistory,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      job: job ?? this.job,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      contactPerson: contactPerson ?? this.contactPerson,
      interviewDate: interviewDate ?? this.interviewDate,
      appliedAt: appliedAt ?? this.appliedAt,
      atsScore: atsScore ?? this.atsScore,
      coverLetter: coverLetter ?? this.coverLetter,
      createdAt: createdAt ?? this.createdAt,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}
