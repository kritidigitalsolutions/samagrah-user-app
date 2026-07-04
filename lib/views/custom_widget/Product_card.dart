// lib/views/custom_widget/Product_card.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 28) / 3;
    final imageHeight = cardWidth;

    final cartState = ref.watch(cartProvider);
    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final currentIndex = ref.watch(imageSliderIndexProvider(product.id ?? ''));

    final hasDiscount = (product.discountPercent ?? 0) != 0;
    final inStock = product.inStock == true;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: product,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── IMAGE SECTION ──────────────────────────────────────
            SizedBox(
              height: imageHeight,
              child: Stack(
                children: [
                  // Image / Carousel
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: product.images.length > 1
                          ? CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: false,
                                viewportFraction: 1,
                                enlargeCenterPage: false,
                                onPageChanged: (index, _) {
                                  ref
                                          .read(
                                            imageSliderIndexProvider(
                                              product.id ?? '',
                                            ).notifier,
                                          )
                                          .state =
                                      index;
                                },
                              ),
                              items: product.images.map((img) {
                                return CustomCachedImage(
                                  borderRadius: BorderRadius.zero,
                                  imageUrl: img.replaceAll("\\", "/"),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              }).toList(),
                            )
                          : CustomCachedImage(
                              borderRadius: BorderRadius.zero,
                              imageUrl:
                                  (product.images.isNotEmpty
                                          ? product.images.first
                                          : product.thumbnail ?? '')
                                      .replaceAll("\\", "/"),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),

                  // TOP-RIGHT: wishlist
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id ?? ''),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.88),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 13,
                          color: isWishlisted
                              ? AppColors.error
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),

                  // BOTTOM-LEFT: page dots
                  if (product.images.length > 1)
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: AnimatedSmoothIndicator(
                        activeIndex: currentIndex.clamp(
                          0,
                          product.images.length - 1,
                        ),
                        count: product.images.length,
                        effect: WormEffect(
                          dotHeight: 4,
                          dotWidth: 4,
                          activeDotColor: AppColors.black,
                          dotColor: AppColors.white.withOpacity(0.7),
                        ),
                      ),
                    ),

                  // BOTTOM: ADD button OR "Out of Stock" overlay
                  // ✅ Both are inside image — info section mein kuch extra nahi
                  Positioned(
                    bottom: 5,
                    right: 5,
                    // Out of stock → full width strip; in stock → right-side button
                    left: inStock ? null : 5,
                    child: inStock
                        ? _QuantityControl(
                            quantity: quantity,
                            productId: product.id ?? '',
                            isLoading: cartState.isLoading,
                            product: product,
                            cartNotifier: cartNotifier,
                          )
                        : Container(
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.52),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: text8(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // ── INFO SECTION ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 7, 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unit
                  if (product.details?.unit != null &&
                      product.details!.unit!.isNotEmpty)
                    Text(
                      product.details!.unit!,
                      style: text10(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 2),

                  // Current price
                  Text(
                    'Rs. ${product.price}',
                    style: text13(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Old price + discount
                  if (hasDiscount) ...[
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Rs.${product.oldPrice}',
                            style: text11(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ).copyWith(decoration: TextDecoration.lineThrough),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${product.discountPercent}% off',
                            style: text10(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 3),

                  // Title
                  Text(
                    capitalizeWords(product.title ?? ''),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text11(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // ✅ "Out of Stock" yahan se hata diya — image overlay pe hai ab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge ──────────────────────────────────────────────────────────────────────

// ── Quantity Control ───────────────────────────────────────────────────────────

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final String productId;
  final bool isLoading;
  final Product product;
  final CartNotifier cartNotifier;

  const _QuantityControl({
    required this.quantity,
    required this.productId,
    required this.product,
    required this.cartNotifier,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 24,
        width: 46,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Center(
          child: SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, anim) =>
          ScaleTransition(scale: anim, child: child),
      child: quantity <= 0
          ? GestureDetector(
              key: ValueKey('add_$productId'),
              onTap: () => cartNotifier.addItem(
                CartItem(
                  productId: productId,
                  title: product.title ?? '',
                  thumbnail: product.thumbnail ?? '',
                  price: product.price?.toDouble() ?? 0.0,
                  inStock: product.inStock == true,
                ),
              ),
              child: Container(
                height: 24,
                width: 52,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(
                    'ADD',
                    style: text11(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            )
          : Container(
              key: ValueKey('qty_$productId'),
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => cartNotifier.decreaseQuantity(productId),
                    child: const SizedBox(
                      width: 20,
                      height: 24,
                      child: Icon(
                        Icons.remove,
                        size: 10,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    alignment: Alignment.center,
                    color: AppColors.white,
                    child: Text(
                      '$quantity',
                      style: text10(
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cartNotifier.increaseQuantity(productId),
                    child: const SizedBox(
                      width: 20,
                      height: 24,
                      child: Icon(Icons.add, size: 10, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
