import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/repo/payment_repo.dart';
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
  String selectedPaymentMethod = 'online'; // 'online', 'wallet', 'cod'

  // Wallet balance (you can fetch this from provider)
  final double walletBalance = 250.00;

  // COD charges
  final double codCharges = 25.00;
  final double shippingCharges = 40.00;

  @override
  void initState() {
    super.initState();
    ref.read(paymentProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PaymentState>(paymentProvider, (prev, next) {
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
    final totalAmount = ref.read(totalPriceProvider);

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPriceBreakdown(totalAmount),
                    const SizedBox(height: 20),

                    // Payment Methods Header
                    Text(
                      "Payment Methods",
                      style: text16(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),

                    // Wallet Option
                    _buildWalletOption(totalAmount),
                    const SizedBox(height: 12),

                    // Online Payment Option
                    _buildOnlineMethods(),
                    const SizedBox(height: 12),

                    // COD Option
                    _buildCODOption(),

                    // COD Charges Info
                    if (selectedPaymentMethod == 'cod') ...[
                      const SizedBox(height: 12),
                      _buildCODChargesInfo(),
                    ],
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

  // 💰 PRICE BREAKDOWN (Blinkit-style)
  Widget _buildPriceBreakdown(num totalAmount) {
    final codTotal = selectedPaymentMethod == 'cod'
        ? totalAmount + codCharges + shippingCharges
        : totalAmount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Bill Details Header
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 20),
              const SizedBox(width: 8),
              Text("Bill Details", style: text14(fontWeight: FontWeight.w600)),
            ],
          ),

          const SizedBox(height: 14),

          // Item Total
          _buildPriceRow("Item Total", "₹$totalAmount", false),

          // COD Charges (if COD selected)
          if (selectedPaymentMethod == 'cod') ...[
            const SizedBox(height: 8),
            _buildPriceRow("Delivery Charges", "₹$shippingCharges", false),
            const SizedBox(height: 8),
            _buildPriceRow("COD Charges", "₹$codCharges", false),
          ],

          const Divider(height: 24),

          // Total Amount
          _buildPriceRow(
            "Total Amount",
            "₹${codTotal.toStringAsFixed(2)}",
            true,
          ),

          // Savings Badge (if online payment)
          if (selectedPaymentMethod != 'cod') ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "You're saving ₹${(codCharges + shippingCharges).toStringAsFixed(0)} on this order",
                      style: text12(
                        color: AppColors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: text13(
            color: isBold ? AppColors.black : AppColors.grey700,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: text14(fontWeight: isBold ? FontWeight.bold : FontWeight.w600),
        ),
      ],
    );
  }

  // 💳 WALLET OPTION (New)
  Widget _buildWalletOption(num totalAmount) {
    final isSelected = selectedPaymentMethod == 'wallet';
    final canPayWithWallet = walletBalance >= totalAmount;

    return GestureDetector(
      onTap: () {
        if (canPayWithWallet) {
          setState(() {
            selectedPaymentMethod = 'wallet';
          });
        } else {
          AppSnackbar.show(
            context,
            message: "Insufficient wallet balance. Please recharge!",
            type: SnackBarType.error,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button.withAlpha(20) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.button : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.button.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.button,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Wallet",
                        style: text14(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Available Balance: ₹${walletBalance.toStringAsFixed(2)}",
                        style: text12(
                          color: canPayWithWallet
                              ? AppColors.green
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.button),
              ],
            ),

            // Insufficient Balance Warning
            if (!canPayWithWallet) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Low balance! Recharge ₹${(totalAmount - walletBalance).toStringAsFixed(2)} more",
                        style: text11(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 💳 ONLINE METHODS CARD
  Widget _buildOnlineMethods() {
    final isSelected = selectedPaymentMethod == 'online';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = 'online';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.green.withAlpha(50) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.green : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.green.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.flash_on,
                    color: AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "UPI / Cards / Netbanking",
                              style: text14(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "BEST",
                              style: text10(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Get instant confirmation",
                        style: text11(color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.green),
              ],
            ),

            // Payment Icons
            if (isSelected) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _paymentIcon('assets/gPay.png'),
                  _paymentIcon('assets/paytm.png'),
                  _paymentIcon('assets/phonePe.png'),
                  const Spacer(),
                  Text(
                    "+more",
                    style: text12(
                      color: AppColors.grey600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
        border: Border.all(color: AppColors.grey300),
      ),
      child: Image.asset(
        path,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          // Fallback icon if image fails to load
          return const Icon(Icons.payment, size: 20, color: AppColors.grey600);
        },
      ),
    );
  }

  // 💵 COD OPTION
  Widget _buildCODOption() {
    final isSelected = selectedPaymentMethod == 'cod';

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentMethod = 'cod';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.grey100 : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.payments_outlined,
                color: AppColors.black,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cash on Delivery",
                    style: text14(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Extra ₹${(codCharges + shippingCharges).toStringAsFixed(0)} charges apply",
                    style: text11(color: AppColors.grey600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.black),
          ],
        ),
      ),
    );
  }

  // 📊 COD CHARGES INFO
  Widget _buildCODChargesInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Additional Charges",
                  style: text13(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Delivery charges (₹$shippingCharges) and COD handling fee (₹$codCharges) will be added to your total.",
                  style: text11(color: AppColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🚀 BOTTOM CTA
  Widget _buildBottomCTA(
    num totalAmount,
    Address? address,
    List<VerifyItem> items,
  ) {
    final paymentState = ref.watch(paymentProvider);

    // Calculate final amount
    final finalAmount = selectedPaymentMethod == 'cod'
        ? totalAmount + codCharges + shippingCharges
        : totalAmount;

    String buttonText = "Pay ₹${finalAmount.toStringAsFixed(0)}";
    Color buttonColor = AppColors.green;

    if (paymentState.isLoading) {
      buttonText = "Processing...";
    } else if (selectedPaymentMethod == 'wallet') {
      buttonText = "Pay with Wallet";
      buttonColor = AppColors.button;
    } else if (selectedPaymentMethod == 'cod') {
      buttonText = "Place Order (₹${finalAmount.toStringAsFixed(0)})";
      buttonColor = AppColors.black;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, -2),
            color: AppColors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: AppButton(
          height: 52,
          isLoading: paymentState.isLoading,
          title: buttonText,
          color: buttonColor,
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

                  if (selectedPaymentMethod == 'cod') {
                    final PaymentRepo repo = PaymentRepo();
                    final verifyReq = VerifyPaymentReqModel(
                      paymentMethod: "COD",
                      deliveryFee: codCharges,
                      address: address,
                      items: items,
                    );

                    debugPrint("📤 Verify Request JSON:");
                    debugPrint("${verifyReq.toJson()}");

                    debugPrint("🌐 Calling verifyPayment API...");

                    final success = await repo.productVerifyPayment(verifyReq);

                    if (success) {
                      Navigator.pushNamed(context, AppRoutes.successPage);
                      debugPrint("✅ PAYMENT VERIFIED SUCCESSFULLY");
                    } else {
                      debugPrint("❌ PAYMENT VERIFICATION FAILED");
                    }
                    // COD Order
                  } else if (selectedPaymentMethod == 'wallet') {
                    // Wallet Payment
                    if (walletBalance >= totalAmount) {
                      // Process wallet payment
                      Navigator.pushNamed(context, AppRoutes.successPage);
                    } else {
                      AppSnackbar.show(
                        context,
                        message: "Insufficient wallet balance",
                        type: SnackBarType.error,
                      );
                    }
                  } else {
                    // Online Payment
                    await ref
                        .read(paymentProvider.notifier)
                        .startPayment(address, items);
                  }
                },
        ),
      ),
    );
  }
}
