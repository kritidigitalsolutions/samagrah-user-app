import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_payment_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/coupon_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/wallet_provider.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.repeat(reverse: true); // 🔥 continuous animation
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ref.invalidate(selectedDateProvider);
        ref.invalidate(selectedAddressProvider);
        ref.invalidate(selectedRitualProvider);
        ref.invalidate(panditPaymentBookingProvider);
        ref.invalidate(selectedPanditProvider);
        ref.invalidate(selectedServiceProvider);
        ref.invalidate(serviceSelected);
        ref.invalidate(panditBookingProvider);
        ref.invalidate(walletProvider);
        ref.invalidate(couponProvider);
        ref.invalidate(panditAvailabilityProvider);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => MyHomeScreen(index: 0)),
          (route) => false, // removes all previous routes
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      ScaleTransition(
                        scale: scaleAnimation,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 40,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Payment Successful Text
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: text26(
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                          children: [
                            TextSpan(text: 'Payment\n'),
                            TextSpan(text: 'Successful'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your payment is completed and booking request has been sent to Pandit ji',
                        textAlign: TextAlign.center,
                        style: text13(
                          color: AppColors.grey,
                        ).copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You will receive confirmation within 60 minutes',
                        textAlign: TextAlign.center,
                        style: text13(
                          color: AppColors.button,
                        ).copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      // View Booking Button
                      AppButton(
                        title: "View Booking",
                        onTap: () {
                          ref.invalidate(panditBookingProvider);
                          Navigator.pushNamed(context, AppRoutes.myBooking);
                        },
                      ),
                      const SizedBox(height: 12),
                      AppOutlineButton(
                        title: "Back to Home",
                        onTap: () {
                          ref.invalidate(selectedDateProvider);
                          ref.invalidate(selectedAddressProvider);
                          ref.invalidate(selectedRitualProvider);
                          ref.invalidate(panditPaymentBookingProvider);
                          ref.invalidate(selectedPanditProvider);
                          ref.invalidate(selectedServiceProvider);
                          ref.invalidate(serviceSelected);
                          ref.invalidate(panditBookingProvider);
                          ref.invalidate(walletProvider);
                          ref.invalidate(couponProvider);
                          ref.invalidate(panditAvailabilityProvider);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MyHomeScreen(index: 0),
                            ),
                            (route) => false, // removes all previous routes
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: buildRecommendationCard(
                //     'Keep this required',
                //     'Pooja Samagri',
                //     'Pooja Kits for the Griha Pravesh pooja',
                //     true,
                //     () {
                //       Navigator.pushNamed(context, AppRoutes.panditRecKit);
                //     },
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
