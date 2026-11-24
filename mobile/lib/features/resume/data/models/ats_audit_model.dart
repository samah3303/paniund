class AtsAuditModel {
  final int overallScore;
  final int formatScore;
  final int keywordScore;
  final int impactScore;
  final int quantificationScore;
  final List<String> recommendations;
  final List<String> keywordsFound;
  final List<String> missingKeywords;
  final String? formattingNotes;

  const AtsAuditModel({
    required this.overallScore,
    required this.formatScore,
    required this.keywordScore,
    required this.impactScore,
    required this.quantificationScore,
    this.recommendations = const [],
    this.keywordsFound = const [],
    this.missingKeywords = const [],
    this.formattingNotes,
  });

  factory AtsAuditModel.fromJson(Map<String, dynamic> json) {
    List<String> parseStringList(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list.map((e) => e.toString()).toList();
      }
      return [];
    }

    final details = json['details'] as Map<String, dynamic>?;

    return AtsAuditModel(
      overallScore: (json['overallScore'] as num?)?.toInt() ?? 0,
      formatScore: (json['formatScore'] as num?)?.toInt() ?? 0,
      keywordScore: (json['keywordScore'] as num?)?.toInt() ?? 0,
      impactScore: (json['impactScore'] as num?)?.toInt() ?? 0,
      quantificationScore: (json['quantificationScore'] as num?)?.toInt() ?? 0,
      recommendations: parseStringList(json['recommendations']),
      keywordsFound: parseStringList(details?['keywordsFound']),
      missingKeywords: parseStringList(details?['missingKeywords']),
      formattingNotes: details?['formattingNotes'] as String?,
    );
  }

  factory AtsAuditModel.fromProfileData({
    required int? atsScore,
    required dynamic atsBreakdown,
    required dynamic recommendations,
  }) {
    List<String> parseList(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    Map<String, dynamic> breakdownMap = {};
    if (atsBreakdown is Map<String, dynamic>) {
      breakdownMap = atsBreakdown;
    }

    final overall = atsScore ?? (breakdownMap['overallScore'] as num?)?.toInt() ?? 0;
    final format = (breakdownMap['formatScore'] as num?)?.toInt() ?? (overall > 0 ? (overall * 0.95).toInt() : 0);
    final keyword = (breakdownMap['keywordScore'] as num?)?.toInt() ?? (overall > 0 ? (overall * 0.9).toInt() : 0);
    final impact = (breakdownMap['impactScore'] as num?)?.toInt() ?? (overall > 0 ? (overall * 0.85).toInt() : 0);
    final quant = (breakdownMap['quantificationScore'] as num?)?.toInt() ?? (overall > 0 ? (overall * 0.8).toInt() : 0);

    final details = breakdownMap['details'] as Map<String, dynamic>?;

    return AtsAuditModel(
      overallScore: overall,
      formatScore: format,
      keywordScore: keyword,
      impactScore: impact,
      quantificationScore: quant,
      recommendations: parseList(recommendations),
      keywordsFound: parseList(details?['keywordsFound']),
      missingKeywords: parseList(details?['missingKeywords']),
      formattingNotes: details?['formattingNotes'] as String?,
    );
  }
}
