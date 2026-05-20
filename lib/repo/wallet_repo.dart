import 'package:flutter/foundation.dart';
import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/model/response/wallet_res/wallet_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class WalletRepo {
  final _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // ================================ get offers ======================

  // Future<OffersResModel> getOffers() async {
  //   try {
  //     final token = await _getToken();
  //     _api.setToken(token);
  //     final res = await _api.getApi(AppUrls.offers);
  //     return OffersResModel.fromJson(res);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // ================================ get wallet ======================

  Future<WalletResModel> getWallet() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.wallet);
      return WalletResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // =================== create order and verify payment ====================

  Future<Map<String, dynamic>> createWalletOrder(int amount) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      debugPrint("CREATE WALLET ORDER => amount: $amount");

      final res = await _api.postApi(AppUrls.walletCreateOrder, {
        "amount": amount,
      });

      return res;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyWalletPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required int amount,
  }) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      debugPrint(
        "VERIFY PAYMENT => "
        "orderId: $razorpayOrderId, "
        "paymentId: $razorpayPaymentId, "
        "amount: $amount",
      );

      final res = await _api.postApi(AppUrls.walletVerify, {
        "razorpayOrderId": razorpayOrderId,
        "razorpayPaymentId": razorpayPaymentId,
        "razorpaySignature": razorpaySignature,
        "amount": amount,
      });

      return res["success"] == true;
    } catch (e) {
      rethrow;
    }
  }

  // ==================coupon ===========================
  //
  //==========================================

  Future<CouponResModel> getCoupon() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.coupons);
      return CouponResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
