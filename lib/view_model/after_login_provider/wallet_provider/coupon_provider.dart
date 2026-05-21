// view_model/after_login_provider/wallet_provider/coupon_provider.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/repo/coupon_repo.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CouponState {
  final bool isLoading;
  final List<CouponData> coupon;
  final String? error;

  final bool isApplying;
  final String? appliedCode;
  final num discountAmount;
  final num finalAmount;
  final String? applyError;
  final bool isApplySuccess;

  const CouponState({
    this.isLoading = false,
    this.coupon = const [],
    this.error,
    this.isApplying = false,
    this.appliedCode,
    this.discountAmount = 0,
    this.finalAmount = 0,
    this.applyError,
    this.isApplySuccess = false,
  });

  bool get isCouponApplied => appliedCode != null && discountAmount > 0;

  CouponState copyWith({
    bool? isLoading,
    List<CouponData>? coupon,
    String? error,
    bool? isApplying,
    String? appliedCode,
    num? discountAmount,
    num? finalAmount,
    String? applyError,
    bool? isApplySuccess,
    bool clearApplied = false,
    bool clearApplyError = false,
  }) => CouponState(
    isLoading: isLoading ?? this.isLoading,
    coupon: coupon ?? this.coupon,
    error: error ?? this.error,
    isApplying: isApplying ?? this.isApplying,
    appliedCode: clearApplied ? null : (appliedCode ?? this.appliedCode),
    discountAmount: clearApplied ? 0 : (discountAmount ?? this.discountAmount),
    finalAmount: clearApplied ? 0 : (finalAmount ?? this.finalAmount),
    applyError: clearApplyError ? null : (applyError ?? this.applyError),
    isApplySuccess: isApplySuccess ?? this.isApplySuccess,
  );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CouponNotifier extends StateNotifier<CouponState> {
  CouponNotifier() : super(const CouponState()) {
    fetchCoupons();
  }

  final _couponRepo = CouponRepo();

  Future<void> fetchCoupons() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final CouponResModel model = await _couponRepo.getCoupon();
      state = state.copyWith(isLoading: false, coupon: model.data);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => fetchCoupons();

  Future<void> applyCoupon({
    required String code,
    required num amount, // original cart total passed from payment page
  }) async {
    if (code.trim().isEmpty) {
      state = state.copyWith(applyError: "Please enter a coupon code");
      return;
    }

    state = state.copyWith(
      isApplying: true,
      clearApplyError: true,
      isApplySuccess: false,
    );

    try {
      final res = await _couponRepo.applyCoupon(
        code: code.trim().toUpperCase(),
        amount: amount,
      );

      if (res.success && res.data != null) {
        final discount = res.data!.discountAmount; // e.g. 200.01
        final appliedCode = res.data!.couponCode.isNotEmpty
            ? res.data!.couponCode
            : code.trim().toUpperCase();
        // finalAmount = original amount − discount (server doesn't send it)
        final finalAmt = (amount - discount).clamp(0.0, double.infinity);

        state = state.copyWith(
          isApplying: false,
          appliedCode: appliedCode,
          discountAmount: discount,
          finalAmount: finalAmt,
          isApplySuccess: true,
        );
      } else {
        state = state.copyWith(
          isApplying: false,
          applyError: res.message.isNotEmpty
              ? res.message
              : "Invalid coupon code",
          isApplySuccess: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        applyError: "Failed to apply coupon. Try again.",
        isApplySuccess: false,
      );
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      clearApplied: true,
      clearApplyError: true,
      isApplySuccess: false,
    );
  }

  void clearApplyStatus() {
    state = state.copyWith(clearApplyError: true, isApplySuccess: false);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final couponProvider = StateNotifierProvider<CouponNotifier, CouponState>(
  (ref) => CouponNotifier(),
);
