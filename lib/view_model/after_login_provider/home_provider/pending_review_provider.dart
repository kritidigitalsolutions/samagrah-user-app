// lib/view_model/after_login_provider/order_provider/pending_review_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';

// ─── Model ────────────────────────────────────────────────────────────────────
class PendingReviewItem {
  final String orderId;
  final String razorpayOrderId;
  final String productId;
  final String productName;
  final String productImage;
  final String deliveredAt;
  final num quantity;
  final bool isKit;

  PendingReviewItem({
    required this.orderId,
    required this.razorpayOrderId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.deliveredAt,
    required this.quantity,
    this.isKit = false,
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

  final prefs = await SharedPreferences.getInstance();
  final dismissed = prefs.getStringList(_kDismissedKey) ?? [];

  final List<PendingReviewItem> result = [];

  for (final order in orders) {
    final status = (order.tracking?.currentStatus ?? order.orderStatus ?? '')
        .toLowerCase();
    if (status != 'delivered') continue;
    if (dismissed.contains(order.id)) continue;

    final isKit =
        order.items.isNotEmpty &&
        (order.items.first.product?.items.isNotEmpty ?? false);

    if (isKit) {
      final kitProduct = order.items.first.product;
      result.add(
        PendingReviewItem(
          orderId: order.id ?? '',
          razorpayOrderId: order.razorpayOrderId ?? '',
          productId: kitProduct?.id ?? '',
          productName: kitProduct?.name ?? kitProduct?.title ?? 'Kit',
          productImage: kitProduct?.media?.image.firstOrNull ?? '',
          deliveredAt: _formatDate(order.updatedAt ?? order.createdAt),
          quantity: order.items.first.quantity ?? 1,
          isKit: true,
        ),
      );
    } else {
      for (final item in order.items) {
        final product = item.product;
        result.add(
          PendingReviewItem(
            orderId: order.id ?? '',
            razorpayOrderId: order.razorpayOrderId ?? '',
            productId: product?.id ?? '',
            productName: product?.title ?? product?.name ?? 'Product',
            productImage: product?.media?.image.firstOrNull ?? '',
            deliveredAt: _formatDate(order.updatedAt ?? order.createdAt),
            quantity: item.quantity ?? 1,
          ),
        );
      }
    }
  }

  return result;
});

// ─── Dismiss action ──────────────────────────────────────────────────────────
final dismissReviewProvider =
    Provider<Future<void> Function(String orderId, WidgetRef ref)>(
      (ref) => (orderId, ref) async {
        final prefs = await SharedPreferences.getInstance();
        final dismissed = prefs.getStringList(_kDismissedKey) ?? [];
        if (!dismissed.contains(orderId)) {
          dismissed.add(orderId);
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
