class BrandsResModel {
  BrandsResModel({
    required this.success,
    required this.city,
    required this.count,
    required this.data,
  });

  final bool? success;
  final String? city;
  final int? count;
  final List<BrandsData> data;

  factory BrandsResModel.fromJson(Map<String, dynamic> json) {
    return BrandsResModel(
      success: json["success"],
      city: json["city"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<BrandsData>.from(
              json["data"]!.map((x) => BrandsData.fromJson(x)),
            ),
    );
  }
}

class BrandsData {
  BrandsData({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.code,
    required this.description,
    required this.image,
    required this.subBrand,
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
  final String? subBrand;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory BrandsData.fromJson(Map<String, dynamic> json) {
    return BrandsData(
      id: json["_id"],
      vendorId: json["vendorId"],
      name: json["name"],
      code: json["code"],
      description: json["description"],
      image: json["image"],
      subBrand: json["subBrand"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
