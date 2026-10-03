class BannerResModel {
  BannerResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<BannerData> data;

  factory BannerResModel.fromJson(Map<String, dynamic> json) {
    return BannerResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<BannerData>.from(
              json["data"]!.map((x) => BannerData.fromJson(x)),
            ),
    );
  }
}

class BannerData {
  BannerData({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.subTitle,
    required this.description,
    required this.image,
    required this.priceOff,
    required this.status,
    required this.coupon,
    required this.offer,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? vendorId;
  final String? title;
  final String? subTitle;
  final String? description;
  final String? image;
  final String? priceOff;
  final String? status;
  final BannerCoupon? coupon;
  final BannerOffer? offer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Banner ka koi coupon/offer attach hai ya nahi
  bool get hasCoupon => coupon != null;
  bool get hasOffer => offer != null;

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json["_id"],
      vendorId: json["vendorId"]?.toString(),
      title: json["title"],
      subTitle: json["subTitle"],
      description: json["description"],
      image: json["image"],
      priceOff: json["priceOff"],
      status: json["status"],
      coupon: json["couponId"] is Map
          ? BannerCoupon.fromJson(json["couponId"])
          : null,
      offer: json["offerId"] is Map
          ? BannerOffer.fromJson(json["offerId"])
          : null,
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}

class BannerCoupon {
  BannerCoupon({
    required this.id,
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
    required this.isWelcomeCoupon,
    required this.startsAt,
    required this.expiresAt,
    required this.isRestricted,
  });

  final String? id;
  final String? code;
  final String? title;
  final String? description;
  final String? discountType;
  final num? discountValue;
  final num? minOrderAmount;
  final num? maxDiscount;
  final int? usageLimit;
  final int? perUserLimit;
  final int? usedCount;
  final bool? isActive;
  final bool? isWelcomeCoupon;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool? isRestricted;

  factory BannerCoupon.fromJson(Map<String, dynamic> json) {
    return BannerCoupon(
      id: json["_id"],
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
      isWelcomeCoupon: json["isWelcomeCoupon"],
      startsAt: DateTime.tryParse(json["startsAt"] ?? ""),
      expiresAt: DateTime.tryParse(json["expiresAt"] ?? ""),
      isRestricted: json["isRestricted"],
    );
  }
}

class BannerOffer {
  BannerOffer({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.description,
    required this.image,
    required this.offerType,
    required this.discountType,
    required this.value,
    required this.minOrderAmount,
    required this.maxBenefit,
    required this.isActive,
    required this.startsAt,
    required this.expiresAt,
  });

  final String? id;
  final String? vendorId;
  final String? title;
  final String? description;
  final String? image;
  final String? offerType;
  final String? discountType;
  final num? value;
  final num? minOrderAmount;
  final num? maxBenefit;
  final bool? isActive;
  final DateTime? startsAt;
  final DateTime? expiresAt;

  factory BannerOffer.fromJson(Map<String, dynamic> json) {
    return BannerOffer(
      id: json["_id"],
      vendorId: json["vendorId"],
      title: json["title"],
      description: json["description"],
      image: json["image"],
      offerType: json["offerType"],
      discountType: json["discountType"],
      value: json["value"],
      minOrderAmount: json["minOrderAmount"],
      maxBenefit: json["maxBenefit"],
      isActive: json["isActive"],
      startsAt: DateTime.tryParse(json["startsAt"] ?? ""),
      expiresAt: DateTime.tryParse(json["expiresAt"] ?? ""),
    );
  }
}
