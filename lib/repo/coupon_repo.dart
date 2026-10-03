// repo/coupon_repo.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class CouponRepo {
  final _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  Future<CouponResModel> getCoupon() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.coupon);
      return CouponResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<ApplyCouponResModel> applyCoupon({
    required String code,
    required num amount,
  }) async {
    try {
      final response = await _api.postApi(AppUrls.couponApply, {
        'code': code,
        'amount': amount,
      });

      debugPrint('🎟️ Apply coupon response: $response');
      return ApplyCouponResModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ Apply coupon error: $e');
      rethrow;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply Coupon Response Models

// ─────────────────────────────────────────────────────────────────────────────

ApplyCouponResModel applyCouponResModelFromJson(String str) =>
    ApplyCouponResModel.fromJson(json.decode(str));

class ApplyCouponResModel {
  final bool success;
  final String message;
  final ApplyCouponData? data;

  ApplyCouponResModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApplyCouponResModel.fromJson(Map<String, dynamic> json) =>
      ApplyCouponResModel(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? ApplyCouponData.fromJson(json["data"])
            : null,
      );
}

class ApplyCouponData {
  /// The discount amount deducted (from "discount" key)
  final num discountAmount;

  /// Coupon code confirmed by the server
  final String couponCode;

  /// Nested coupon detail fields
  final String discountType;
  final num discountValue;
  final num minOrderAmount;
  final num maxDiscount;

  /// Newly added fields
  final int usedCount;
  final int perUserLimit;

  ApplyCouponData({
    required this.discountAmount,
    required this.couponCode,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    required this.maxDiscount,
    required this.usedCount,
    required this.perUserLimit,
  });

  factory ApplyCouponData.fromJson(Map<String, dynamic> json) {
    // "data.coupon" nested object
    final couponMap = json["coupon"] as Map<String, dynamic>? ?? json;

    return ApplyCouponData(
      // "data.discount" is the actual rupee amount deducted
      discountAmount: (json["discount"] ?? 0) as num,

      couponCode: (couponMap["code"] ?? '') as String,
      discountType: (couponMap["discountType"] ?? '') as String,
      discountValue: (couponMap["discountValue"] ?? 0) as num,
      minOrderAmount: (couponMap["minOrderAmount"] ?? 0) as num,
      maxDiscount: (couponMap["maxDiscount"] ?? 0) as num,

      // Added fields
      usedCount: (couponMap["usedCount"] ?? 0) as int,
      perUserLimit: (couponMap["perUserLimit"] ?? 0) as int,
    );
  }
}
