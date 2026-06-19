// lib/view_model/after_login_provider/order_provider/pending_review_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class PendingReviewItem {
  final String reviewKey;
  final String sourceId;
  final String razorpayOrderId;
  final String reviewTargetId;
  final String title;
  final String subtitle;
  final String image;
  final String deliveredAt;
  final num quantity;
  final bool isKit;
  final bool isPanditBooking;

  PendingReviewItem({
    required this.reviewKey,
    required this.sourceId,
    required this.razorpayOrderId,
    required this.reviewTargetId,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.deliveredAt,
    required this.quantity,
    this.isKit = false,
    this.isPanditBooking = false,
  });
}

// ─── SharedPrefs key ─────────────────────────────────────────────────────────
const _kDismissedKey = 'dismissed_review_orders';

// ─── Provider ─────────────────────────────────────────────────────────────────
final pendingReviewProvider = FutureProvider<List<PendingReviewItem>>((
  ref,
) async {
  final ordersAsync = await ref.watch(orderProvider.future);
  final orders = ordersAsync.orders?.data?.orders ?? [];
  final panditBookings = await ref.watch(panditBookingProvider.future);

  final prefs = await SharedPreferences.getInstance();
  final dismissed = prefs.getStringList(_kDismissedKey) ?? [];

  final List<PendingReviewItem> result = [];

  for (final order in orders) {
    final status = (order.tracking?.currentStatus ?? order.orderStatus ?? '')
        .toLowerCase();
    if (status != 'delivered') continue;

    final isKit =
        order.items.isNotEmpty &&
        (order.items.first.product?.items.isNotEmpty ?? false);

    if (isKit) {
      final kitProduct = order.items.first.product;
      final reviewKey = _reviewKey('order', order.id, kitProduct?.id);
      if (_isDismissed(dismissed, reviewKey, order.id)) continue;
      result.add(
        PendingReviewItem(
          reviewKey: reviewKey,
          sourceId: order.id ?? '',
          razorpayOrderId: order.razorpayOrderId ?? '',
          reviewTargetId: kitProduct?.id ?? '',
          title: kitProduct?.name ?? kitProduct?.title ?? 'Kit',
          subtitle: 'Your order was delivered!',
          image: kitProduct?.media?.image.firstOrNull ?? '',
          deliveredAt: _formatDate(order.updatedAt ?? order.createdAt),
          quantity: order.items.first.quantity ?? 1,
          isKit: true,
        ),
      );
    } else {
      for (final item in order.items) {
        final product = item.product;
        final reviewKey = _reviewKey('order', order.id, product?.id);
        if (_isDismissed(dismissed, reviewKey, order.id)) continue;
        result.add(
          PendingReviewItem(
            reviewKey: reviewKey,
            sourceId: order.id ?? '',
            razorpayOrderId: order.razorpayOrderId ?? '',
            reviewTargetId: product?.id ?? '',
            title: product?.title ?? product?.name ?? 'Product',
            subtitle: 'Your order was delivered!',
            image: product?.media?.image.firstOrNull ?? '',
            deliveredAt: _formatDate(order.updatedAt ?? order.createdAt),
            quantity: item.quantity ?? 1,
          ),
        );
      }
    }
  }

  for (final booking in panditBookings.data) {
    final status = (booking.bookingStatus ?? '').toLowerCase();
    if (status != 'completed') continue;

    final pandit = booking.pandit;
    final reviewKey = _reviewKey('pandit', booking.id, pandit?.id);
    if (_isDismissed(dismissed, reviewKey, booking.id)) continue;

    final ritualName =
        booking.ritual?.name ?? booking.ritualRef?.title ?? 'Pooja';

    result.add(
      PendingReviewItem(
        reviewKey: reviewKey,
        sourceId: booking.id ?? '',
        razorpayOrderId: booking.payment?.razorpayOrderId ?? '',
        reviewTargetId: pandit?.id ?? '',
        title: pandit?.fullName ?? 'Pandit Ji',
        subtitle: '$ritualName completed',
        image: pandit?.profileImage ?? booking.ritual?.image ?? '',
        deliveredAt: _formatDate(booking.updatedAt ?? booking.createdAt),
        quantity: 1,
        isPanditBooking: true,
      ),
    );
  }

  return result;
});

// ─── Dismiss action ──────────────────────────────────────────────────────────
final dismissReviewProvider =
    Provider<Future<void> Function(String reviewKey, WidgetRef ref)>(
      (ref) => (reviewKey, ref) async {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getStringList(_kDismissedKey) ?? [];
        if (!dismissed.contains(reviewKey)) {
          dismissed.add(reviewKey);
          await prefs.setStringList(_kDismissedKey, dismissed);
        }
        ref.invalidate(pendingReviewProvider);
      },
    );

String _formatDate(DateTime? dt) {
  // String? ki jagah DateTime?
  if (dt == null) return '';
  try {
    final local = dt.toLocal();
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[local.month]} ${local.day}';
  } catch (_) {
    return '';
  }
}

String _reviewKey(String type, String? sourceId, String? targetId) {
  return '$type:${sourceId ?? ''}:${targetId ?? ''}';
}

bool _isDismissed(List<String> dismissed, String reviewKey, String? legacyKey) {
  return dismissed.contains(reviewKey) ||
      (legacyKey != null && dismissed.contains(legacyKey));
}
