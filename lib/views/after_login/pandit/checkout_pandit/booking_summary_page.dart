import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_payment_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/wallet_provider.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  ConsumerState<BookingSummaryScreen> createState() =>
      _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(panditPaymentBookingProvider.notifier)
          .initializeRazorpay(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(panditPaymentBookingProvider);
    final slotPrice = ref.watch(slotPriceProvider);
    final ritual = ref.read(selectedRitualProvider);
    final pandit = ref.read(selectedPanditProvider);
    final address = ref.read(selectedAddressProvider);
    final onlineDetails = ref.read(selectedOnlineProvider);
    final dateTimeList = ref.read(selectedDateProvider);
    final selectedService = ref.read(selectedServiceProvider);
    final templeId = ref.read(selectedTempleIdProvider);
    final useWallet = ref.watch(useWalletProvider);
    final walletAsync = ref.watch(walletProvider);

    // ✅ Read balance safely from async state — no side effects in build
    final int walletBalance =
        walletAsync.asData?.value.data?.wallet?.balance ?? 0;

    String fullAddress = '';
    if (address != null) {
      fullAddress = [
        address.fullAddress,
        address.city,
        address.state,
        address.pincode,
      ].where((e) => e != null && e.isNotEmpty).join(', ');
    }

    return Scaffold(
      backgroundColor: AppColors.headerCard,
      appBar: CustomAppBar(
        title: "Booking Summary",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/panditLogo.png',
              width: 70,
              height: 70,
              errorBuilder: (_, _, _) => Container(
                width: 70,
                height: 70,
                color: AppColors.grey500,
                child: const Icon(Icons.image),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // ── Ritual details card ──────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CustomCachedImage(
                        imageUrl: ritual?.image ?? '',
                        width: 60,
                        height: 60,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ritual?.title ?? '',
                              style: text16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (dateTimeList.isNotEmpty)
                              Column(
                                children: List.generate(dateTimeList.length, (
                                  index,
                                ) {
                                  final item = dateTimeList[index];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date - ${item['date'] ?? ''}",
                                        style: text14(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.grey500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Time - ${item['time_slot'] ?? ''}",
                                        style: text13(
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            Text(
                              fullAddress.isNotEmpty
                                  ? fullAddress
                                  : "No address selected",
                              style: text12(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Pandit card ──────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CustomCachedImage(
                        imageUrl: pandit?.profileImage ?? '',
                        width: 60,
                        height: 60,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pandit?.fullName ?? '',
                            style: text16(
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${pandit?.ratingAverage ?? 0} (${pandit?.ratingCount ?? 0}),",
                                style: text12(color: AppColors.white),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${pandit?.yearsOfExperience ?? 0} yrs exp",
                                style: text12(color: AppColors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (pandit?.languagesSpoken.isNotEmpty == true)
                            Text(
                              pandit!.languagesSpoken.join(', '),
                              style: text12(color: AppColors.white),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Booking process ──────────────────────────────────────
                Text(
                  'Booking Process',
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildProcessStep(
                  '1',
                  'After your order, receipt copy will be sent to your email.',
                  true,
                ),
                _buildProcessStep(
                  '2',
                  'Pandit Ji will review and accept your booking request.',
                  true,
                ),
                _buildProcessStep(
                  '3',
                  'You will receive confirmation shortly.',
                  true,
                ),
                const SizedBox(height: 24),

                // ── WALLET SECTION ───────────────────────────────────────
                Text(
                  'Payment Options',
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: wallet icon + balance chip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Wallet',
                                style: text15(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          // ✅ Balance chip — purely display, no side effects
                          walletAsync.when(
                            data: (data) {
                              final amount = data.data?.wallet?.balance ?? 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Balance: ₹$amount',
                                  style: text12(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                            loading: () => const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            error: (_, _) => Text(
                              'Balance unavailable',
                              style: text12(color: AppColors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Toggle row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              walletBalance > 0
                                  ? 'Use wallet balance for this payment'
                                  : 'No wallet balance available',
                              style: text13(color: AppColors.textSecondary),
                            ),
                          ),
                          Switch(
                            value: useWallet,
                            activeThumbColor: AppColors.success,
                            // ✅ Disable toggle when no balance
                            onChanged: walletBalance > 0
                                ? (val) =>
                                      ref
                                              .read(useWalletProvider.notifier)
                                              .state =
                                          val
                                : null,
                          ),
                        ],
                      ),

                      // ✅ Price breakdown — variables now properly scoped
                      if (useWallet && walletBalance > 0)
                        slotPrice.when(
                          data: (priceData) {
                            final double total = (priceData["price"] as num)
                                .toDouble();
                            final double deduction = walletBalance >= total
                                ? total
                                : walletBalance.toDouble();
                            final double remaining = total - deduction;

                            return Column(
                              children: [
                                const Divider(height: 20),
                                _buildPriceRow(
                                  'Ritual fee',
                                  '₹${total.toStringAsFixed(0)}',
                                  AppColors.textSecondary,
                                ),
                                const SizedBox(height: 6),
                                _buildPriceRow(
                                  'Wallet deduction',
                                  '- ₹${deduction.toStringAsFixed(0)}',
                                  AppColors.success,
                                ),
                                const Divider(height: 16),
                                _buildPriceRow(
                                  'To pay via Razorpay',
                                  '₹${remaining.toStringAsFixed(0)}',
                                  AppColors.textPrimary,
                                  bold: true,
                                ),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          error: (_, _) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),

                // ── END WALLET SECTION ───────────────────────────────────
                const SizedBox(height: 24),

                // ── Total amount ─────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: text18(fontWeight: FontWeight.bold),
                    ),
                    slotPrice.when(
                      data: (data) => Text(
                        '₹${data["price"]}',
                        style: text20(
                          fontWeight: FontWeight.bold,
                          color: AppColors.button,
                        ),
                      ),
                      error: (_, _) => const Text("0"),
                      loading: () => SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.button,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Payment method icons
                Row(
                  children: [
                    Image.asset(
                      'assets/gPay.png',
                      height: 24,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.payment, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/paytm.png',
                      height: 24,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.account_balance_wallet, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/phonePe.png',
                      height: 24,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.payment, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Pay button ───────────────────────────────────────────
                slotPrice.when(
                  data: (data) {
                    // ✅ walletBalance is a plain int — no .asData needed
                    final double total = (data["price"] as num).toDouble();
                    final double deduction = useWallet
                        ? (walletBalance >= total
                              ? total
                              : walletBalance.toDouble())
                        : 0.0;
                    final double toPay = total - deduction;

                    return AppButton(
                      isLoading: paymentState.isLoading,
                      title: toPay > 0
                          ? 'Pay ₹${toPay.toStringAsFixed(0)} & Request Booking'
                          : 'Confirm Booking (Wallet)',
                      onTap: () {
                        final List<DateTimeSlot> slots = dateTimeList.map((d) {
                          return DateTimeSlot(
                            date: d["date"] ?? "",
                            time: d["time_slot"] ?? "",
                          );
                        }).toList();

                        final model = PanditCreateOrderReqModel(
                          ritualId: ritual?.id ?? '',
                          bookingMode: selectedService?.type ?? '',
                          panditId: pandit?.id ?? '',
                          templeId: templeId,
                          dateAndTime: DateAndTimeWrapper(dateAndTime: slots),
                          address: Address(
                            name: address?.name ?? '',
                            phone: address?.phone ?? '',
                            fullAddress: address?.fullAddress ?? '',
                            city: address?.city ?? '',
                            state: address?.state ?? '',
                            pincode: address?.pincode ?? '',
                          ),
                          onlineDetails: onlineDetails,
                          price: toPay,
                        );

                        ref
                            .read(panditPaymentBookingProvider.notifier)
                            .createOrderAndPay(context: context, model: model);
                      },
                      color: AppColors.success,
                      textStyle: text15(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                  error: (_, _) => const Text("0"),
                  loading: () => Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.button),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Pooja fee can be transferred offline after booking\nconfirmation and transaction.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(String number, String text, bool hasCheck) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            hasCheck ? Icons.check_circle : Icons.circle_outlined,
            color: const Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value,
    Color color, {
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
