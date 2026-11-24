class JobModel {
  final String id;
  final String title;
  final String? company;
  final String? location;
  final String? salary;
  final String? jobType;
  final String? description;
  final String? requirements;
  final String? sourceUrl;
  final int? matchScore;
  final bool isBookmarked;
  final DateTime? createdAt;

  const JobModel({
    required this.id,
    required this.title,
    this.company,
    this.location,
    this.salary,
    this.jobType,
    this.description,
    this.requirements,
    this.sourceUrl,
    this.matchScore,
    this.isBookmarked = false,
    this.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Role',
      company: json['company'] as String?,
      location: json['location'] as String?,
      salary: json['salary'] as String?,
      jobType: json['jobType'] as String?,
      description: json['description'] as String?,
      requirements: json['requirements'] is String
          ? json['requirements'] as String
          : json['requirements']?.toString(),
      sourceUrl: json['sourceUrl'] as String?,
      matchScore: (json['matchScore'] as num?)?.toInt(),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'description': description,
      'requirements': requirements,
      'sourceUrl': sourceUrl,
      'matchScore': matchScore,
      'isBookmarked': isBookmarked,
    };
  }
}
