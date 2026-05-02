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
import 'package:samagrah/views/after_login/home_screen.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';
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
                    RatingSummaryWidget(
                      ratings: product.ratings!,
                      productId: product.id ?? '', // ye add karo
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

// ─────────────────────────────────────────────────────────────────────────────
// Entry point — call this to open the sheet
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
// Bottom Sheet
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
    // Load all reviews (more per page for bottom sheet)
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
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
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
            const SizedBox(height: 16),

            // Title
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

            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.button),
                    )
                  : ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        // ── Rating Summary ──────────────────────────────
                        if (state.ratings != null)
                          _RatingSummaryCompact(ratings: state.ratings!),

                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 12),

                        // ── Reviews header ──────────────────────────────
                        Row(
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
                        const SizedBox(height: 12),

                        // ── Review cards ────────────────────────────────
                        if (state.reviews.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
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
                          ...state.reviews.map((r) => _ReviewCard(review: r)),

                        // ── Load more indicator ─────────────────────────
                        if (state.isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.button,
                                strokeWidth: 2,
                              ),
                            ),
                          ),

                        if (!state.hasMore && state.reviews.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: Text(
                                'All reviews loaded',
                                style: text12(color: AppColors.grey600),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Rating Summary (inside bottom sheet)
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
        // Big score box
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

        // Bars
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
// Individual Review Card
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
          // Top row: avatar + name + rating badge
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.button.withOpacity(0.15),
                backgroundImage:
                    review.user?.profileImage != null &&
                        (review.user!.profileImage!.isNotEmpty)
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

              // Rating pill
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

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment!, style: text13(color: AppColors.grey700)),
          ],
        ],
      ),
    );
  }
}
