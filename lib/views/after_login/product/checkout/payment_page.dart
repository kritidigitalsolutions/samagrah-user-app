// view/after_login/checkout/payment/payment_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/data/exception/app_exception.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/repo/payment_repo.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/payment_provider.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/state/payment_state.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/coupon_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/wallet_provider.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  String selectedPaymentMethod = 'online';
  num walletBalance = 0.0;

  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(paymentProvider.notifier).init();
  }

  void _showSafeSnackbar(String message, SnackBarType type) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppSnackbar.show(context, message: message, type: type);
    });
  }

  String _checkoutErrorMessage(Object error) {
    final message = error is AppException ? error.message : error.toString();
    if (message.toLowerCase().contains('multiple vendors')) {
      return "Products from different sellers cannot be ordered together. Please keep products from one seller in your cart.";
    }
    return message.trim().isEmpty
        ? "Something went wrong. Please try again."
        : message.trim();
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final couponState = ref.watch(couponProvider);

    // ── Listeners ────────────────────────────────────────────────────────────
    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (!mounted) return;
      if (next.error?.isNotEmpty == true && next.error != previous?.error) {
        _showSafeSnackbar(next.error!, SnackBarType.error);
      }
      if (next.isSuccess) {
        _showSafeSnackbar("Payment Successful 🎉", SnackBarType.success);
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) Navigator.pushNamed(context, AppRoutes.successPage);
        });
      }
    });

    ref.listen<CouponState>(couponProvider, (previous, next) {
      if (!mounted) return;
      if (next.isApplySuccess && !(previous?.isApplySuccess ?? false)) {
        _showSafeSnackbar(
          "Coupon applied! You saved ₹${next.discountAmount.toStringAsFixed(0)} 🎉",
          SnackBarType.success,
        );
        FocusScope.of(context).unfocus();
      }
      if (next.applyError?.isNotEmpty == true &&
          next.applyError != previous?.applyError) {
        _showSafeSnackbar(next.applyError!, SnackBarType.error);
      }
    });

    final address = ref.watch(storeAddressProvider);
    final panditId = ref.watch(panditIdProvider);
    final items = ref.watch(bookingItemProvider);
    final totalAmount = ref.watch(totalPriceProvider); // 200 — items only

    // ✅ Delivery HAMESHA raw items pe — coupon ke baad nahi
    final deliveryChargeAsync = ref.watch(
      resolvedDeliveryChargeProvider(totalAmount.toDouble()),
    );

    final resolvedDeliveryCharge = deliveryChargeAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0.0,
    );
    final codChargeAsync = ref.watch(resolvedCodChargeProvider);
    final resolvedCodCharge = codChargeAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0.0,
    );

    // ✅ Grand total ek jagah calculate
    final grandTotal = couponState.isCouponApplied
        ? couponState
              .finalAmount // server: (200+40) - 24 = 216
        : totalAmount + resolvedDeliveryCharge; // 200 + 40 = 240

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
                    // ── Delivery Charge Info Banner ───────────────────────
                    _buildDeliveryChargeBanner(
                      totalAmount.toDouble(),
                      deliveryChargeAsync,
                    ),
                    const SizedBox(height: 16),

                    _buildPriceBreakdown(
                      totalAmount,
                      couponState,
                      resolvedDeliveryCharge,
                      resolvedCodCharge,
                    ),
                    const SizedBox(height: 20),

                    _buildCouponSection(
                      totalAmount,
                      couponState,
                      resolvedDeliveryCharge,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      "Payment Methods",
                      style: text16(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    walletAsync.when(
                      data: (data) {
                        final amount = data.data?.wallet?.balance;
                        walletBalance = amount ?? 0.0;
                        return _buildWalletOption(grandTotal);
                      },
                      loading: () => const _ShimmerBox(height: 140),
                      error: (_, _) =>
                          _ErrorText(message: "Offers load nahi ho paye"),
                    ),
                    const SizedBox(height: 12),
                    _buildOnlineMethods(),
                    const SizedBox(height: 12),
                    _buildCODOption(resolvedCodCharge),
                    if (selectedPaymentMethod == 'cod') ...[
                      const SizedBox(height: 12),
                      _buildCODChargesInfo(
                        resolvedDeliveryCharge,
                        resolvedCodCharge,
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(
              grandTotal,
              address,
              items,
              couponState,
              panditId,
              resolvedDeliveryCharge,
              resolvedCodCharge,
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // DELIVERY CHARGE BANNER
  // ──────────────────────────────────────────────────────────────────────────

  /// Shows a contextual banner:
  ///  - Loading  → shimmer
  ///  - Error    → error chip
  ///  - FREE     → green "Free Delivery" badge
  ///  - Charged  → amber "Add ₹X more for free delivery" nudge
  Widget _buildDeliveryChargeBanner(
    double orderAmount,
    AsyncValue<double> chargeAsync,
  ) {
    return chargeAsync.when(
      loading: () => const _ShimmerBox(height: 52),
      error: (_, _) => const SizedBox.shrink(),
      data: (charge) {
        final isFree = charge == 0.0;
        final remaining = kFreeDeliveryThreshold - orderAmount;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: isFree
              ? _DeliveryBadge(
                  key: const ValueKey('free'),
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppColors.green,
                  backgroundColor: AppColors.green,
                  label: "Free Delivery on this order 🎉",
                )
              : _DeliveryBadge(
                  key: const ValueKey('charged'),
                  icon: Icons.info_outline,
                  iconColor: AppColors.warning,
                  backgroundColor: AppColors.warning,
                  label:
                      "Add ₹${remaining.toStringAsFixed(0)} more for FREE delivery  •  Delivery: ₹${charge.toStringAsFixed(0)}",
                ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COUPON SECTION
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCouponSection(
    num totalAmount,
    CouponState couponState,
    double deliveryCharge,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Coupons & Offers", style: text16(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        couponState.isCouponApplied
            ? _buildAppliedCouponBanner(couponState)
            : _buildCouponInputCard(totalAmount, couponState, deliveryCharge),
        if (!couponState.isCouponApplied) ...[
          const SizedBox(height: 12),
          _buildAvailableOffers(totalAmount, couponState),
        ],
      ],
    );
  }

  Widget _buildCouponInputCard(
    num totalAmount,
    CouponState couponState,
    double deliveryCharge,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              const Icon(
                Icons.local_offer_outlined,
                color: AppColors.button,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Have a coupon?",
                style: text14(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter coupon code",
                    hintStyle: text13(color: AppColors.grey600),
                    filled: true,
                    fillColor: AppColors.grey100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: AppColors.button,
                        width: 1.5,
                      ),
                    ),
                  ),
                  style: text14(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: couponState.isApplying
                      ? null
                      : () => _applyManualCoupon(totalAmount, deliveryCharge),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    elevation: 0,
                  ),
                  child: couponState.isApplying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "APPLY",
                          style: text13(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppliedCouponBanner(CouponState couponState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.green.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green.withAlpha(80), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.green.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${couponState.appliedCode} Applied!",
                  style: text14(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "You saved ₹${couponState.discountAmount.toStringAsFixed(0)} on this order",
                  style: text12(color: AppColors.green),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(couponProvider.notifier).removeCoupon();
              _couponController.clear();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withAlpha(60)),
              ),
              child: Text(
                "REMOVE",
                style: text11(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableOffers(num totalAmount, CouponState couponState) {
    if (couponState.isLoading) return const _ShimmerBox(height: 90);
    if (couponState.coupon.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final validOffers = couponState.coupon.where((c) {
      final active = c.isActive ?? false;
      final started = c.startsAt == null || now.isAfter(c.startsAt!);
      final notExpired = c.expiresAt == null || now.isBefore(c.expiresAt!);
      return active && started && notExpired;
    }).toList();

    if (validOffers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Available Offers",
          style: text13(color: AppColors.grey700, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: validOffers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) =>
                _buildOfferChip(validOffers[i], totalAmount),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferChip(CouponData coupon, num totalAmount) {
    final eligible = totalAmount >= (coupon.minOrderAmount ?? 0);
    final discountLabel = (coupon.discountType ?? '').toLowerCase() == 'percent'
        ? '${(coupon.discountValue ?? 0).toInt()}% OFF'
        : '₹${(coupon.discountValue ?? 0).toInt()} OFF';

    int? daysLeft;
    if (coupon.expiresAt != null) {
      final diff = coupon.expiresAt!.difference(DateTime.now()).inDays;
      daysLeft = diff < 0 ? 0 : diff;
    }

    return GestureDetector(
      onTap: eligible ? () => _couponController.text = coupon.code ?? '' : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 220,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: eligible ? AppColors.white : AppColors.grey100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: eligible
                ? AppColors.button.withAlpha(80)
                : AppColors.grey300,
          ),
          boxShadow: eligible
              ? [
                  BoxShadow(
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    color: AppColors.button.withOpacity(0.08),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: eligible ? AppColors.button : AppColors.grey400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    discountLabel,
                    style: text11(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (daysLeft != null)
                  Text(
                    daysLeft == 0 ? "Expired" : "$daysLeft days left",
                    style: text10(
                      color: daysLeft <= 3
                          ? AppColors.warning
                          : AppColors.grey600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      coupon.code ?? '',
                      style: text13(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            if ((coupon.title ?? '').isNotEmpty)
              Text(
                coupon.title ?? '',
                style: text11(
                  color: AppColors.button,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if ((coupon.description ?? '').isNotEmpty)
              Text(
                coupon.description ?? '',
                style: text11(color: AppColors.grey700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 2),
            if ((coupon.usageLimit ?? 0) > 0)
              _buildCouponInfoRow(
                title: "Usage Limit",
                value: "${coupon.usageLimit}",
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponInfoRow({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text10(color: AppColors.grey600)),
          Text(value, style: text10(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  void _applyManualCoupon(num totalAmount, double deliveryCharge) {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      AppSnackbar.show(
        context,
        message: "Please enter a coupon code",
        type: SnackBarType.error,
      );
      return;
    }

    // ✅ Delivery loaded hai ya nahi check karo
    if (deliveryCharge == 0.0) {
      // Provider still loading ho sakta hai — raw totalAmount use karo fallback
      // Ya user ko wait karo
    }

    final grandTotal = totalAmount + deliveryCharge;
    debugPrint('Applying coupon on grand total: $grandTotal');

    ref
        .read(couponProvider.notifier)
        .applyCoupon(
          code: code,
          amount: grandTotal, // ✅ 240
        );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // STEPPER
  // ──────────────────────────────────────────────────────────────────────────

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

  // ──────────────────────────────────────────────────────────────────────────
  // PRICE BREAKDOWN  (now accepts resolvedDeliveryCharge)
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildPriceBreakdown(
    num totalAmount,
    CouponState couponState,
    double deliveryCharge,
    double codCharge,
  ) {
    final isCOD = selectedPaymentMethod == 'cod';
    final grandTotal = couponState.isCouponApplied
        ? couponState.finalAmount + (isCOD ? codCharge : 0)
        : totalAmount + deliveryCharge + (isCOD ? codCharge : 0);

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
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, size: 20),
              const SizedBox(width: 8),
              Text("Bill Details", style: text14(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),

          _buildPriceRow("Item Total", "₹$totalAmount", false),

          // Coupon discount row
          if (couponState.isCouponApplied) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "Coupon (${couponState.appliedCode})",
                      style: text13(color: AppColors.green),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.local_offer,
                      color: AppColors.green,
                      size: 14,
                    ),
                  ],
                ),
                Text(
                  "- ₹${couponState.discountAmount.toStringAsFixed(2)}",
                  style: text14(
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Delivery charge row
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 14,
                    color: AppColors.grey700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Delivery Charges",
                    style: text13(color: AppColors.grey700),
                  ),
                ],
              ),
              deliveryCharge == 0.0
                  ? Row(
                      children: [
                        Text(
                          "FREE",
                          style: text13(
                            color: AppColors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      "₹${deliveryCharge.toStringAsFixed(2)}",
                      style: text14(fontWeight: FontWeight.w600),
                    ),
            ],
          ),

          if (isCOD) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              "COD Charges",
              "₹${codCharge.toStringAsFixed(2)}",
              false,
            ),
          ],

          const Divider(height: 24),
          _buildPriceRow(
            "Total Amount",
            "₹${grandTotal.toStringAsFixed(2)}",
            true,
          ),

          const SizedBox(height: 12),
          Builder(
            builder: (_) {
              final savedAmount = couponState.isCouponApplied
                  ? couponState.discountAmount.toDouble()
                  : 0.0;
              if (savedAmount <= 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
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
                        "You're saving ₹${savedAmount.toStringAsFixed(2)} on this order",
                        style: text12(
                          color: AppColors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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

  // ──────────────────────────────────────────────────────────────────────────
  // WALLET
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildWalletOption(num totalAmount) {
    final isSelected = selectedPaymentMethod == 'wallet';
    final canPayWithWallet = walletBalance >= totalAmount;

    return GestureDetector(
      onTap: () {
        if (canPayWithWallet) {
          setState(() => selectedPaymentMethod = 'wallet');
        } else {
          Navigator.pushNamed(context, AppRoutes.myWallet);
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

  // ──────────────────────────────────────────────────────────────────────────
  // ONLINE METHODS
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildOnlineMethods() {
    final isSelected = selectedPaymentMethod == 'online';

    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = 'online'),
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
        errorBuilder: (_, _, _) =>
            const Icon(Icons.payment, size: 20, color: AppColors.grey600),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COD
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCODOption(double codCharge) {
    final isSelected = selectedPaymentMethod == 'cod';
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = 'cod'),
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
                    codCharge > 0
                        ? "Extra ₹${codCharge.toStringAsFixed(0)} COD charges apply"
                        : "No extra charges",
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

  Widget _buildCODChargesInfo(double deliveryCharge, double codCharge) {
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
                  deliveryCharge > 0
                      ? "Delivery charges (₹${deliveryCharge.toStringAsFixed(0)}) and COD handling fee (₹${codCharge.toStringAsFixed(0)}) will be added."
                      : codCharge > 0
                      ? "COD handling fee (₹${codCharge.toStringAsFixed(0)}) will be added to your total."
                      : "No additional charges for this order.",
                  style: text11(color: AppColors.grey700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // BOTTOM CTA
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBottomCTA(
    num effectiveTotal,
    Address? address,
    List<VerifyItem> items,
    CouponState couponState,
    String panditId,
    double deliveryCharge,
    double codCharge,
  ) {
    final paymentState = ref.watch(paymentProvider);
    final loading = ref.watch(loadingProvider);

    final finalAmount = couponState.isCouponApplied
        ? couponState.finalAmount +
              (selectedPaymentMethod == 'cod' ? codCharge : 0)
        : effectiveTotal + (selectedPaymentMethod == 'cod' ? codCharge : 0);

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
          title: loading ? "Placing Order..." : buttonText,
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
                  if (items.isEmpty ||
                      effectiveTotal <= 0 ||
                      items.any(
                        (item) =>
                            item.productId.isEmpty || item.quantity <= 0,
                      )) {
                    AppSnackbar.show(
                      context,
                      message: "Add a valid product before placing the order",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  try {
                    if (selectedPaymentMethod == 'cod') {
                    ref.read(loadingProvider.notifier).state = true;
                    final repo = PaymentRepo();

                    final createReq = CreateOrderReqModel(
                      deliveryFee: deliveryCharge,
                      codCharge: codCharge,
                      items: items,
                      couponCode: couponState.appliedCode,
                      panditId: panditId,
                    );

                    final orderRes = await repo.productCreateOrder(createReq);

                    if (orderRes.data == null) {
                      ref.read(loadingProvider.notifier).state = false;
                      AppSnackbar.show(
                        context,
                        message: "Failed to create order",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    final orderId = orderRes.data?.razorpayOrder?.id;
                    if (orderId == null || orderId.isEmpty) {
                      ref.read(loadingProvider.notifier).state = false;
                      AppSnackbar.show(
                        context,
                        message: "Invalid Order ID",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    final verifyReq = VerifyPaymentReqModel(
                      paymentMethod: "COD",
                      deliveryFee: deliveryCharge,
                      codCharge: codCharge,
                      address: address,
                      items: items,
                      couponCode: couponState.appliedCode,
                      panditId: panditId,
                      razorpayOrderId: orderId,
                    );
                    final success = await repo.productVerifyPayment(verifyReq);
                    ref.read(loadingProvider.notifier).state = false;
                    if (success && mounted) {
                      Navigator.pushNamed(context, AppRoutes.successPage);
                    }
                    } else if (selectedPaymentMethod == 'wallet') {
                    if (walletBalance >= effectiveTotal) {
                      ref.read(loadingProvider.notifier).state = true;
                      final repo = PaymentRepo();
                      final createReq = CreateOrderReqModel(
                        deliveryFee: deliveryCharge,
                        items: items,
                        couponCode: couponState.appliedCode,
                        panditId: panditId,
                      );

                      final orderRes = await repo.productCreateOrder(createReq);

                      if (orderRes.data == null) {
                        ref.read(loadingProvider.notifier).state = false;
                        AppSnackbar.show(
                          context,
                          message: "Failed to create order",
                          type: SnackBarType.error,
                        );
                        return;
                      }

                      final orderId = orderRes.data?.razorpayOrder?.id;
                      if (orderId == null || orderId.isEmpty) {
                        ref.read(loadingProvider.notifier).state = false;
                        AppSnackbar.show(
                          context,
                          message: "Invalid Order ID",
                          type: SnackBarType.error,
                        );
                        return;
                      }

                      final verifyReq = VerifyPaymentReqModel(
                        paymentMethod: "WALLET",
                        deliveryFee: deliveryCharge,
                        walletAmount: walletBalance,
                        address: address,
                        items: items,
                        couponCode: couponState.appliedCode,
                        panditId: panditId,
                        razorpayOrderId: orderId,
                      );
                      final success = await repo.productVerifyPayment(
                        verifyReq,
                      );
                      ref.read(loadingProvider.notifier).state = false;
                      if (success && mounted) {
                        Navigator.pushNamed(context, AppRoutes.successPage);
                      }
                    } else {
                      AppSnackbar.show(
                        context,
                        message: "Insufficient wallet balance",
                        type: SnackBarType.error,
                      );
                    }
                    } else {
                      await ref
                          .read(paymentProvider.notifier)
                          .startPayment(
                            address,
                            items,
                            couponState.appliedCode ?? '',
                            panditId,
                            deliveryCharge,
                          );
                    }
                  } catch (error) {
                    ref.read(loadingProvider.notifier).state = false;
                    if (mounted) {
                      AppSnackbar.show(
                        context,
                        message: _checkoutErrorMessage(error),
                        type: SnackBarType.error,
                      );
                    }
                  }
                },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// DELIVERY BADGE  (reusable)
// ──────────────────────────────────────────────────────────────────────────

class _DeliveryBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String label;

  const _DeliveryBadge({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// HELPERS
// ──────────────────────────────────────────────────────────────────────────

class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.button,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(message, style: TextStyle(color: AppColors.error)),
      ),
    );
  }
}
