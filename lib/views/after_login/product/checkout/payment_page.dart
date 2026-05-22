// view/after_login/checkout/payment/payment_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  final double codCharges = 25.00;
  final double shippingCharges = 40.00;

  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(paymentProvider.notifier).init();
  }

  // Safe Snackbar Helper
  void _showSafeSnackbar(String message, SnackBarType type) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppSnackbar.show(context, message: message, type: type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(walletProvider);
    final couponState = ref.watch(couponProvider);

    // ── Payment success / error listener ─────────────────────────────────────
    ref.listen<PaymentState>(paymentProvider, (previous, next) {
      if (!mounted) return;

      if (next.error?.isNotEmpty == true) {
        _showSafeSnackbar(next.error!, SnackBarType.error);
      }

      if (next.isSuccess) {
        _showSafeSnackbar("Payment Successful 🎉", SnackBarType.success);

        // Increased delay to make sure navigation works
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            Navigator.pushNamed(context, AppRoutes.successPage);
          }
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
    final items = ref.watch(bookingItemProvider);
    final totalAmount = ref.watch(totalPriceProvider);

    final effectiveTotal = couponState.isCouponApplied
        ? couponState.finalAmount
        : totalAmount;

    // final validCoupons = couponState.coupon.where((coupon) {
    //   final usageLeft = (coupon.usageLimit ?? 0) > (coupon.usedCount ?? 0);

    //   final perUserAvailable = (coupon.perUserLimit ?? 0) > 0;

    //   final isNotExpired = coupon.expiresAt == null
    //       ? true
    //       : coupon.expiresAt!.isAfter(DateTime.now());

    //   return usageLeft && perUserAvailable && isNotExpired;
    // }).toList();

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
                    _buildPriceBreakdown(totalAmount, couponState),
                    const SizedBox(height: 20),

                    _buildCouponSection(totalAmount, couponState),
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
                        return _buildWalletOption(effectiveTotal);
                      },
                      loading: () => const _ShimmerBox(height: 140),
                      error: (_, _) =>
                          _ErrorText(message: "Offers load nahi ho paye"),
                    ),
                    const SizedBox(height: 12),
                    _buildOnlineMethods(),
                    const SizedBox(height: 12),
                    _buildCODOption(),
                    if (selectedPaymentMethod == 'cod') ...[
                      const SizedBox(height: 12),
                      _buildCODChargesInfo(),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            _buildBottomCTA(effectiveTotal, address, items, couponState),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COUPON SECTION
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildCouponSection(num totalAmount, CouponState couponState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Coupons & Offers", style: text16(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        couponState.isCouponApplied
            ? _buildAppliedCouponBanner(couponState)
            : _buildCouponInputCard(totalAmount, couponState),
        if (!couponState.isCouponApplied) ...[
          const SizedBox(height: 12),
          _buildAvailableOffers(totalAmount, couponState),
        ],
      ],
    );
  }

  Widget _buildCouponInputCard(num totalAmount, CouponState couponState) {
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
                      : () => _applyManualCoupon(totalAmount),
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

  /// Horizontally scrollable offer chips — uses new CouponData fields
  Widget _buildAvailableOffers(num totalAmount, CouponState couponState) {
    if (couponState.isLoading) return const _ShimmerBox(height: 90);
    if (couponState.coupon.isEmpty) return const SizedBox.shrink();

    // Filter: active + not expired
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

  /// Chip card for each offer — tapping fills the code field and auto-applies
  Widget _buildOfferChip(CouponData coupon, num totalAmount) {
    final eligible = totalAmount >= (coupon.minOrderAmount ?? 0);

    // Discount label
    final discountLabel = (coupon.discountType ?? '').toLowerCase() == 'percent'
        ? '${(coupon.discountValue ?? 0).toInt()}% OFF'
        : '₹${(coupon.discountValue ?? 0).toInt()} OFF';

    // Expiry
    int? daysLeft;
    if (coupon.expiresAt != null) {
      final diff = coupon.expiresAt!.difference(DateTime.now()).inDays;
      daysLeft = diff < 0 ? 0 : diff;
    }

    return GestureDetector(
      onTap: eligible
          ? () {
              _couponController.text = coupon.code ?? '';
            }
          : null,
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
            // Top Row
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

            // Coupon Code
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

            // Description
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

  // Helper Widget
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

  void _applyManualCoupon(num totalAmount) {
    final code = _couponController.text.trim();
    if (code.isEmpty) {
      AppSnackbar.show(
        context,
        message: "Please enter a coupon code",
        type: SnackBarType.error,
      );
      return;
    }
    ref
        .read(couponProvider.notifier)
        .applyCoupon(code: code, amount: totalAmount);
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
  // PRICE BREAKDOWN
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildPriceBreakdown(num totalAmount, CouponState couponState) {
    final isCOD = selectedPaymentMethod == 'cod';
    final baseAmount = couponState.isCouponApplied
        ? couponState.finalAmount
        : totalAmount;
    final grandTotal = isCOD
        ? baseAmount + codCharges + shippingCharges
        : baseAmount;

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

          if (isCOD) ...[
            const SizedBox(height: 8),
            _buildPriceRow("Delivery Charges", "₹$shippingCharges", false),
            const SizedBox(height: 8),
            _buildPriceRow("COD Charges", "₹$codCharges", false),
          ],

          const Divider(height: 24),
          _buildPriceRow(
            "Total Amount",
            "₹${grandTotal.toStringAsFixed(2)}",
            true,
          ),

          if (selectedPaymentMethod != 'cod') ...[
            const SizedBox(height: 12),
            Builder(
              builder: (_) {
                final savedAmount = couponState.isCouponApplied
                    ? (codCharges + shippingCharges) +
                          couponState.discountAmount.toDouble()
                    : (codCharges + shippingCharges).toDouble();
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

  Widget _buildCODOption() {
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

  // ──────────────────────────────────────────────────────────────────────────
  // BOTTOM CTA
  // ──────────────────────────────────────────────────────────────────────────

  Widget _buildBottomCTA(
    num effectiveTotal,
    Address? address,
    List<VerifyItem> items,
    CouponState couponState,
  ) {
    final paymentState = ref.watch(paymentProvider);
    final loading = ref.watch(loadingProvider);

    final finalAmount = selectedPaymentMethod == 'cod'
        ? effectiveTotal + codCharges + shippingCharges
        : effectiveTotal;

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
                  if (items.isEmpty) {
                    AppSnackbar.show(
                      context,
                      message: "No items found",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  if (selectedPaymentMethod == 'cod') {
                    ref.read(loadingProvider.notifier).state = true;
                    final repo = PaymentRepo();
                    final verifyReq = VerifyPaymentReqModel(
                      paymentMethod: "COD",
                      deliveryFee: codCharges,
                      address: address,
                      items: items,
                      couponCode: couponState.appliedCode,
                    );
                    final success = await repo.productVerifyPayment(verifyReq);
                    ref.read(loadingProvider.notifier).state = false;
                    if (success) {
                      Navigator.pushNamed(context, AppRoutes.successPage);
                    }
                  } else if (selectedPaymentMethod == 'wallet') {
                    if (walletBalance >= effectiveTotal) {
                      ref.read(loadingProvider.notifier).state = true;
                      final repo = PaymentRepo();
                      final verifyReq = VerifyPaymentReqModel(
                        paymentMethod: "WALLET",
                        deliveryFee: codCharges,
                        walletAmount: walletBalance,
                        address: address,
                        items: items,
                        couponCode: couponState.appliedCode,
                      );
                      final success = await repo.productVerifyPayment(
                        verifyReq,
                      );
                      ref.read(loadingProvider.notifier).state = false;
                      if (success) {
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
                        );
                  }
                },
        ),
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
        child: Text(message, style: text13(color: AppColors.error)),
      ),
    );
  }
}
