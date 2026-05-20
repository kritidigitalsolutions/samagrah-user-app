import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:samagrah/model/response/wallet_res/offers_res_model.dart';
import 'package:samagrah/model/response/wallet_res/wallet_res_model.dart';
import 'package:samagrah/repo/wallet_repo.dart';

final walletRepoProvider = Provider((ref) => WalletRepo());

// final offerProvider = FutureProvider<OffersResModel>((ref) async {
//   final repo = ref.read(walletRepoProvider);
//   return repo.getOffers();
// });

final walletProvider = FutureProvider<WalletResModel>((ref) async {
  final repo = ref.read(walletRepoProvider);
  return repo.getWallet();
});

// ====================================================================

final addMoneyLoadingProvider = StateProvider<bool>((ref) => false);
final selectedAmountProvider = StateProvider<int?>((ref) => null);

// ======================= wallet yop up =====================

final razorpayProvider = Provider<RazorpayService>((ref) {
  return RazorpayService(ref);
});

class RazorpayService {
  final Ref ref;
  late Razorpay _razorpay;
  int amount = 0;

  RazorpayService(this.ref) {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<bool> openCheckout(int amount) async {
    try {
      final repo = ref.read(walletRepoProvider);

      this.amount = amount;

      final order = await repo.createWalletOrder(amount);

      final options = {
        "key": "rzp_test_ScAfkfdSrrcuVo",
        "amount": amount * 100,
        "name": "Samagran",
        "description": "Wallet Topup",
        "order_id": order["data"]["razorpayOrder"]["id"],
        "prefill": {"contact": "9999999999", "email": "test@gmail.com"},
      };

      _razorpay.open(options);
      return true;
    } catch (e) {
      debugPrint("RAZORPAY ERROR => $e");
      return false;
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final repo = ref.read(walletRepoProvider);

      final success = await repo.verifyWalletPayment(
        razorpayOrderId: response.orderId ?? "",
        razorpayPaymentId: response.paymentId ?? "",
        razorpaySignature: response.signature ?? "",
        amount: amount,
      );

      if (success) {
        ref.invalidate(walletProvider);
        debugPrint("Wallet credited successfully");
      }
    } catch (e) {
      debugPrint("VERIFY ERROR => $e");
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("PAYMENT FAILED => ${response.message}");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("EXTERNAL WALLET => ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
