import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_booked_res/review_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/product_details_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/custom_widget/product_image_slider.dart';
import 'package:samagrah/views/custom_widget/rating_summary_widget.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key});

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reviewProvider.notifier)
          .fetchReviews(product.id ?? '', limit: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final quantity = ref.watch(cartQuantityProvider(product.id ?? ''));
    final cartNotifier = ref.read(cartProvider.notifier);
    final productState = ref.watch(productProvider);
    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final showAllDetails = ref.watch(showAllDetailsProvider);
    final details = product.details;

    // All detail fields — show ALL, even if null (will display "N/A")
    final allDetailFields = details == null
        ? <String, String?>{}
        : {
            'Brand': details.brand,
            'Sub Brand': details.subBrand,
            'Unit': details.unit,
            'Weight': details.weight,
            'Dimensions': details.dimensions,
            'Material': details.material,
            'Color': details.color,
            'Manufacturer': details.manufacturer,
            'Country of Origin': details.countryOfOrigin,
            'Package Contents': details.packageContents,
            'Usage Instructions': details.usageInstructions,
            'Care Instructions': details.careInstructions,
            'Expiry Info': details.expiryInfo,
          };

    // Filled items (have real data)
    final filledItems = allDetailFields.entries
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .toList();

    // Empty items (null or blank)
    final emptyItems = allDetailFields.entries
        .where((e) => e.value == null || e.value!.trim().isEmpty)
        .toList();

    // Combine: filled first, then empty
    final visibleItems = [...filledItems, ...emptyItems];
    final displayedItems = showAllDetails
        ? visibleItems
        : visibleItems.take(5).toList();

    // Badges
    final badges = <_BadgeData>[
      if (product.isRecommended == true)
        _BadgeData('Recommended', Icons.star_rounded, const Color(0xFFF59E0B)),
      if (product.isMostPoojaEssentials == true)
        _BadgeData(
          'Pooja Essential',
          Icons.local_fire_department,
          Colors.deepOrange,
        ),
      if (product.isMostUsed == true)
        _BadgeData('Most Used', Icons.trending_up, Colors.deepPurple),
      if (product.isEveryDayRitual == true)
        _BadgeData('Daily Ritual', Icons.wb_sunny_rounded, Colors.teal),
      if (product.isRitualItems == true)
        _BadgeData('Ritual Item', Icons.auto_awesome, Colors.indigo),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── SliverAppBar ──────────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: AppColors.white,
                  automaticallyImplyLeading: false,
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircleAvatar(
                        backgroundColor: AppColors.white,
                        child: Icon(Icons.keyboard_arrow_left),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => ref
                            .read(wishlistProvider.notifier)
                            .toggle(product.id ?? ''),
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
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: ProductImageSlider(images: product.images),
                  ),
                ),

                // ── Product Info Card ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Badges row ──────────────────────────────────
                          if (badges.isNotEmpty) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: badges
                                  .map((b) => _BadgeChip(data: b))
                                  .toList(),
                            ),
                            const SizedBox(height: 10),
                          ],

                          // ── Title + Add/Qty ─────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  capitalizeWords(product.title ?? ''),
                                  style: text14(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 100,
                                child: _QuantityControl(
                                  quantity: quantity,
                                  product: product,
                                  cartNotifier: cartNotifier,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // ── Unit tag ────────────────────────────────────
                          if (details?.unit != null &&
                              details!.unit!.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                details.unit!,
                                style: text11(color: AppColors.grey700),
                              ),
                            ),

                          // ── Price row ───────────────────────────────────
                          Row(
                            children: [
                              Text(
                                'MRP ₹${product.oldPrice}',
                                style: text13(color: AppColors.grey).copyWith(
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.discountPercent}% OFF',
                                  style: text11(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${product.price}/-',
                            style: text18(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          // ── Rating + stock row ──────────────────────────
                          Row(
                            children: [
                              // Rating badge
                              if (product.ratings != null) ...[
                                GestureDetector(
                                  onTap: () => showReviewBottomSheet(
                                    context,
                                    ref,
                                    product.id ?? '',
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${product.ratings!.average ?? 0}',
                                          style: text13(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        const Icon(
                                          Icons.star,
                                          color: AppColors.warningLight,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => showReviewBottomSheet(
                                    context,
                                    ref,
                                    product.id ?? '',
                                  ),
                                  child: Text(
                                    '(${product.ratings!.totalReviews ?? 0} reviews)',
                                    style: text13(color: AppColors.grey),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],

                              // Stock pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: (product.inStock ?? false)
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: (product.inStock ?? false)
                                        ? Colors.green.shade300
                                        : Colors.red.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (product.inStock ?? false)
                                          ? Icons.check_circle_outline
                                          : Icons.cancel_outlined,
                                      size: 12,
                                      color: (product.inStock ?? false)
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (product.inStock ?? false)
                                          ? 'In Stock'
                                          : 'Out of Stock',
                                      style: text11(
                                        color: (product.inStock ?? false)
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),

                          // ── Product Details Section ─────────────────────
                          Row(
                            children: [
                              Text(
                                'Product Details',
                                style: text15(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${filledItems.length}/${allDetailFields.length}',
                                  style: text10(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              children: displayedItems.map((item) {
                                final hasValue =
                                    item.value != null &&
                                    item.value!.trim().isNotEmpty;
                                return _DetailRow(
                                  label: item.key,
                                  value: hasValue ? item.value! : 'N/A',
                                  hasValue: hasValue,
                                );
                              }).toList(),
                            ),
                          ),

                          // Show more / less
                          if (visibleItems.length > 5)
                            GestureDetector(
                              onTap: () {
                                ref
                                        .read(showAllDetailsProvider.notifier)
                                        .state =
                                    !showAllDetails;
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.grey200,
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      showAllDetails
                                          ? 'Show Less'
                                          : 'Show All ${visibleItems.length} Details',
                                      style: text13(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      showAllDetails
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 12),

                          // ── Buy Now ─────────────────────────────────────
                          AppButton(
                            title: 'Buy Now',
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
                  ),
                ),

                // ── Offer Banner ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
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
                                      'Get ₹50 OFF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Add items worth ₹399 more',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 70),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Image.asset(
                            'assets/icon/plate.png',
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Similar Items ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    child: Text(
                      'Similar Items',
                      style: text15(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 140,
                    child: productState.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) =>
                          const Center(child: Text('Something went wrong')),
                      data: (state) {
                        final filterProduct = state.categoryProducts
                            .where((p) => p.id != product.id)
                            .toList();
                        if (filterProduct.isEmpty) {
                          return const Center(child: Text('No Products Found'));
                        }
                        return AnimationLimiter(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: filterProduct.length,
                            itemBuilder: (context, index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  horizontalOffset: 50,
                                  child: FadeInAnimation(
                                    child: ProductCard(
                                      product: filterProduct[index],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ── Ratings & Reviews ─────────────────────────────────────
                if (product.ratings != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                      child: RatingSummaryWidget(
                        ratings: product.ratings!,
                        productId: product.id ?? '',
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),

            const BottomCartBar(),
          ],
        ),
      ),
    );
  }
}

// ── Badge data model ──────────────────────────────────────────────────────────
class _BadgeData {
  final String label;
  final IconData icon;
  final Color color;
  const _BadgeData(this.label, this.icon, this.color);
}

// ── Badge chip ────────────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final _BadgeData data;
  const _BadgeChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: data.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 12, color: data.color),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasValue;
  const _DetailRow({
    required this.label,
    required this.value,
    required this.hasValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.grey200, width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: text12(
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: text12(
                color: hasValue ? AppColors.textPrimary : AppColors.grey300,
                fontWeight: hasValue ? FontWeight.normal : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quantity control ──────────────────────────────────────────────────────────
class _QuantityControl extends StatelessWidget {
  final int quantity;
  final Product product;
  final CartNotifier cartNotifier;
  const _QuantityControl({
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
      child: quantity == 0
          ? AppButton(
              key: ValueKey('add_${product.id}'),
              height: 34,
              radius: 6,
              textStyle: text12(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              title: 'Add to Cart',
              onTap: () {
                cartNotifier.addItem(
                  CartItem(
                    productId: product.id ?? '',
                    title: product.title ?? '',
                    thumbnail: product.thumbnail ?? '',
                    price: product.price?.toDouble() ?? 0.0,
                  ),
                );
              },
            )
          : Container(
              key: ValueKey('qty_${product.id}'),
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () =>
                        cartNotifier.decreaseQuantity(product.id ?? ''),
                    child: const SizedBox(
                      width: 30,
                      height: 34,
                      child: Icon(
                        Icons.remove,
                        size: 14,
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
                        style: text13(
                          fontWeight: FontWeight.bold,
                          color: AppColors.button,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () =>
                        cartNotifier.increaseQuantity(product.id ?? ''),
                    child: const SizedBox(
                      width: 30,
                      height: 34,
                      child: Icon(Icons.add, size: 14, color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Bottom Sheet — entry point
// ─────────────────────────────────────────────────────────────────────────────

void showReviewBottomSheet(
  BuildContext context,
  WidgetRef ref,
  String productId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ReviewBottomSheet(productId: productId),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewBottomSheet extends ConsumerStatefulWidget {
  final String productId;
  const _ReviewBottomSheet({required this.productId});

  @override
  ConsumerState<_ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<_ReviewBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(reviewProvider.notifier)
          .fetchReviews(widget.productId, limit: 10);
    });
    _scrollController.addListener(() {
      final pos = _scrollController.position;
      if (pos.pixels >= pos.maxScrollExtent - 100) {
        ref.read(reviewProvider.notifier).loadMore(widget.productId, limit: 10);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reviewProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      // FIX: use different parameter names for the two positional args
      builder: (sheetContext, sheetScrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CustomScrollView(
          // Use our own controller for pagination listening
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              expandedHeight: 75,
              flexibleSpace: FlexibleSpaceBar(
                background: Column(
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Ratings & Reviews',
                            style: text18(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (state.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.button),
                ),
              )
            else ...[
              if (state.ratings != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _RatingSummaryCompact(ratings: state.ratings!),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Colors.grey.shade200),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        'Customer Reviews',
                        style: text15(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      if (state.pagination?.totalReviews != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.button.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${state.pagination!.totalReviews}',
                            style: text12(color: AppColors.button),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (state.reviews.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.rate_review_outlined,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No reviews yet',
                          style: text14(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ReviewCard(review: state.reviews[index]),
                      childCount: state.reviews.length,
                    ),
                  ),
                ),

              if (state.isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.button,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),

              if (!state.hasMore && state.reviews.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'All reviews loaded',
                        style: text12(color: AppColors.grey600),
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating Summary Compact
// ─────────────────────────────────────────────────────────────────────────────

class _RatingSummaryCompact extends StatelessWidget {
  final Ratings ratings;
  const _RatingSummaryCompact({required this.ratings});

  Color _barColor(int star) {
    if (star >= 4) return Colors.green;
    if (star == 3) return Colors.amber;
    if (star == 2) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final counts = ratings.counts;
    if (counts == null) return const SizedBox.shrink();

    final ratingMap = {
      5: counts.rating5 ?? 0,
      4: counts.rating4 ?? 0,
      3: counts.rating3 ?? 0,
      2: counts.rating2 ?? 0,
      1: counts.rating1 ?? 0,
    };
    final total = ratingMap.values.fold(0, (s, v) => s + v);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              '${ratings.average ?? 0}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.button,
                height: 1,
              ),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < (ratings.average ?? 0)
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: const Color(0xFFFFA000),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('$total ratings', style: text12(color: AppColors.grey600)),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: ratingMap.entries.map((e) {
              final progress = total == 0 ? 0.0 : e.value / total;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Text('${e.key}', style: text12(color: AppColors.grey700)),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(_barColor(e.key)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${e.value}',
                        textAlign: TextAlign.end,
                        style: text11(color: AppColors.grey700),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  Color _starColor(int? rating) {
    if ((rating ?? 0) >= 4) return Colors.green;
    if ((rating ?? 0) == 3) return Colors.amber;
    return Colors.red;
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.button.withOpacity(0.15),
                backgroundImage:
                    review.user?.profileImage != null &&
                        review.user!.profileImage!.isNotEmpty
                    ? NetworkImage(review.user!.profileImage!)
                    : null,
                child:
                    review.user?.profileImage == null ||
                        review.user!.profileImage!.isEmpty
                    ? Text(
                        (review.user?.name ?? 'U')[0].toUpperCase(),
                        style: text14(
                          color: AppColors.button,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.name ?? 'Anonymous',
                      style: text13(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _timeAgo(review.createdAt),
                      style: text11(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _starColor(review.rating),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${review.rating ?? 0}',
                      style: text12(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment!, style: text13(color: AppColors.grey700)),
          ],
        ],
      ),
    );
  }
}
