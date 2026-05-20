// model/response/product_res/coupon_res_model.dart

import 'dart:convert';

CouponResModel couponResModelFromJson(String str) =>
    CouponResModel.fromJson(json.decode(str));

class CouponResModel {
  final bool success;
  final CouponData data;

  CouponResModel({required this.success, required this.data});

  factory CouponResModel.fromJson(Map<String, dynamic> json) => CouponResModel(
    success: json["success"] ?? false,
    data: CouponData.fromJson(json["data"] ?? {}),
  );
}

class CouponData {
  final List<Offer> offers;

  CouponData({required this.offers});

  factory CouponData.fromJson(Map<String, dynamic> json) => CouponData(
    offers: List<Offer>.from(
      (json["offers"] ?? []).map((x) => Offer.fromJson(x)),
    ),
  );
}

class Offer {
  final String id;
  final String vendorId;
  final String title;
  final String description;
  final String offerType;
  final String discountType;
  final num value;
  final num minOrderAmount;
  final num maxBenefit;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Offer({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.description,
    required this.offerType,
    required this.discountType,
    required this.value,
    required this.minOrderAmount,
    required this.maxBenefit,
    required this.isActive,
    this.startsAt,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) => Offer(
    id: json["_id"] ?? '',
    vendorId: json["vendorId"] ?? '',
    title: json["title"] ?? '',
    description: json["description"] ?? '',
    offerType: json["offerType"] ?? '',
    discountType: json["discountType"] ?? '',
    value: json["value"] ?? 0,
    minOrderAmount: json["minOrderAmount"] ?? 0,
    maxBenefit: json["maxBenefit"] ?? 0,
    isActive: json["isActive"] ?? false,
    startsAt: json["startsAt"] != null
        ? DateTime.tryParse(json["startsAt"])
        : null,
    expiresAt: json["expiresAt"] != null
        ? DateTime.tryParse(json["expiresAt"])
        : null,
    createdAt: json["createdAt"] != null
        ? DateTime.tryParse(json["createdAt"])
        : null,
    updatedAt: json["updatedAt"] != null
        ? DateTime.tryParse(json["updatedAt"])
        : null,
  );

  /// Returns true if the offer is currently valid
  bool get isValid {
    final now = DateTime.now();
    final started = startsAt == null || now.isAfter(startsAt!);
    final notExpired = expiresAt == null || now.isBefore(expiresAt!);
    return isActive && started && notExpired;
  }

  /// Returns days remaining until expiry (null if no expiry)
  int? get daysRemaining {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Formatted discount label e.g. "20% OFF" or "₹200 OFF"
  String get discountLabel {
    if (discountType == 'percent') {
      return '${value.toInt()}% OFF';
    } else {
      return '₹${value.toInt()} OFF';
    }
  }
}
