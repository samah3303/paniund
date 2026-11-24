enum GenerationType {
  coverLetter,
  bulletUpgrade,
  linkedinOutreach,
  followupEmail,
}

enum GenerationTone {
  professional,
  confident,
  conversational,
  humble,
}

class GenerationRequestModel {
  final GenerationType type;
  final String? jobId;
  final String jobTitle;
  final String company;
  final String? jobDescription;
  final GenerationTone tone;
  final String? linkedinMessageType; // connection_request, inmail, referral_request
  final String? followupContext; // post_application, post_interview, status_inquiry

  const GenerationRequestModel({
    required this.type,
    this.jobId,
    required this.jobTitle,
    required this.company,
    this.jobDescription,
    this.tone = GenerationTone.professional,
    this.linkedinMessageType = "connection_request",
    this.followupContext = "post_interview",
  });

  String get toneString {
    switch (tone) {
      case GenerationTone.professional:
        return "professional";
      case GenerationTone.confident:
        return "confident";
      case GenerationTone.conversational:
        return "conversational";
      case GenerationTone.humble:
        return "humble";
    }
  }
}
