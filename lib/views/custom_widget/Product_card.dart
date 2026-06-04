// lib/views/widgets/product_card_widget.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
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
    final cartState = ref.watch(cartProvider);
    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final currentIndex = ref.watch(imageSliderIndexProvider(product.id ?? ''));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE SECTION ─────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                // Carousel
                Positioned.fill(
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.productDetails,
                      arguments: product,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CarouselSlider(
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
                        items: product.images.map((image) {
                          return CustomCachedImage(
                            borderRadius: BorderRadius.zero,
                            imageUrl: image.replaceAll("\\", "/"),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // ── TOP LEFT: badge stack (Recommended + Daily + MostUsed)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ⭐ Recommended badge
                      if (product.isRecommended == true)
                        _Badge(
                          label: 'Top Pick',
                          icon: Icons.star,
                          color: AppColors.warning,
                        ),
                      if (product.isRecommended == true)
                        const SizedBox(height: 3),

                      // 🪔 Daily Essential badge
                      if (product.isMostPoojaEssentials == true)
                        _Badge(
                          label: 'Daily',
                          icon: Icons.local_fire_department,
                          color: AppColors.error,
                        ),
                      if (product.isMostPoojaEssentials == true)
                        const SizedBox(height: 3),

                      // 🔥 Most Used badge
                      if (product.isMostUsed == true)
                        _Badge(
                          label: 'Popular',
                          icon: Icons.trending_up,
                          color: Colors.deepPurple,
                        ),
                    ],
                  ),
                ),

                // ── TOP RIGHT: wishlist
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(wishlistProvider.notifier)
                        .toggle(product.id ?? ''),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: isWishlisted ? AppColors.error : AppColors.grey,
                      ),
                    ),
                  ),
                ),

                // ── BOTTOM LEFT: page dots
                if (product.images.length > 1)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: AnimatedSmoothIndicator(
                      activeIndex: currentIndex.clamp(
                        0,
                        product.images.length - 1,
                      ),
                      count: product.images.length,
                      effect: product.images.length <= 5
                          ? WormEffect(
                              dotHeight: 5,
                              dotWidth: 5,
                              activeDotColor: AppColors.black,
                              dotColor: AppColors.white.withOpacity(0.6),
                            )
                          : ScrollingDotsEffect(
                              activeDotColor: AppColors.black,
                              dotColor: AppColors.white.withOpacity(0.6),
                              dotHeight: 5,
                              dotWidth: 5,
                              spacing: 3,
                              maxVisibleDots: 5,
                            ),
                    ),
                  ),

                // ── BOTTOM RIGHT: ADD / qty control
                if (product.inStock == true)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _QuantityControl(
                      quantity: quantity,
                      productId: product.id ?? '',
                      isLoading: cartState.isLoading,
                      product: product,
                      cartNotifier: cartNotifier,
                    ),
                  ),
              ],
            ),
          ),

          // ── INFO SECTION ──────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unit / weight
                      if (product.details?.unit != null &&
                          product.details!.unit!.isNotEmpty)
                        Text(
                          product.details!.unit!,
                          style: text10(color: AppColors.grey),
                        ),

                      // Title
                      Text(
                        capitalizeWords(product.title ?? ''),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text11(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Price block
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.discountPercent != 0)
                        Row(
                          children: [
                            Text(
                              'Rs. ${product.oldPrice}',
                              style: text8(color: AppColors.grey).copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product.discountPercent}% off',
                              style: text8(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 1),
                      Text(
                        'Rs. ${product.price}/-',
                        style: text13(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  // Out of stock
                  if (product.inStock != true) _OutOfStockWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge widget ──────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _Badge({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 9),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Out of stock ──────────────────────────────────────────────────────────────

class _OutOfStockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.error),
      ),
      child: Text(
        "Out of Stock",
        style: text10(color: AppColors.error, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Quantity control ──────────────────────────────────────────────────────────

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
        height: 28,
        width: 52,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: const Center(
          child: SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: quantity <= 0
          ? AppButton(
              key: ValueKey('add_$productId'),
              height: 28,
              radius: 6,
              textStyle: text11(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              title: "ADD",
              onTap: () => cartNotifier.addItem(
                CartItem(
                  productId: productId,
                  title: product.title ?? '',
                  thumbnail: product.thumbnail ?? '',
                  price: product.price?.toDouble() ?? 0.0,
                ),
              ),
            )
          : Container(
              key: ValueKey('qty_$productId'),
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => cartNotifier.decreaseQuantity(productId),
                    child: const SizedBox(
                      width: 24,
                      height: 28,
                      child: Icon(
                        Icons.remove,
                        size: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 22,
                    alignment: Alignment.center,
                    color: AppColors.white,
                    child: Text(
                      '$quantity',
                      style: text11(
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => cartNotifier.increaseQuantity(productId),
                    child: const SizedBox(
                      width: 24,
                      height: 28,
                      child: Icon(Icons.add, size: 12, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
