import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/model/response/product_res/sub_category_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/sub_category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class TypeOfCategoryPage extends ConsumerStatefulWidget {
  final String title;
  final String categoryType;

  const TypeOfCategoryPage({
    super.key,
    required this.title,
    required this.categoryType,
  });

  @override
  ConsumerState<TypeOfCategoryPage> createState() => _TypeOfCategoryPageState();
}

class _TypeOfCategoryPageState extends ConsumerState<TypeOfCategoryPage> {
  final leftController = ScrollController();
  final rightController = ScrollController();
  String? selectedSubCategoryId;

  @override
  void dispose() {
    leftController.dispose();
    rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final subCategoryAsync = ref.watch(subCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: capitalizeWords(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.searchProduct),
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 18,
                child: Icon(Icons.search, size: 20, color: AppColors.grey400),
              ),
            ),
          ),
        ],
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Something went wrong")),
        data: (state) {
          List<Product> sourceProducts = widget.categoryType == "allItems"
              ? state.allProducts
              : state.allProducts
                    .where(
                      (p) => (p.categoryId?.id ?? '') == widget.categoryType,
                    )
                    .toList();

          return subCategoryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildLayout(sourceProducts, []),
            data: (subCategories) =>
                _buildLayout(sourceProducts, subCategories),
          );
        },
      ),
    );
  }

  Widget _buildLayout(
    List<Product> sourceProducts,
    List<SubCategoryData> subCategories,
  ) {
    final visibleSubCategories = _visibleSubCategories(
      sourceProducts,
      subCategories,
    );
    final selectedExists =
        selectedSubCategoryId == null ||
        visibleSubCategories.any((item) => item.id == selectedSubCategoryId);
    if (!selectedExists) {
      selectedSubCategoryId = null;
    }

    final filteredProducts = selectedSubCategoryId == null
        ? sourceProducts
        : sourceProducts
              .where((p) => (p.subCategoryId?.id ?? '') == selectedSubCategoryId)
              .toList();

    return SafeArea(
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubCategoryList(visibleSubCategories),
              Container(
                width: 1,
                color: AppColors.grey200,
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              _buildProductGrid(filteredProducts),
            ],
          ),
          const BottomCartBar(),
        ],
      ),
    );
  }

  List<SubCategoryData> _visibleSubCategories(
    List<Product> sourceProducts,
    List<SubCategoryData> subCategories,
  ) {
    final productSubCategoryIds = sourceProducts
        .map((p) => p.subCategoryId?.id ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    return subCategories.where((subCategory) {
      final isActive = (subCategory.status ?? '').toLowerCase() == 'active';
      final belongsToSelectedCategory =
          widget.categoryType == 'allItems' ||
          (subCategory.categoryId?.id ?? '') == widget.categoryType;
      final hasProducts = productSubCategoryIds.contains(subCategory.id ?? '');

      return isActive && belongsToSelectedCategory && hasProducts;
    }).toList();
  }

  Widget _buildSubCategoryList(List<SubCategoryData> subCategories) {
    return SizedBox(
      width: 80,
      child: Scrollbar(
        controller: leftController,
        thumbVisibility: true,
        thickness: 2,
        radius: const Radius.circular(5),
        child: ListView.builder(
          controller: leftController,
          physics: const BouncingScrollPhysics(),
          itemCount: subCategories.length + 1,
          padding: const EdgeInsets.only(top: 8),
          itemBuilder: (context, index) {
            final isAll = index == 0;
            final subCategory = isAll ? null : subCategories[index - 1];
            final image = subCategory?.image ?? '';
            final isSelected = isAll
                ? selectedSubCategoryId == null
                : selectedSubCategoryId == subCategory?.id;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              child: GestureDetector(
                onTap: () => setState(
                  () => selectedSubCategoryId = isAll ? null : subCategory?.id,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: isSelected
                        ? const Border(
                            left: BorderSide(color: AppColors.button, width: 3),
                          )
                        : null,
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.button.withAlpha(30)
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isAll || image.isEmpty
                              ? Icon(
                                  isAll
                                      ? Icons.all_inclusive
                                      : Icons.category_outlined,
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.button
                                      : AppColors.grey500,
                                )
                              : CustomCachedImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAll ? 'All' : (subCategory?.name ?? ''),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text10(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ? AppColors.button
                              : AppColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.grey300,
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
                style: text14(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        controller: rightController,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${products.length} items',
              style: text11(color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio:
                    0.56, // was 0.62 — gives ~10% more vertical space
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) =>
                  _BlinkitCard(product: products[index]),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Blinkit-style card ────────────────────────────────────────────────────────

class _BlinkitCard extends ConsumerWidget {
  final Product product;
  const _BlinkitCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final currentIndex = ref.watch(imageSliderIndexProvider(product.id ?? ''));
    final inStock = product.inStock == true;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetails,
        arguments: product,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ─────────────────────────────────────────────
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Carousel
                Positioned.fill(
                  child: ClipRRect(
                    child: product.images.isEmpty
                        ? Container(color: AppColors.grey200)
                        : CarouselSlider(
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
                                imageUrl: img.replaceAll("\\", "/"),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                borderRadius: BorderRadius.zero,
                              );
                            }).toList(),
                          ),
                  ),
                ),

                // Wishlist
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(wishlistProvider.notifier)
                        .toggle(product.id ?? ''),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: isWishlisted ? AppColors.error : AppColors.grey,
                      ),
                    ),
                  ),
                ),

                // Page dots
                if (product.images.length > 1)
                  Positioned(
                    bottom: 5,
                    left: 6,
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
                        dotColor: AppColors.white.withOpacity(0.6),
                      ),
                    ),
                  ),

                // ADD button — bottom right (Blinkit style)
                Positioned(
                  bottom: 6,
                  right: 6,
                  left: inStock ? null : 6,
                  child: inStock
                      ? _QuantityWidget(
                          quantity: quantity,
                          product: product,
                          cartNotifier: cartNotifier,
                        )
                      : Container(
                          height: 22,
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

          // ── Info ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unit
                if (product.details?.unit != null &&
                    product.details!.unit!.isNotEmpty)
                  Text(
                    product.details!.unit!,
                    style: text8(color: AppColors.grey),
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
                const SizedBox(height: 4),

                // Old price + discount
                Row(
                  children: [
                    Text(
                      'Rs.${product.oldPrice}',
                      style: text8(
                        color: AppColors.grey,
                      ).copyWith(decoration: TextDecoration.lineThrough),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.discountPercent}% off',
                      style: text8(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Price
                Text(
                  'Rs. ${product.price}/-',
                  style: text12(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                // Out of stock
                if (product.inStock != true)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      'Out of Stock',
                      style: text8(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small badge ───────────────────────────────────────────────────────────────
// ── Quantity control ──────────────────────────────────────────────────────────
class _QuantityWidget extends StatelessWidget {
  final int quantity;
  final Product product;
  final CartNotifier cartNotifier;
  const _QuantityWidget({
    required this.quantity,
    required this.product,
    required this.cartNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: quantity <= 0
          ? GestureDetector(
              key: ValueKey('add_${product.id}'),
              onTap: () => cartNotifier.addItem(
                CartItem(
                  productId: product.id ?? '',
                  title: product.title ?? '',
                  thumbnail: product.thumbnail ?? '',
                  price: product.price?.toDouble() ?? 0.0,
                  inStock: product.inStock == true,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
                child: Text(
                  'ADD',
                  style: text11(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          : Container(
              key: ValueKey('qty_${product.id}'),
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
                    onTap: () =>
                        cartNotifier.decreaseQuantity(product.id ?? ''),
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
                    onTap: () =>
                        cartNotifier.increaseQuantity(product.id ?? ''),
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
