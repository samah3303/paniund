class ProfileModel {
  final String id;
  final String? name;
  final String email;
  final String? phone;
  final String? location;
  final String? summary;
  final List<String> targetRoles;
  final List<String> skills;
  final List<Map<String, dynamic>> experience;
  final List<Map<String, dynamic>> education;
  final String? resumeFileName;
  final int? atsScore;
  final dynamic atsBreakdown;
  final List<String> recommendations;

  const ProfileModel({
    required this.id,
    this.name,
    required this.email,
    this.phone,
    this.location,
    this.summary,
    this.targetRoles = const [],
    this.skills = const [],
    this.experience = const [],
    this.education = const [],
    this.resumeFileName,
    this.atsScore,
    this.atsBreakdown,
    this.recommendations = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      return [];
    }

    List<Map<String, dynamic>> parseMapList(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    }

    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      summary: json['summary'] as String?,
      targetRoles: parseStringList(json['targetRoles']),
      skills: parseStringList(json['skills']),
      experience: parseMapList(json['experience']),
      education: parseMapList(json['education']),
      resumeFileName: json['resumeFileName'] as String?,
      atsScore: (json['atsScore'] as num?)?.toInt(),
      atsBreakdown: json['atsBreakdown'],
      recommendations: parseStringList(json['recommendations']),
    );
  }
}
