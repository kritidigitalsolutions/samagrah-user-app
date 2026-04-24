class AboutusResModel {
  AboutusResModel({required this.success, required this.aboutUs});

  final bool? success;
  final AboutUs? aboutUs;

  factory AboutusResModel.fromJson(Map<String, dynamic> json) {
    return AboutusResModel(
      success: json["success"],
      aboutUs: json["aboutUs"] == null
          ? null
          : AboutUs.fromJson(json["aboutUs"]),
    );
  }
}

class AboutUs {
  AboutUs({required this.id, required this.type, required this.content});

  final String? id;
  final String? type;
  final String? content;

  factory AboutUs.fromJson(Map<String, dynamic> json) {
    return AboutUs(
      id: json["_id"],
      type: json["type"],
      content: json["content"],
    );
  }
}
