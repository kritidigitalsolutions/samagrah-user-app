// lib/views/custom_widget/pending_review_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/pending_review_provider.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';
import 'package:samagrah/views/after_login/order/order_details_screen.dart';

class PendingReviewCard extends ConsumerWidget {
  final PendingReviewItem item;

  const PendingReviewCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFAC775), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFAC775).withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top amber banner ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8EF),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.isPanditBooking
                            ? 'Your pooja was completed!'
                            : 'Your order was delivered!',
                        style: text13(
                          color: const Color(0xFF854F0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.isPanditBooking
                            ? 'Rate your experience'
                            : 'Tell us how it was',
                        style: text11(color: const Color(0xFFBA7517)),
                      ),
                    ],
                  ),
                ),
                // Dismiss button
                GestureDetector(
                  onTap: () async {
                    final dismiss = ref.read(dismissReviewProvider);
                    await dismiss(item.reviewKey, ref);
                  },
                  child: Icon(Icons.close, size: 18, color: AppColors.grey600),
                ),
              ],
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivered badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3DE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF639922),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      // Text(
                      //   'Delivered · ${item.deliveredAt}',
                      //   style: text11(
                      //     color: const Color(0xFF3B6D11),
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Product row
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomCachedImage(imageUrl: item.image),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: text14(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            item.subtitle,
                            style: text11(color: AppColors.grey600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Text(
                          //   '${item.razorpayOrderId} · Qty: ${item.quantity}',
                          //   style: text11(color: AppColors.grey600),
                          // ),
                          const SizedBox(height: 6),
                          // Inline star row
                          _QuickStarRow(item: item),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openRatingSheet(context, ref),
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF9F27),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Rate Now',
                            style: text13(
                              color: const Color(0xFF412402),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final dismiss = ref.read(dismissReviewProvider);
                          await dismiss(item.reviewKey, ref);
                        },
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Maybe Later',
                            style: text13(color: AppColors.grey600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openRatingSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RatingBottomSheet(
        orderId: item.sourceId,
        title: item.isPanditBooking ? 'Rate this Pooja' : 'Rate this Product',
        isPanditBooking: item.isPanditBooking, // 🔥 yeh line add karo
        item: ProductDisplayItem(
          name: item.title,
          emoji: item.image,
          quantity: item.quantity,
          price: 0,
          productId: item.reviewTargetId,
        ),
        onSubmitted: () async {
          final dismiss = ref.read(dismissReviewProvider);
          await dismiss(item.reviewKey, ref);
        },
      ),
    );
  }
}

// ── Quick 5-star selector inside the card ────────────────────────────────────
class _QuickStarRow extends ConsumerStatefulWidget {
  final PendingReviewItem item;
  const _QuickStarRow({required this.item});

  @override
  ConsumerState<_QuickStarRow> createState() => _QuickStarRowState();
}

class _QuickStarRowState extends ConsumerState<_QuickStarRow> {
  int _hovered = 0;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final val = i + 1;
        final filled = val <= (_hovered > 0 ? _hovered : _selected);
        return GestureDetector(
          onTap: () {
            setState(() => _selected = val);
            // slight delay then open full rating sheet
            Future.delayed(const Duration(milliseconds: 200), () {
              if (!mounted) return;
              _openRatingWithStar(context, val);
            });
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => _hovered = val),
            onExit: (_) => setState(() => _hovered = 0),
            child: Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 22,
                color: filled ? const Color(0xFFEF9F27) : AppColors.grey300,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _openRatingWithStar(BuildContext context, int preselected) {
    // Pre-select the rating then open sheet
    ref.read(selectedRatingProvider.notifier).state = preselected;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RatingBottomSheet(
        orderId: widget.item.sourceId,
        title: widget.item.isPanditBooking
            ? 'Rate this Pooja'
            : 'Rate this Product',
        item: ProductDisplayItem(
          name: widget.item.title,
          emoji: widget.item.image,
          quantity: widget.item.quantity,
          price: 0,
          productId: widget.item.reviewTargetId,
        ),
        onSubmitted: () async {
          final dismiss = ref.read(dismissReviewProvider);
          await dismiss(widget.item.reviewKey, ref);
        },
      ),
    );
  }
}
