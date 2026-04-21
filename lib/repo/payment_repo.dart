import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/payment_res/create_order_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class PaymentRepo {
  final _api = NetworkApiService();

  // ✅ CREATE ORDER
  Future<CreateOrderResModel> createOrder(CreateOrderReqModel req) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(AppUrls.createOrder, req.toJson());
      return CreateOrderResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ VERIFY PAYMENT
  Future<bool> verifyPayment(VerifyPaymentReqModel req) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(AppUrls.verifyPayment, req.toJson());

      return res["success"] == true;
    } catch (e) {
      rethrow;
    }
  }
}
