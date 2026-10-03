import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/model/response/product_booked_res/track_order_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class BookingRepo {
  final _api = NetworkApiService();

  // ======================= Product booking ===================

  Future<ProductBookedResModel> getOrders() async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.myOrder);
      return ProductBookedResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<TrackOrderResModel> trackOrder(String orderId) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final uri = "${AppUrls.order}/$orderId/tracking";
      final res = await _api.getApi(uri);
      return TrackOrderResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // order cancel

  Future<bool> cancelOrder(String orderId, String reason) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final uri = "${AppUrls.order}/$orderId/cancel";
      await _api.pacthApi(uri, {"reason": reason});
      return true;
    } catch (e) {
      print("cancel order  ${e.toString()}");
      return false;
    }
  }

  // =================== rating ===============================

  // order cancel

  Future<bool> postRating(String productId, int rate, String comments) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final uri = "${AppUrls.getProduct}/$productId/ratings";
      await _api.postApi(uri, {"rating": rate, "comment": comments});
      return true;
    } catch (e) {
      print("cancel order  ${e.toString()}");
      return false;
    }
  }
}
