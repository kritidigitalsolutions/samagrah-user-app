import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';
import 'package:samagrah/views/custom_widget/product_image_slider.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class ProductDetails extends ConsumerWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
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
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffe9e4dc),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
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
                          ],
                        ),
                        const SizedBox(height: 10),
                        ProductImageSlider(images: product.images),
                      ],
                    ),
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
                                product.title ?? '',
                                style: TextStyle(fontWeight: FontWeight.w600),
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
                        Text(
                          "₹${product.price}/-",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Row(
                          children: [
                            Text(
                              "MRP ₹${product.oldPrice}",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "${product.discountPercent}% OFF",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Text(
                          (product.inStock ?? false)
                              ? "In Stock"
                              : "Out of Stock",
                          style: TextStyle(
                            color: (product.inStock ?? false)
                                ? AppColors.green
                                : AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

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
                  const Text(
                    "You might also like",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  /// Horizontal List
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icon/kalash.png',
                                    fit: BoxFit.cover,
                                    height: 70,
                                  ),
                                  const SizedBox(height: 5),
                                  const Text("Kalash"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "₹80/-",
                                            style: text13(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),

                                        AppButton(
                                          height: 25,
                                          title: "Add",
                                          onTap: () {},
                                          textStyle: text12(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 10,
                              child: Icon(
                                Icons.favorite_border_outlined,
                                size: 20,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

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
