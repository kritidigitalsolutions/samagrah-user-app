// pandit_payment_booking_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';
import 'package:samagrah/repo/payment_repo.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

final panditRepoProvider = Provider((ref) => PanditRepo());

final slotPriceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(panditRepoProvider);
  return repo.getPrice();
});

// // Payment State
enum PaymentStatus { idle, loading, success, failed }

class PaymentState {
  final PaymentStatus status;
  final String? orderId;
  final String? paymentId;
  final String? signature;
  final String? errorMessage;

  PaymentState({
    this.status = PaymentStatus.idle,
    this.orderId,
    this.paymentId,
    this.signature,
    this.errorMessage,
  });

  bool get isLoading => status == PaymentStatus.loading;

  PaymentState copyWith({
    PaymentStatus? status,
    String? orderId,
    String? paymentId,
    String? signature,
    String? errorMessage,
  }) {
    return PaymentState(
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      paymentId: paymentId ?? this.paymentId,
      signature: signature ?? this.signature,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Provider
final panditPaymentBookingProvider =
    StateNotifierProvider<PanditPaymentBookingNotifier, PaymentState>((ref) {
      return PanditPaymentBookingNotifier();
    });

class PanditPaymentBookingNotifier extends StateNotifier<PaymentState> {
  PanditPaymentBookingNotifier() : super(PaymentState());

  final _repo = PaymentRepo();
  Razorpay? _razorpay;
  String? _currentBookingId;

  /// Initialize Razorpay
  void initializeRazorpay(BuildContext context) {
    debugPrint("🟡 Initializing Razorpay...");

    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) {
      _handlePaymentSuccess(response, context);
    });
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
      _handlePaymentError(response, context);
    });
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
      _handleExternalWallet(response, context);
    });
  }

  /// Dispose Razorpay
  void disposeRazorpay() {
    _razorpay?.clear();
  }

  /// Create Order and Open Razorpay
  Future<void> createOrderAndPay({
    required BuildContext context,
    required PanditCreateOrderReqModel model,
  }) async {
    if (state.isLoading) return;
    try {
      debugPrint("🚀 Creating Order...");
      debugPrint("📦 Request: ${model.toJson()}");
      state = state.copyWith(status: PaymentStatus.loading);

      /// ✅ CALL API WITH MODEL
      final response = await _repo.panditCreateOrder(model);

      debugPrint("📥 Full Response: ${jsonEncode(response)}");

      /// ✅ VALIDATION
      if (response["success"] != true || response["data"] == null) {
        throw Exception("Failed to create order");
      }

      final data = response["data"];

      final payment = data["booking"]?["payment"];

      if (payment == null) {
        throw Exception("Payment data not found");
      }

      final String orderId = payment["razorpayOrderId"] ?? "";
      //final String bookingId = data["_id"];
      final String bookingId = data["booking"]?["_id"];
      final double amount = model.price.toDouble();

      debugPrint("🧾 OrderId: $orderId");
      debugPrint("📌 BookingId: $bookingId");
      debugPrint("💰 Amount: $amount");

      /// ✅ SAVE IN STATE
      state = state.copyWith(orderId: orderId);

      /// 👉 Store bookingId (needed for verify)
      _currentBookingId = bookingId;

      final user = await AuthLocalstorageService.getUser();
      debugPrint("👤 User: $user");

      final contact = user?["phone"] ?? "";
      final email = user?["email"] ?? "";
      final name = user?["name"] ?? "";

      /// ✅ OPEN RAZORPAY
      ///
      state = state.copyWith(status: PaymentStatus.idle);
      _openRazorpay(
        orderId: orderId,
        amount: amount,
        userName: name ?? "User",
        userEmail: email ?? "user@email.com",
        userPhone: contact ?? "9999999999",
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );

      if (context.mounted) {
        print(e.toString());
        AppSnackbar.show(
          context,
          message: "Order Creation Failed: ${e.toString()}",
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Open Razorpay Payment Gateway
  void _openRazorpay({
    required String orderId,
    required double amount,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) {
    state = state.copyWith(status: PaymentStatus.idle);
    var options = {
      'key': 'rzp_test_ScAfkfdSrrcuVo', // Replace with your Razorpay Key
      'amount': (amount * 100).toInt(), // Amount in paise
      'order_id': orderId,
      'name': 'Samagrah',
      'description': 'Pandit Booking Payment',
      'prefill': {'contact': userPhone, 'email': userEmail, 'name': userName},
      'theme': {'color': '#E91E63'},
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: 'Failed to open payment gateway',
      );
    }
  }

  /// Handle Payment Success
  void _handlePaymentSuccess(
    PaymentSuccessResponse response,
    BuildContext context,
  ) async {
    debugPrint("🎉 PAYMENT SUCCESS");
    debugPrint("PaymentId: ${response.paymentId}");
    debugPrint("OrderId: ${response.orderId}");
    debugPrint("Signature: ${response.signature}");

    // Update state
    state = state.copyWith(
      paymentId: response.paymentId,
      signature: response.signature,
    );

    // Verify Payment
    await _verifyPayment(
      bookingId: _currentBookingId ?? '',
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
      context: context,
    );
  }

  /// Handle Payment Error
  void _handlePaymentError(
    PaymentFailureResponse response,
    BuildContext context,
  ) {
    debugPrint("❌ PAYMENT FAILED");
    debugPrint("Code: ${response.code}");
    debugPrint("Message: ${response.message}");

    state = state.copyWith(
      status: PaymentStatus.failed,
      errorMessage: response.message ?? 'Payment failed',
    );

    if (context.mounted) {
      AppSnackbar.show(
        context,
        message: 'Payment Failed: ${response.message}',
        type: SnackBarType.error,
      );

      // Show error dialog
      _showPaymentFailedDialog(context, response.message ?? 'Payment failed');
    }
  }

  /// Handle External Wallet
  void _handleExternalWallet(
    ExternalWalletResponse response,
    BuildContext context,
  ) {
    debugPrint('External Wallet: ${response.walletName}');

    if (context.mounted) {
      AppSnackbar.show(
        context,
        message: 'External Wallet: ${response.walletName}',
        type: SnackBarType.info,
      );
    }
  }

  /// Verify Payment API
  Future<void> _verifyPayment({
    required String bookingId,
    required String paymentId,
    required String orderId,
    required String signature,
    required BuildContext context,
  }) async {
    try {
      debugPrint("🔍 Verifying Payment...");
      debugPrint("BookingId: $bookingId");
      state = state.copyWith(status: PaymentStatus.loading);

      final response = await _repo.panditVerifyPayment(
        id: bookingId,
        razorpayOrderId: orderId,
        paymentId: paymentId,
        razorpaySignature: signature,
      );

      if (response == true) {
        state = state.copyWith(status: PaymentStatus.success);

        if (context.mounted) {
          AppSnackbar.show(
            context,
            message: 'Payment Successful!',
            type: SnackBarType.success,
          );

          // Show success dialog
          Navigator.pushNamed(context, AppRoutes.panditPayment);
        }
      } else {
        throw Exception('Payment verification failed');
      }
    } catch (e) {
      debugPrint('Verify Payment Error: $e');

      state = state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: e.toString(),
      );

      if (context.mounted) {
        AppSnackbar.show(
          context,
          message: 'Verification Failed: ${e.toString()}',
          type: SnackBarType.error,
        );

        _showPaymentFailedDialog(context, e.toString());
      }
    }
  }

  /// Show Payment Failed Dialog
  void _showPaymentFailedDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Payment Failed',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Error Message
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    // Cancel
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Retry
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Trigger retry payment
                          // You can call createOrderAndPay again here
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE91E63),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Reset state
  void resetPaymentState() {
    state = PaymentState();
  }
}
