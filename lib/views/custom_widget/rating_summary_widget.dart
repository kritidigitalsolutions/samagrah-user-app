// ═══════════════════════════════════════════════════════════════════════════
// FILE 1: lib/views/custom_widget/rating_summary_widget.dart
// Replace your existing RatingSummaryWidget with this
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_booked_res/review_res_model.dart'
    as rev;
import 'package:samagrah/model/response/product_res/product_response_model.dart';

import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/product_details_provider.dart';
import 'package:samagrah/views/after_login/product/product_details.dart';

class RatingSummaryWidget extends ConsumerWidget {
  final Ratings ratings;
  final String productId; // needed to open bottom sheet

  const RatingSummaryWidget({
    super.key,
    required this.ratings,
    required this.productId,
  });

  Color _getColor(int rating) {
    if (rating >= 4) return Colors.green;
    if (rating == 3) return Colors.amber;
    if (rating == 2) return Colors.orange;
    return Colors.red;
  }

  String _getLabel(int rating) {
    switch (rating) {
      case 5:
        return "Very Good";
      case 4:
        return "Good";
      case 3:
        return "Ok-Ok";
      case 2:
        return "Bad";
      default:
        return "Very Bad";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewState = ref.watch(reviewProvider);
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with View All ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Customer Reviews",
                style: text16(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => showReviewBottomSheet(context, ref, productId),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.button),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View All', style: text12(color: AppColors.button)),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10,
                        color: AppColors.button,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Summary row ───────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left rating box
              Container(
                width: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey300),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: const BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(14),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "${ratings.average ?? 0}",
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.white, size: 26),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Text(
                            "$total ratings",
                            style: text13(color: AppColors.grey700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${ratings.totalReviews ?? 0} reviews",
                            style: text13(color: AppColors.grey700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 14),

              /// Right bars
              Expanded(
                child: Column(
                  children: ratingMap.entries.map((entry) {
                    final progress = total == 0 ? 0.0 : entry.value / total;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 70,
                            child: Text(_getLabel(entry.key), style: text13()),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  _getColor(entry.key),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 40,
                            child: Text(
                              entry.value.toString(),
                              textAlign: TextAlign.end,
                              style: text12(color: AppColors.grey700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200),
          const SizedBox(height: 12),

          // ── Preview: last 2 reviews ───────────────────────────────────────
          if (reviewState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  color: AppColors.button,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (reviewState.reviews.isNotEmpty) ...[
            Text('Recent Reviews', style: text14(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...reviewState.reviews
                .take(2) // show only 2 preview reviews
                .map((r) => _PreviewReviewCard(review: r)),

            // View All reviews button
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => showReviewBottomSheet(context, ref, productId),
                child: Text(
                  'View all ${ratings.totalReviews ?? ''} reviews →',
                  style: text13(
                    color: AppColors.button,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ] else if (reviewState.error == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'No reviews yet',
                  style: text13(color: AppColors.grey600),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Preview card (compact, for product detail page) ─────────────────────────

class _PreviewReviewCard extends StatelessWidget {
  final rev.Review review;

  const _PreviewReviewCard({required this.review});

  Color _starColor(int? r) {
    if ((r ?? 0) >= 4) return Colors.green;
    if ((r ?? 0) == 3) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.button.withOpacity(0.15),
                child: Text(
                  (review.user?.name ?? 'U')[0].toUpperCase(),
                  style: text11(
                    color: AppColors.button,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.user?.name ?? 'Anonymous',
                  style: text12(fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _starColor(review.rating),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${review.rating ?? 0}',
                      style: text11(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.star_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: text12(color: AppColors.grey700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════════════════════
// FILE 2: In ProductDetails build() — replace bottom section
// Find:  if (product.ratings != null) RatingSummaryWidget(ratings: product.ratings!),
// Replace with the useEffect + updated widget call below
// ═══════════════════════════════════════════════════════════════════════════

// Step 1: Change ProductDetails to ConsumerStatefulWidget
// and add initState to fetch reviews on page open:

/*
class ProductDetails extends ConsumerStatefulWidget {
  const ProductDetails({super.key});

  @override
  ConsumerState<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<ProductDetails> {
  late Product product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    product = ModalRoute.of(context)!.settings.arguments as Product;
    // Fetch reviews once on page open (limit 3 for preview)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reviewProvider.notifier).fetchReviews(product.id ?? '', limit: 3);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... same as before, but change:

    // OLD:
    // if (product.ratings != null) RatingSummaryWidget(ratings: product.ratings!),

    // NEW:
    if (product.ratings != null)
      RatingSummaryWidget(
        ratings: product.ratings!,
        productId: product.id ?? '',
      ),
  }
}
*/