// lib/views/widgets/product_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Heart Icon
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetails,
                        arguments: product,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CustomCachedImage(
                        imageUrl:
                            "http://192.168.1.40:8000/${product.thumbnail}",
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id ?? '');
                    },
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isWishlisted ? AppColors.error : AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: AppColors.grey300),

          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: text11(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      '${product.discountPercent}% off',
                      style: text10(color: AppColors.grey500),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${product.oldPrice}/-',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price}/-',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // 🔥 Quantity Control
                _QuantityControl(
                  quantity: quantity,
                  productId: product.id ?? '',
                  isLoading: cartState.isLoading,
                  product: product,
                  cartNotifier: cartNotifier,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Separate widget for quantity control - prevents unnecessary rebuilds
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
      return const SizedBox(
        height: 22,
        child: Center(
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
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: quantity <= 0
          ? AppButton(
              key: ValueKey('add_$productId'),
              height: 22,
              radius: 4,
              textStyle: text11(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              title: "Add",
              onTap: () {
                cartNotifier.addItem(
                  CartItem(
                    productId: productId,
                    title: product.title ?? '',
                    thumbnail: product.thumbnail ?? '',
                    price: product.price?.toDouble() ?? 0.0,
                  ),
                );
              },
            )
          : Container(
              key: ValueKey('qty_$productId'),
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => cartNotifier.decreaseQuantity(productId),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(
                        Icons.remove,
                        size: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
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
                  ),
                  InkWell(
                    onTap: () => cartNotifier.increaseQuantity(productId),
                    child: const SizedBox(
                      width: 22,
                      height: 22,
                      child: Icon(Icons.add, size: 12, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
