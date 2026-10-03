class SubCategoryResModel {
  SubCategoryResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<SubCategoryData> data;

  factory SubCategoryResModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<SubCategoryData>.from(
              json["data"]!.map((x) => SubCategoryData.fromJson(x)),
            ),
    );
  }
}

class SubCategoryData {
  SubCategoryData({
    required this.id,
    required this.image,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.code,
    required this.v,
  });

  final String? id;
  final String? image;
  final SubCategoryParent? categoryId;
  final String? name;
  final String? description;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? code;
  final int? v;

  factory SubCategoryData.fromJson(Map<String, dynamic> json) {
    return SubCategoryData(
      id: json["_id"],
      image: json["image"],
      categoryId: json["categoryId"] == null
          ? null
          : SubCategoryParent.fromJson(json["categoryId"]),
      name: json["name"],
      description: json["description"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      code: json["code"],
      v: json["__v"],
    );
  }
}

class SubCategoryParent {
  SubCategoryParent({required this.id, required this.name, required this.code});

  final String? id;
  final String? name;
  final String? code;

  factory SubCategoryParent.fromJson(Map<String, dynamic> json) {
    return SubCategoryParent(
      id: json["_id"],
      name: json["name"],
      code: json["code"],
    );
  }
}
