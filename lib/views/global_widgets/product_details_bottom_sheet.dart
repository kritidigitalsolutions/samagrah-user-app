import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_booked_res/review_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/product_details_provider.dart';
import 'package:samagrah/views/after_login/home_screen.dart';
import 'package:samagrah/views/custom_widget/product_image_slider.dart';
import 'package:samagrah/views/custom_widget/rating_summary_widget.dart';

class ProductDetailsBottomSheet extends ConsumerWidget {
  final String productId;

  const ProductDetailsBottomSheet({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailsProvider(productId));
    final productState = ref.watch(productProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: asyncProduct.when(
            /// 🔄 LOADING
            loading: () => const Center(child: CircularProgressIndicator()),

            /// ❌ ERROR
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 40, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Something went wrong"),
                  Text("$e", style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),

            /// ✅ DATA
            data: (res) {
              final product = res.data;
              if (product == null) {
                return const Center(child: Text("No product found"));
              }

              final pricing = product.pricing;

              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔘 Drag Handle
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// 🖼 IMAGE SLIDER
                    SizedBox(child: ProductImageSlider(images: product.image)),

                    const SizedBox(height: 16),

                    /// 🏷 TITLE
                    Text(
                      product.title ?? "Product",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// 📦 CATEGORY
                    Text(
                      product.category?.name ?? "",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 12),

                    /// 💰 PRICE
                    Row(
                      children: [
                        Text(
                          "₹${pricing?.price ?? 0}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (pricing?.mrp != null)
                          Text(
                            "₹${pricing!.mrp}",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(width: 8),

                        if (pricing?.discountPercent != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${pricing!.discountPercent}% OFF",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (pricing?.savings != null)
                      Text(
                        "You save ₹${pricing!.savings}",
                        style: const TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 12),

                    /// 📊 STOCK
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: product.stock?.status == "in_stock"
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(product.stock?.status ?? "Unknown"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// TAGS
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 20),

                    // ── Ratings & Reviews ──
                    if (product.ratings != null)
                      RatingSummaryWidget(
                        ratings: product.ratings!,
                        productId: product.id ?? '',
                      ),

                    productState.when(
                      data: (data) {
                        final allProducts = data.allProducts;

                        // ✅ FILTER by category
                        final category = product.category?.name;

                        final filteredProducts = allProducts.where((p) {
                          return p.category?.name == category;
                        }).toList();

                        if (filteredProducts.isEmpty) {
                          return const SizedBox();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Similar Items",
                              style: text15(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                              height: 160,
                              child: AnimationLimiter(
                                key: ValueKey("${filteredProducts.length}"),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredProducts[index];

                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: SlideAnimation(
                                        horizontalOffset: 50,
                                        child: FadeInAnimation(
                                          child: GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (_) =>
                                                    ProductDetailsBottomSheet(
                                                      productId: item.id ?? '',
                                                    ),
                                              );
                                            },
                                            child: buildDiyaCard(
                                              item,
                                              ref,
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => const Text("Error loading products"),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

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
      builder: (_, _) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Drag handle + title as pinned header ──
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
              // ── Rating Summary ──
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

              // ── Customer Reviews header ──
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

              // ── Empty state ──
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
                // ── Review cards list ──
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

              // ── Load more indicator ──
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
// Rating Summary (compact — inside bottom sheet)
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
        // Big score
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
