class CategoryResModel {
  CategoryResModel({
    required this.success,
    required this.city,
    required this.count,
    required this.data,
  });

  final bool? success;
  final String? city;
  final int? count;
  final List<CategoryData> data;

  factory CategoryResModel.fromJson(Map<String, dynamic> json) {
    return CategoryResModel(
      success: json["success"],
      city: json["city"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<CategoryData>.from(
              json["data"]!.map((x) => CategoryData.fromJson(x)),
            ),
    );
  }
}

class CategoryData {
  CategoryData({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.code,
    required this.description,
    required this.image,
    required this.subCategory,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? vendorId;
  final String? name;
  final String? code;
  final String? description;
  final String? image;
  final String? subCategory;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json["_id"],
      vendorId: json["vendorId"],
      name: json["name"],
      code: json["code"],
      description: json["description"],
      image: json["image"],
      subCategory: json["subCategory"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
