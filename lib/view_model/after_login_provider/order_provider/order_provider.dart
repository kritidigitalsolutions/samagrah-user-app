import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:intl/intl.dart';
import 'package:samagrah/model/response/product_booked_res/track_order_res_model.dart';
import 'package:samagrah/repo/booking_repo.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_state.dart';

final orderProvider = AsyncNotifierProvider<BookingNotifier, BookingState>(
  () => BookingNotifier(),
);

class BookingNotifier extends AsyncNotifier<BookingState> {
  final _repo = BookingRepo();

  @override
  Future<BookingState> build() async {
    debugPrint("🔥 BookingNotifier build called");
    return await _fetchOrders();
  }

  Future<BookingState> _fetchOrders() async {
    final res = await _repo.getOrders();
    return BookingState(orders: res);
  }

  // 🔄 Refresh API manually
  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    try {
      final data = await _fetchOrders();
      state = AsyncData(data);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

class OrderUtils {
  // Get status color based on order status
  static Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'delivered':
        return AppColors.green;
      case 'out for delivery':
      case 'shipped':
        return AppColors.borderFocus;
      case 'preparing':
      case 'processing':
      case 'confirmed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.errorDark;
      case 'placed':
        return Colors.amber;
      default:
        return AppColors.grey;
    }
  }

  // Get user-friendly status text
  static String getStatusText(String? status) {
    if (status == null) return 'Unknown';

    // Convert status to title case with proper spacing
    return status
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Format date to readable format
  static String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMMM dd, yyyy, HH:mm').format(date);
  }

  // Format date for order details page
  static String formatDateShort(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(date);
  }

  // Format currency
  static String formatCurrency(int? amount) {
    if (amount == null) return '₹0';
    return '₹$amount';
  }

  // Get order number from order ID
  static String getOrderNumber(String? orderId) {
    if (orderId == null || orderId.isEmpty) return '#0';
    // Use last 4 characters or a hash code
    return '#${orderId.substring(orderId.length > 4 ? orderId.length - 4 : 0)}';
  }

  // Check if order has multiple items
  static bool hasMultipleItems(Order order) {
    int totalItems = 0;
    for (var item in order.items) {
      // Count products in booked kits
      if (item.product?.items != null) {
        totalItems += item.product!.items.length;
      } else {
        totalItems += 1;
      }
    }
    return totalItems > 1;
  }

  // Get total item count
  static int getTotalItemCount(Order order) {
    int totalItems = 0;
    for (var item in order.items) {
      if (item.product?.items != null) {
        totalItems += item.product!.items.length;
      } else {
        totalItems += 1;
      }
    }
    return totalItems;
  }

  // Get full address string
  static String getFullAddress(Address? address) {
    if (address == null) return 'N/A';

    List<String> parts = [];
    if (address.fullAddress != null && address.fullAddress!.isNotEmpty) {
      parts.add(address.fullAddress!);
    }
    if (address.city != null && address.city!.isNotEmpty) {
      parts.add(address.city!);
    }
    if (address.state != null && address.state!.isNotEmpty) {
      parts.add(address.state!);
    }
    if (address.pincode != null && address.pincode!.isNotEmpty) {
      parts.add(address.pincode!);
    }

    return parts.join(', ');
  }
}

// track order

final trackOrderRepo = Provider((ref) => BookingRepo());

final trackOrderProvider = FutureProvider.family<TrackOrderResModel, String>((
  ref,
  id,
) async {
  final repo = ref.read(trackOrderRepo);
  return repo.trackOrder(id);
});
