import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';

// Existing provider
final typeSelected = StateProvider<String>((ref) => "home");

// Repository provider
final panditRepoProvider = Provider((ref) => PanditRepo());

// API provider for fetching bookings
final panditBookingProvider = FutureProvider<PanditBookedResModel>((ref) async {
  final repo = ref.read(panditRepoProvider);
  return repo.getPnanditBooked();
});

// Provider to hold selected booking for details page
final selectedBookingProvider = StateProvider<Datum?>((ref) => null);

final selectedCancelReasonProvider = StateProvider<String?>((ref) => null);

// ==================== cancel booking ===================================

final cancelBookingProvider =
    StateNotifierProvider<CancelBookingNotifier, AsyncValue<bool>>((ref) {
      return CancelBookingNotifier();
    });

class CancelBookingNotifier extends StateNotifier<AsyncValue<bool>> {
  CancelBookingNotifier() : super(const AsyncData(false));

  final PanditRepo _repository = PanditRepo();

  Future<bool> cancelOrder(String orderId, String reason) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.cancelBooking(orderId, reason);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // =========== reschedule ================================

  Future<bool> bookingReschedule(
    String bookingId,
    PanditCreateOrderReqModel req,
  ) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.bookingReschedule(bookingId, req);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

// ========================== Reschedule booking ============================

final rescheduleBookingProvider =
    StateNotifierProvider<RescheduleBookingNotifier, AsyncValue<bool>>((ref) {
      return RescheduleBookingNotifier();
    });

class RescheduleBookingNotifier extends StateNotifier<AsyncValue<bool>> {
  RescheduleBookingNotifier() : super(const AsyncData(false));

  final PanditRepo _repository = PanditRepo();

  // =========== reschedule ================================

  Future<bool> bookingReschedule(
    String bookingId,
    PanditCreateOrderReqModel req,
  ) async {
    state = const AsyncLoading();

    try {
      final result = await _repository.bookingReschedule(bookingId, req);
      state = AsyncData(result);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
