import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
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
}
