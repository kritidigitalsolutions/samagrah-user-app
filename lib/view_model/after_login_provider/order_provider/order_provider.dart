import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:intl/intl.dart';
import 'package:samagrah/model/response/product_booked_res/track_order_res_model.dart';
import 'package:samagrah/repo/booking_repo.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
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
        return AppColors.info;
      case 'preparing':
      case 'processing':
      case 'confirmed':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
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
  static String formatCurrency(num? amount) {
    if (amount == null) return '₹0';
    return '₹$amount';
  }

  // // Get order number from order ID
  // static String getOrderNumber(String? orderId) {
  //   if (orderId == null || orderId.isEmpty) return '#0';
  //   // Use last 4 characters or a hash code
  //   return '#${orderId.substring(orderId.length > 4 ? orderId.length - 4 : 0)}';
  // }

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

// cancel order

final selectedCancelReasonProvider = StateProvider<String?>((ref) => null);

final cancelOrderProvider =
    StateNotifierProvider<CancelOrderNotifier, AsyncValue<bool>>((ref) {
      return CancelOrderNotifier();
    });

class CancelOrderNotifier extends StateNotifier<AsyncValue<bool>> {
  CancelOrderNotifier() : super(const AsyncData(false));

  final BookingRepo _repository = BookingRepo();

  Future<bool> cancelOrder(String orderId, String reason) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.cancelOrder(orderId, reason);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// rating ========================

final selectedRatingProvider = StateProvider<int>((ref) => 0);

final ratingOrderProvider =
    StateNotifierProvider<RatingOrderNotifier, AsyncValue<bool>>((ref) {
      return RatingOrderNotifier();
    });

class RatingOrderNotifier extends StateNotifier<AsyncValue<bool>> {
  RatingOrderNotifier() : super(const AsyncData(false));

  final BookingRepo _repository = BookingRepo();

  Future<bool> postRating(String productId, int rate, String comment) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.postRating(productId, rate, comment);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// ── Invoice State ─────────────────────────────────────────────

enum InvoiceStatus { idle, downloading, done, error }

class InvoiceState {
  final InvoiceStatus status;
  final double progress;
  final String? errorMsg;

  const InvoiceState({
    this.status = InvoiceStatus.idle,
    this.progress = 0,
    this.errorMsg,
  });

  InvoiceState copyWith({
    InvoiceStatus? status,
    double? progress,
    String? errorMsg,
  }) => InvoiceState(
    status: status ?? this.status,
    progress: progress ?? this.progress,
    errorMsg: errorMsg ?? this.errorMsg,
  );
}

final invoiceProvider =
    StateNotifierProvider.autoDispose<InvoiceNotifier, InvoiceState>(
      (ref) => InvoiceNotifier(ref),
    );

class InvoiceNotifier extends StateNotifier<InvoiceState> {
  final Ref _ref;
  InvoiceNotifier(this._ref) : super(const InvoiceState());

  Future<void> downloadAndOpen(String orderId) async {
    if (state.status == InvoiceStatus.downloading) return;
    state = state.copyWith(status: InvoiceStatus.downloading, progress: 0);

    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      final url = '${AppUrls.baseUrl}/order/$orderId/invoice';
      debugPrint('Invoice URL: $url');
      debugPrint('Token: $token');

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/invoice_$orderId.pdf';

      // ── 1. Download with Bearer header ──
      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            state = state.copyWith(
              status: InvoiceStatus.downloading,
              progress: received / total,
            );
          }
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

      state = state.copyWith(status: InvoiceStatus.done, progress: 1.0);

      await OpenFilex.open(filePath);
    } catch (e) {
      debugPrint('Invoice error: $e');
      state = state.copyWith(
        status: InvoiceStatus.error,
        errorMsg: 'Could not download invoice. Tap to retry.',
      );
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) state = const InvoiceState();
    }
  }
}
