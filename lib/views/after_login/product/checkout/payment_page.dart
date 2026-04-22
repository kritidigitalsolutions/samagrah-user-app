import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/payment_provider.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/state/payment_state.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  bool isCashOnDelivery = false;

  @override
  void initState() {
    super.initState();
    ref.read(paymentProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      // 🔥 VERY IMPORTANT
      if (!mounted) return;

      // ❌ Error Snackbar
      if (next.error != null && next.error!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          AppSnackbar.show(
            context,
            message: next.error!,
            type: SnackBarType.error,
          );
        });
      }

      // ✅ Success
      if (next.isSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          AppSnackbar.show(
            context,
            message: "Payment Successful 🎉",
            type: SnackBarType.success,
          );

          Navigator.pushNamed(context, AppRoutes.successPage);
        });
      }
    });
    final address = ref.read(storeAddressProvider);
    final items = ref.watch(bookingItemProvider);
    final totalAmount = ref.read(totalPrice);

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Column(
          children: [
            _buildStepper(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTotalCard(totalAmount),
                    const SizedBox(height: 20),
                    _buildOnlineMethods(),
                    const SizedBox(height: 16),
                    _buildCODOption(),
                  ],
                ),
              ),
            ),

            _buildBottomCTA(totalAmount, address, items),
          ],
        ),
      ),
    );
  }

  // 🔝 MODERN STEPPER
  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, 'Item\nSummary', true),
          _buildStepConnector(isActive: true),
          _buildStep(2, 'Delivery\nAddress', true),
          _buildStepConnector(isActive: true),
          _buildStep(3, 'Payment\nMethod', true),
        ],
      ),
    );
  }

  Widget _buildStep(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.button : AppColors.grey300,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: text14(
                color: isActive ? AppColors.white : AppColors.grey600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: text10(color: isActive ? AppColors.black : AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.button : AppColors.grey300,
      ),
    );
  }

  // 💰 TOTAL CARD (MODERN)
  Widget _buildTotalCard(num totalAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: AppColors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Label
          Text(
            "Total Payable",
            style: text13(
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 6),

          // 💰 Price (Primary Focus)
          Text(
            "₹$totalAmount",
            style: text24(
              fontWeight: FontWeight.w700,
            ).copyWith(letterSpacing: 0.5),
          ),

          const SizedBox(height: 18),

          // 🔸 Available Section (Secondary)
          Text(
            "Available on",
            style: text13(
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          // 💳 Payment Icons
          Row(
            children: [
              _paymentIcon('assets/gPay.png'),
              _paymentIcon('assets/paytm.png'),
              _paymentIcon('assets/phonePe.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentIcon(String path) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(path, height: 22),
    );
  }

  // 💳 ONLINE METHODS CARD
  Widget _buildOnlineMethods() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCashOnDelivery
            ? AppColors.white
            : AppColors.green.withAlpha(50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCashOnDelivery ? AppColors.grey300 : AppColors.green,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.flash_on, color: AppColors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Pay Online (Recommended)",
              style: text14(fontWeight: FontWeight.w600),
            ),
          ),
          if (!isCashOnDelivery)
            const Icon(Icons.check_circle, color: AppColors.green),
        ],
      ),
    );
  }

  // 💵 COD OPTION
  Widget _buildCODOption() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isCashOnDelivery = !isCashOnDelivery;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCashOnDelivery
              ? AppColors.button.withAlpha(20)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCashOnDelivery ? AppColors.button : AppColors.grey300,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Cash on Delivery",
                style: text14(fontWeight: FontWeight.w600),
              ),
            ),
            if (isCashOnDelivery)
              const Icon(Icons.check_circle, color: AppColors.button),
          ],
        ),
      ),
    );
  }

  // 🚀 BOTTOM CTA (MODERN FIXED BUTTON)
  Widget _buildBottomCTA(
    num totalAmount,
    Address? address,
    List<VerifyItem> items,
  ) {
    final paymentState = ref.watch(paymentProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: AppColors.black.withOpacity(0.05)),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          height: 50,
          isLoading: paymentState.isLoading,
          title: paymentState.isLoading
              ? "Processing..."
              : isCashOnDelivery
              ? "Place Order"
              : "Pay ₹$totalAmount",

          color: isCashOnDelivery ? AppColors.button : AppColors.green,

          // 🔥 Disable tap while loading
          onTap: paymentState.isLoading
              ? null
              : () async {
                  if (address == null) {
                    AppSnackbar.show(
                      context,
                      message: "Address not found",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  if (items.isEmpty) {
                    AppSnackbar.show(
                      context,
                      message: "No items found",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  if (isCashOnDelivery) {
                    Navigator.pushNamed(context, AppRoutes.successPage);
                  } else {
                    await ref
                        .read(paymentProvider.notifier)
                        .startPayment(address, items);
                  }
                },

          // 👉 OPTIONAL: show loader inside button
        ),
      ),
    );
  }
}
