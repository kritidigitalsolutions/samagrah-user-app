import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/payment_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/notification_provider.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/coupon_provider.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/wallet_provider.dart';

class SuccessPage extends ConsumerStatefulWidget {
  const SuccessPage({super.key});

  @override
  ConsumerState<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends ConsumerState<SuccessPage>
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        await _handleBackToHome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              elevation: 1,
              color: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Animated Success Icon
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

                    Text(
                      'Order Confirmed',
                      style: text20(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Your order is confirmed now\nand will reach you soon',
                      textAlign: TextAlign.center,
                      style: text15(color: Colors.grey).copyWith(height: 1.4),
                    ),

                    const SizedBox(height: 30),

                    AppButton(
                      radius: 8,
                      title: "My Order",
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.myOrder);
                      },
                    ),

                    const SizedBox(height: 12),

                    AppOutlineButton(
                      radius: 8,
                      title: "Back To Home",
                      onTap: () async {
                        await _handleBackToHome();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBackToHome() async {
    final bookingItems = ref.read(bookingItemProvider);
    final cartState = ref.read(cartProvider);

    // Delete ordered items from cart
    for (final bookingItem in bookingItems) {
      final matchedCartItem = cartState.items.firstWhere(
        (cartItem) => cartItem.productId == bookingItem.productId,
        orElse: () =>
            CartItem(productId: '', title: '', thumbnail: '', price: 0),
      );

      if (matchedCartItem.productId.isNotEmpty) {
        await ref
            .read(cartProvider.notifier)
            .deleteCart(matchedCartItem.productId);
      }
    }

    // === IMPORTANT: Reset all checkout related providers ===
    ref.invalidate(bookingItemProvider);
    ref.invalidate(cartProvider);
    ref.invalidate(walletProvider);
    ref.invalidate(couponProvider);
    ref.invalidate(paymentProvider); // ←←← Ye line add karo
    ref.invalidate(loadingProvider); // Ye bhi add karo
    ref.invalidate(offerProvider);
    ref.invalidate(orderProvider);
    ref.invalidate(notificationProvider);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MyHomeScreen(index: 0)),
      (route) => false,
    );
  }
}
