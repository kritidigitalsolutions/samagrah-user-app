// view_model/after_login_provider/home_provider/coupon_provider.dart

import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/repo/wallet_repo.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CouponState {
  final bool isLoading;
  final List<Offer> offers;
  final String? error;

  const CouponState({
    this.isLoading = false,
    this.offers = const [],
    this.error,
  });

  CouponState copyWith({bool? isLoading, List<Offer>? offers, String? error}) =>
      CouponState(
        isLoading: isLoading ?? this.isLoading,
        offers: offers ?? this.offers,
        error: error,
      );
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class CouponNotifier extends StateNotifier<CouponState> {
  CouponNotifier() : super(const CouponState()) {
    fetchCoupons();
  }

  final _repo = WalletRepo();

  Future<void> fetchCoupons() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final CouponResModel model = await _repo.getCoupon();

      state = state.copyWith(isLoading: false, offers: model.data.offers);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Optional: Refresh method
  Future<void> refresh() async {
    await fetchCoupons();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final couponProvider = StateNotifierProvider<CouponNotifier, CouponState>(
  (ref) => CouponNotifier(),
);
