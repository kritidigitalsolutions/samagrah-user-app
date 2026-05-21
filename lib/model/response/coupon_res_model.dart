class CouponResModel {
  CouponResModel({required this.success, required this.data});

  final bool? success;
  final List<CouponData> data;

  factory CouponResModel.fromJson(Map<String, dynamic> json) {
    return CouponResModel(
      success: json["success"],
      data: json["data"] == null
          ? []
          : List<CouponData>.from(
              json["data"]!.map((x) => CouponData.fromJson(x)),
            ),
    );
  }
}

class CouponData {
  CouponData({
    required this.id,
    required this.vendorId,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.maxDiscount,
    required this.usageLimit,
    required this.perUserLimit,
    required this.usedCount,
    required this.isActive,
    required this.startsAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? vendorId;
  final String? code;
  final String? title;
  final String? description;
  final String? discountType;
  final num? discountValue;
  final num? minOrderAmount;
  final num? maxDiscount;
  final num? usageLimit;
  final num? perUserLimit;
  final num? usedCount;
  final bool? isActive;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      id: json["_id"],
      vendorId: json["vendorId"],
      code: json["code"],
      title: json["title"],
      description: json["description"],
      discountType: json["discountType"],
      discountValue: json["discountValue"],
      minOrderAmount: json["minOrderAmount"],
      maxDiscount: json["maxDiscount"],
      usageLimit: json["usageLimit"],
      perUserLimit: json["perUserLimit"],
      usedCount: json["usedCount"],
      isActive: json["isActive"],
      startsAt: DateTime.tryParse(json["startsAt"] ?? ""),
      expiresAt: DateTime.tryParse(json["expiresAt"] ?? ""),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}
