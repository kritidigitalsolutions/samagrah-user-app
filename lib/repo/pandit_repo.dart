import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';
import 'package:samagrah/model/response/pandit_res/temple_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';

class PanditRepo {
  final _api = NetworkApiService();

  // ================ Get ritual ========================

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  //  Get all ritual

  Future<RitualResModel> getRituals() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final city = await LocationStorage.getCity() ?? "Agra";
      final pincode = await LocationStorage.getPincode() ?? '';
      final res = await _api.getApi(
        "${AppUrls.rituals}?city=$city&pincode=$pincode",
      );
      return RitualResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // =========================  Get all pandit ==============================

  Future<PanditResModel> getPandit({String? city, String? pincode}) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final finalCity = city ?? await LocationStorage.getCity() ?? "Agra";
      final finalPincode = pincode ?? await LocationStorage.getPincode() ?? '';

      final res = await _api.getApi(
        "${AppUrls.pandit}?city=$finalCity&pincode=$finalPincode",
      );

      return PanditResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
  // =========================  Get availability ==============================

  Future<AvailabilityResModel> getAvailability(String panditId) async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi("${AppUrls.availability}/$panditId");
      return AvailabilityResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ========================= Get pandit slot booking ==============================

  Future<Map<String, dynamic>> getPrice() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.slotPanditBooking);
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // ========================= Get Temple ==============================

  Future<TempleResModel> getTemple() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.temple);
      return TempleResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ========================= Get Temple ==============================

  Future<PanditBookedResModel> getPnanditBooked() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.panditHistory);
      return PanditBookedResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ====================== booking cancel ====================================

  Future<bool> cancelBooking(String bookingId, String reason) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final uri = "${AppUrls.panditCreateOrder}/$bookingId/cancel";
      await _api.pacthApi(uri, {"reason": reason});
      return true;
    } catch (e) {
      print("cancel order  ${e.toString()}");
      return false;
    }
  }

  // ====================== booking reschedule ====================================

  Future<bool> bookingReschedule(
    String bookingId,
    PanditCreateOrderReqModel req,
  ) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final uri = "${AppUrls.panditCreateOrder}/$bookingId/reschedule";
      await _api.pacthApi(uri, req.toJson());
      return true;
    } catch (e) {
      print("cancel order  ${e.toString()}");
      return false;
    }
  }

  Future<dynamic> submitReview({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.postApi(
        AppUrls.panditBookingReview(
          bookingId,
        ), // '/api/pandit-bookings/$bookingId/review'
        {"rating": rating, "comment": comment},
      );
      return res;
    } catch (e) {
      print("❌ submitReview error: $e");
      rethrow;
    }
  }
}
