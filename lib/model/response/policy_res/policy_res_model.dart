class PolicyResModel {
  PolicyResModel({required this.success, required this.legal});

  final bool? success;
  final Legal? legal;

  factory PolicyResModel.fromJson(Map<String, dynamic> json) {
    return PolicyResModel(
      success: json["success"],
      legal: json["legal"] == null ? null : Legal.fromJson(json["legal"]),
    );
  }
}

class Legal {
  Legal({required this.id, required this.type, required this.content});

  final String? id;
  final String? type;
  final String? content;

  factory Legal.fromJson(Map<String, dynamic> json) {
    return Legal(id: json["_id"], type: json["type"], content: json["content"]);
  }
}
