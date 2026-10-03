class RitualResModel {
  RitualResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<RitualData> data;

  factory RitualResModel.fromJson(Map<String, dynamic> json) {
    return RitualResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<RitualData>.from(
              json["data"]!.map((x) => RitualData.fromJson(x)),
            ),
    );
  }
}

class RitualData {
  RitualData({
    required this.id,
    required this.title,
    required this.name,
    required this.description,
    required this.image,
    required this.durationHours,
    required this.travelForSpecialPooja,
    required this.standardSamagri,
    required this.customSamagri,
  });

  final String? id;
  final String? title;
  final String? name;
  final String? description;
  final String? image;
  final int? durationHours;
  final bool? travelForSpecialPooja;
  final bool? standardSamagri;
  final bool? customSamagri;

  factory RitualData.fromJson(Map<String, dynamic> json) {
    return RitualData(
      id: json["_id"],
      title: json["title"],
      name: json["name"],
      description: json["description"],
      image: json["image"],
      durationHours: json["durationHours"],
      travelForSpecialPooja: json["travelForSpecialPooja"],
      standardSamagri: json["standardSamagri"],
      customSamagri: json["customSamagri"],
    );
  }
}
