import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:samagrah/data/exception/app_exception.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/product_res/delivered_res_model.dart';
import 'package:samagrah/repo/payment_repo.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/state/payment_state.dart';

final deliveryRepo = Provider((ref) => ProductRepo());

/// Fetches delivery charge data from the API.
/// Called automatically when PaymentPage mounts.
final deliveryProvider = FutureProvider<DeliveredResModel>((ref) async {
  final repo = ref.read(deliveryRepo);
  return repo.getDeliveredCharge();
});

/// Threshold below which delivery charges apply (in ₹).
/// Change this value to update the free-delivery minimum order amount.
const double kFreeDeliveryThreshold = 500.0;

/// Resolves the delivery charge for the current order.
///
/// Logic:
///  - Fetches [DeliveredResModel] from API.
///  - If order amount >= [kFreeDeliveryThreshold] → delivery is FREE (₹0).
///  - Otherwise → uses the first active location's [deliveryCharge] from the API.
///    Falls back to ₹0 if no active entry is found.
final resolvedDeliveryChargeProvider =
    Provider.family<AsyncValue<double>, double>((ref, orderAmount) {
      final deliveryAsync = ref.watch(deliveryProvider);

      return deliveryAsync.when(
        data: (model) {
          // Free delivery for orders >= threshold
          if (orderAmount >= kFreeDeliveryThreshold) {
            return const AsyncValue.data(0.0);
          }

          // Pick first active location's charge
          final activeDatum = model.data
              .where((d) => d.status == 'active')
              .firstOrNull;
          final charge = activeDatum?.deliveryCharge?.toDouble() ?? 0.0;
          return AsyncValue.data(charge);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    });

/// COD charge always applies for COD orders, regardless of order amount.
final resolvedCodChargeProvider = Provider<AsyncValue<double>>((ref) {
  final deliveryAsync = ref.watch(deliveryProvider);

  return deliveryAsync.when(
    data: (model) {
      final activeDatum = model.data
          .where((d) => d.status == 'active')
          .firstOrNull;
      return AsyncValue.data(activeDatum?.codCharge?.toDouble() ?? 0.0);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// payment provider
//
//====================================

final loadingProvider = StateProvider<bool>((ref) => false);

final paymentProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(),
);

class PaymentNotifier extends StateNotifier<PaymentState> {
  PaymentNotifier() : super(const PaymentState());

  late Razorpay _razorpay;
  late Address address;
  String couponCode = "";
  String panditId = "";
  double deliveryFee = 0.0;
  late List<VerifyItem> items;
  final PaymentRepo _repo = PaymentRepo();

  void init() {
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  @override
  void dispose() {
    // cleanup here (razorpay clear etc.)
    _razorpay.clear(); // example
    super.dispose();
  }

  // 🚀 START PAYMENT
  Future<void> startPayment(
    Address address,
    List<VerifyItem> items,
    String couponCode,
    String panditId,
    double deliveryFee,
  ) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      debugPrint("🚀 START PAYMENT");
      debugPrint("🚀 ${address.toJson()}");
      debugPrint("🚀 $items");

      this.address = address;
      this.items = items;
      this.couponCode = couponCode;
      this.panditId = panditId;
      this.deliveryFee = deliveryFee;

      final user = await AuthLocalstorageService.getUser();
      debugPrint("👤 User: $user");

      final createReq = CreateOrderReqModel(
        deliveryFee: deliveryFee,
        items: items,
        couponCode: couponCode,
        panditId: panditId,
      );

      debugPrint("📤 CreateOrder Request: ${createReq.toJson()}");

      final orderRes = await _repo.productCreateOrder(createReq);

      debugPrint("📥 CreateOrder Response: ${orderRes.data}");

      final data = orderRes.data;
      final order = data?.razorpayOrder;

      debugPrint("📦 Order Object: $order");
      debugPrint("🆔 Order ID: ${order?.id}");
      debugPrint("💰 Amount: ${order?.amount}");

      // ❗ VALIDATION
      if (order == null || order.id == null || order.id!.isEmpty) {
        debugPrint("❌ Invalid Order ID");
        state = state.copyWith(isLoading: false, error: "Invalid Order ID");
        return;
      }

      if (order.amount == null || order.amount == 0) {
        debugPrint("❌ Invalid Amount");
        state = state.copyWith(isLoading: false, error: "Invalid Amount");
        return;
      }

      final orderId = order.id!;
      final amount = order.amount!;

      final contact = user?["phone"] ?? "";
      final email = user?["email"] ?? "";

      debugPrint("📞 Contact: $contact");
      debugPrint("📧 Email: $email");

      debugPrint("✅ READY TO OPEN RAZORPAY");

      // 👉 Uncomment when ready
      _openCheckout(
        orderId: orderId,
        amount: amount,
        contact: contact,
        email: email,
      );

      state = state.copyWith(isLoading: false);
    } catch (e, stack) {
      debugPrint("🔥 ERROR: $e");
      debugPrint("📍 STACK: $stack");

      state = state.copyWith(isLoading: false, error: _userFriendlyError(e));
    }
  }

  void _openCheckout({
    required String orderId,
    required int amount,
    String? contact,
    String? email,
  }) {
    var options = {
      'key': 'rzp_test_ScAfkfdSrrcuVo',

      // ✅ Use backend amount (already in paise)
      'amount': amount,

      'order_id': orderId,
      'name': 'Samagran',
      'description': 'Puja Kit Payment',

      'prefill': {
        'contact': contact?.isNotEmpty == true ? contact : '',
        'email': email?.isNotEmpty == true ? email : '',
      },

      'theme': {'color': '#CA1F48'},

      'timeout': 120,
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      state = state.copyWith(error: "Failed to open payment");
    }
  }

  // ✅ SUCCESS
  void _handleSuccess(PaymentSuccessResponse res) async {
    debugPrint("🎯 PAYMENT SUCCESS CALLBACK TRIGGERED");

    debugPrint("📦 Raw Response:");
    debugPrint("➡️ OrderId: ${res.orderId}");
    debugPrint("➡️ PaymentId: ${res.paymentId}");
    debugPrint("➡️ Signature: ${res.signature}");

    // ❌ VALIDATION
    if (res.orderId == null || res.paymentId == null || res.signature == null) {
      debugPrint("❌ Invalid payment response (null values)");

      state = state.copyWith(
        isLoading: false,
        error: "Invalid payment response",
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      debugPrint("🚀 Creating VerifyPaymentReqModel...");

      final verifyReq = VerifyPaymentReqModel(
        paymentMethod: "ONLINE",
        deliveryFee: deliveryFee,
        address: address,
        items: items,
        couponCode: couponCode,
        razorpayOrderId: res.orderId!,
        razorpayPaymentId: res.paymentId!,
        razorpaySignature: res.signature!,
        panditId: panditId,
      );

      debugPrint("📤 Verify Request JSON:");
      debugPrint("${verifyReq.toJson()}");

      debugPrint("🌐 Calling verifyPayment API...");

      final success = await _repo.productVerifyPayment(verifyReq);

      debugPrint("📥 Verify API Response: $success");

      if (success) {
        debugPrint("✅ PAYMENT VERIFIED SUCCESSFULLY");
      } else {
        debugPrint("❌ PAYMENT VERIFICATION FAILED");
      }

      state = state.copyWith(
        isLoading: false,
        isSuccess: success,
        error: success ? null : "Verification failed",
      );
    } catch (e, stack) {
      debugPrint("🔥 EXCEPTION DURING PAYMENT VERIFICATION");
      debugPrint("❌ Error: $e");
      debugPrint("📍 StackTrace: $stack");

      state = state.copyWith(isLoading: false, error: _userFriendlyError(e));
    }
  }

  // ❌ ERROR
  void _handleError(PaymentFailureResponse res) {
    final message = (res.message != null && res.message!.isNotEmpty)
        ? res.message
        : "Payment failed";
    debugPrint("❌ Error: $res");
    state = state.copyWith(isLoading: false, error: message);
  }

  String _userFriendlyError(Object error) {
    if (error is AppException && error.message.trim().isNotEmpty) {
      if (error.message.toLowerCase().contains('multiple vendors')) {
        return "Products from different sellers cannot be ordered together. Please keep products from one seller in your cart.";
      }
      return error.message.trim();
    }
    return "Something went wrong. Please try again.";
  }
}
