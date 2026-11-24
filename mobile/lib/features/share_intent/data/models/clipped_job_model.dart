class ClippedJobModel {
  final String? jobId;
  final String? applicationId;
  final String title;
  final String company;
  final String? location;
  final String? salary;
  final String? description;
  final String? requirements;
  final String sourceUrl;
  final String source;
  final int matchScore;
  final List<String> matchedSkills;
  final List<String> missingSkills;
  final String status;

  const ClippedJobModel({
    this.jobId,
    this.applicationId,
    required this.title,
    required this.company,
    this.location,
    this.salary,
    this.description,
    this.requirements,
    required this.sourceUrl,
    required this.source,
    this.matchScore = 75,
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.status = "wishlist",
  });

  static String detectSource(String url) {
    final lower = url.toLowerCase();
    if (lower.contains("linkedin.com")) return "LinkedIn";
    if (lower.contains("indeed.com")) return "Indeed";
    if (lower.contains("glassdoor.com")) return "Glassdoor";
    if (lower.contains("bayt.com")) return "Bayt";
    if (lower.contains("monster.com")) return "Monster";
    return "Web Listing";
  }

  factory ClippedJobModel.fromParsedJson({
    required Map<String, dynamic> json,
    required String url,
    int? matchScore,
    List<String>? matchedSkills,
    List<String>? missingSkills,
  }) {
    final source = detectSource(url);
    final title = (json['title'] as String?)?.trim();
    final company = (json['company'] as String?)?.trim();

    return ClippedJobModel(
      title: (title != null && title.isNotEmpty) ? title : "Position via $source",
      company: (company != null && company.isNotEmpty) ? company : source,
      location: json['location'] as String?,
      salary: json['salary'] as String?,
      description: json['description'] as String?,
      requirements: json['requirements'] is String
          ? json['requirements'] as String
          : json['requirements']?.toString(),
      sourceUrl: url,
      source: source,
      matchScore: matchScore ?? 78,
      matchedSkills: matchedSkills ?? [],
      missingSkills: missingSkills ?? [],
    );
  }

  factory ClippedJobModel.fromClipApiResponse({
    required Map<String, dynamic> json,
    required String url,
  }) {
    List<String> parseList(dynamic val) {
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    return ClippedJobModel(
      jobId: json['jobId'] as String?,
      applicationId: json['applicationId'] as String?,
      title: json['title'] as String? ?? "Position via Web",
      company: json['company'] as String? ?? "Hiring Company",
      location: json['location'] as String?,
      salary: json['salary'] as String?,
      sourceUrl: url,
      source: detectSource(url),
      matchScore: (json['matchScore'] as num?)?.toInt() ?? 78,
      matchedSkills: parseList(json['matchedSkills']),
      missingSkills: parseList(json['missingSkills']),
      status: json['status'] as String? ?? "wishlist",
    );
  }

  ClippedJobModel copyWith({
    String? jobId,
    String? applicationId,
    String? title,
    String? company,
    String? location,
    String? salary,
    String? description,
    String? requirements,
    String? sourceUrl,
    String? source,
    int? matchScore,
    List<String>? matchedSkills,
    List<String>? missingSkills,
    String? status,
  }) {
    return ClippedJobModel(
      jobId: jobId ?? this.jobId,
      applicationId: applicationId ?? this.applicationId,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      salary: salary ?? this.salary,
      description: description ?? this.description,
      requirements: requirements ?? this.requirements,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      source: source ?? this.source,
      matchScore: matchScore ?? this.matchScore,
      matchedSkills: matchedSkills ?? this.matchedSkills,
      missingSkills: missingSkills ?? this.missingSkills,
      status: status ?? this.status,
    );
  }
}
