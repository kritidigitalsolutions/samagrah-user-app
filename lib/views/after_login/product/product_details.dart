import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/after_login/home_screen.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';
import 'package:samagrah/views/custom_widget/product_image_slider.dart';
import 'package:samagrah/views/custom_widget/rating_summary_widget.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class ProductDetails extends ConsumerWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final productState = ref.watch(productProvider);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final showAllDetails = ref.watch(showAllDetailsProvider);

    final details = product.details;

    final detailItems = details == null
        ? <String, String?>{}
        : {
            "Brand": details.brand,
            "SKU": details.sku,
            "Unit": details.unit,
            "Weight": details.weight,
            "Dimensions": details.dimensions,
            "Material": details.material,
            "Color": details.color,
            "Manufacturer": details.manufacturer,
            "Country of Origin": details.countryOfOrigin,
            "Package Contents": details.packageContents,
            "Usage Instructions": details.usageInstructions,
            "Care Instructions": details.careInstructions,
            "Expiry Info": details.expiryInfo,
          };

    final visibleItems = detailItems.entries
        .where((item) => item.value != null && item.value!.trim().isNotEmpty)
        .toList();

    final displayedItems = showAllDetails
        ? visibleItems
        : visibleItems.take(5).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 Back + Image Card
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.white,
                              child: Icon(Icons.keyboard_arrow_left),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(wishlistProvider.notifier)
                                  .toggle(product.id ?? '');
                            },
                            child: CircleAvatar(
                              backgroundColor: AppColors.white,
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 23,
                                color: isWishlisted
                                    ? AppColors.error
                                    : AppColors.grey500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ProductImageSlider(images: product.images),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 🛒 Product Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title + Add button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                capitalizeWords(product.title ?? ""),
                                style: text14(fontWeight: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                                child: quantity == 0
                                    ? AppButton(
                                        key: ValueKey('add_${product.id}'),
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
                                              productId: product.id ?? '',
                                              title: product.title ?? '',
                                              thumbnail:
                                                  product.thumbnail ?? '',
                                              price:
                                                  product.price?.toDouble() ??
                                                  0.0,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        key: ValueKey('qty_${product.id}'),
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: AppColors.button,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  cartNotifier.decreaseQuantity(
                                                    product.id ?? '',
                                                  ),
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                alignment: Alignment.center,
                                                child: const Icon(
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
                                              onTap: () =>
                                                  cartNotifier.increaseQuantity(
                                                    product.id ?? '',
                                                  ),
                                              child: Container(
                                                width: 22,
                                                height: 22,
                                                alignment: Alignment.center,
                                                child: const Icon(
                                                  Icons.add,
                                                  size: 12,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Price
                        Row(
                          children: [
                            Text(
                              "MRP ₹${product.oldPrice}",
                              style: text13(color: AppColors.grey).copyWith(
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "${product.discountPercent}% OFF",
                              style: text13(
                                color: AppColors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "₹${product.price}/-",
                          style: text16(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    product.ratings?.average.toString() ?? '',
                                    style: text13(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.star,
                                    color: AppColors.warningLight,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "(${product.ratings?.totalReviews ?? ''})",
                              style: text15(color: AppColors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Text(
                          (product.inStock ?? false)
                              ? "In Stock"
                              : "Out of Stock",
                          style: text13(
                            color: (product.inStock ?? false)
                                ? AppColors.green
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        if (visibleItems.isNotEmpty) ...[
                          const SizedBox(height: 12),

                          Text(
                            "Product Details",
                            style: text15(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 8),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              children: displayedItems
                                  .map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 6,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              item.key,
                                              style: text13(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              item.value!,
                                              style: text13(
                                                color: AppColors.grey700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),

                          if (visibleItems.length > 5)
                            TextButton.icon(
                              onPressed: () {
                                ref
                                        .read(showAllDetailsProvider.notifier)
                                        .state =
                                    !showAllDetails;
                              },
                              label: Text(
                                showAllDetails ? "Show Less" : "Show More",
                                style: text13(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: Icon(
                                showAllDetails
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                              ),
                            ),
                        ],

                        const SizedBox(height: 10),

                        /// Buy Now
                        AppButton(
                          title: "Buy Now",
                          onTap: () {
                            final qua = quantity == 0 ? 1 : quantity;
                            Navigator.pushNamed(
                              context,
                              AppRoutes.orderSummary,
                              arguments: [
                                OrderItem(
                                  productId: product.id ?? '',
                                  title: product.title ?? '',
                                  price: product.price ?? 0,
                                  quantity: qua,
                                  image: product.thumbnail ?? '',
                                ),
                              ],
                            );
                          },
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🎁 Offer Banner
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff5c1f2e),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Get ₹50 OFF",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Add items worth ₹399 more",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                          "assets/icon/plate.png",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 👍 Suggested
                  Text(
                    "Similar Items",
                    style: text15(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  /// Horizontal List
                  productState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),

                    error: (e, _) =>
                        const Center(child: Text("Something went wrong")),

                    data: (state) {
                      final products = state.categoryProducts;

                      final filterProduct = products
                          .where((p) => p.id != product.id)
                          .toList();

                      if (filterProduct.isEmpty) {
                        return const Center(child: Text("No Products Found"));
                      }

                      return SizedBox(
                        height: 140,
                        child: AnimationLimiter(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filterProduct.length,
                            itemBuilder: (context, index) {
                              final product = filterProduct[index];

                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  horizontalOffset: 50, // 👉 right se aayega
                                  child: FadeInAnimation(
                                    child: buildDiyaCard(product, ref, context),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),
                  if (product.ratings != null)
                    RatingSummaryWidget(ratings: product.ratings!),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            BottomCartBar(),
          ],
        ),
      ),
    );
  }
}
