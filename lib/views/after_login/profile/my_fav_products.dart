import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/cart_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/res/app_image.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/custom_widget/empty_data_widget.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

class MyFavProducts extends ConsumerWidget {
  const MyFavProducts({super.key});

  Future<void> _refreshWishlist(WidgetRef ref) {
    return ref.read(wishlistProvider.notifier).loadWishlist();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);
    final items = wishlistState.items;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CustomAppBar(
        title: "My Wishlist",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/icon/heart.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, exception, stackTrace) {
                return SizedBox(
                  width: 70,
                  height: 70,

                  child: Center(
                    child: Icon(
                      Icons.favorite,
                      color: AppColors.button,
                      size: 50,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.background),
              child: Column(
                children: [
                  wishlistState.isLoading
                      ? Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => _refreshWishlist(ref),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          ),
                        )
                      : items.isEmpty
                      ? Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => _refreshWishlist(ref),
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.65,
                                child: EmptyDataWidget(
                                  title: "Your Wishlist is Empty",
                                  subtitle:
                                      "Save items you love to view them later",
                                  animationPath: AppImages.empty,
                                  height: 250,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Expanded(
                          child: RefreshIndicator(
                            onRefresh: () => _refreshWishlist(ref),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(15),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return _buildCartItem(
                                  context,
                                  ref,
                                  items[index],
                                );
                              },
                            ),
                          ),
                        ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomElevatedIconButton(
                            text: "Add more items",
                            icon: Icons.add_shopping_cart_outlined,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.comparisionPage,
                              );
                            },
                            iconSize: 18,
                            textStyle: text13(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomCartBar(bottom: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, WidgetRef ref, Datum item) {
    final product = item.product;

    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final productId = product?.id ?? '';
    final quantity = ref.watch(cartQuantityProvider(productId));

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// IMAGE
              CustomCachedImage(
                borderRadius: BorderRadius.circular(10),
                width: 75,
                height: 75,
                imageUrl: product?.media?.image.isNotEmpty == true
                    ? product!.media!.image.first
                    : '',
              ),

              const SizedBox(width: 12),

              /// DETAILS
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.title ?? '',
                      style: text15(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product?.category?.name ?? '',
                      style: text12(color: AppColors.grey500),
                    ),
                    const SizedBox(height: 8),

                    InkWell(
                      onTap: () {
                        openProductBottomSheet(context, productId);
                      },
                      child: Text(
                        'View Product',
                        style: text12(
                          color: AppColors.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// 🔥 QUANTITY CONTROL
                  ],
                ),
              ),

              /// PRICE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        ref.read(wishlistProvider.notifier).toggle(productId);
                      },
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.button.withAlpha(20),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.button,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    if (cartState.isLoading)
                      const SizedBox(
                        height: 22,
                        child: Center(
                          child: SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    else
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
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
                                      title: product?.title ?? '',
                                      thumbnail:
                                          product?.media?.image.isNotEmpty ==
                                              true
                                          ? product!.media!.image.first
                                          : '',
                                      price: (product?.pricing?.price ?? 0)
                                          .toDouble(),
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
                                  children: [
                                    InkWell(
                                      onTap: () => cartNotifier
                                          .decreaseQuantity(productId),
                                      child: const SizedBox(
                                        width: 22,
                                        child: Icon(
                                          Icons.remove,
                                          size: 12,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
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
                                      onTap: () => cartNotifier
                                          .increaseQuantity(productId),
                                      child: const SizedBox(
                                        width: 22,
                                        child: Icon(
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '₹ ${product?.pricing?.mrp ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '₹${product?.pricing?.price ?? 0}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void openProductBottomSheet(BuildContext context, String productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailsBottomSheet(productId: productId),
  );
}
