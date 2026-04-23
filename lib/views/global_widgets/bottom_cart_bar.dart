// lib/utils/bottom_cart_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';

class BottomCartBar extends ConsumerWidget {
  final double bottom;
  const BottomCartBar({super.key, this.bottom = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalItems = ref.watch(totalItemsProvider);
    final totalPrice = ref.watch(totalPriceProvider);

    // Hide if cart is empty
    if (cart.items.isEmpty) return const SizedBox.shrink();
    final displayItems = cart.items.take(3).toList();
    final remainingCount = cart.items.length - displayItems.length;

    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.myCart);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: AppColors.button,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 70,
                  height: 40,
                  child: Stack(
                    children: [
                      for (int i = 0; i < displayItems.length; i++)
                        Positioned(
                          left: i * 15, // spacing between images
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.white,
                            child: ClipOval(
                              child: displayItems[i].thumbnail.isNotEmpty
                                  ? CustomCachedImage(
                                      imageUrl:
                                          "http://192.168.1.40:8000/${displayItems[i].thumbnail}",
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.shopping_cart, size: 16),
                            ),
                          ),
                        ),

                      // 👉 Remaining Count (+X)
                      if (remainingCount > 0)
                        Positioned(
                          left: displayItems.length * 14,
                          top: 5,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.black,
                            child: Text(
                              "+$remainingCount",
                              style: text10(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$totalItems item${totalItems > 1 ? 's' : ''}",
                      style: text13(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      "₹${totalPrice.toStringAsFixed(0)}",
                      style: text15(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  "View Cart >",
                  style: text14(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
