import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/payment_res/create_order_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class PaymentRepo {
  final _api = NetworkApiService();

  // ================ product page payment ========================

  // ✅ CREATE ORDER
  Future<CreateOrderResModel> productCreateOrder(
    CreateOrderReqModel req,
  ) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(AppUrls.productCreateOrder, req.toJson());
      return CreateOrderResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ VERIFY PAYMENT
  Future<bool> productVerifyPayment(VerifyPaymentReqModel req) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(
        AppUrls.productVerifyPayment,
        req.toJson(),
      );

      return res["success"] == true;
    } catch (e) {
      rethrow;
    }
  }

  // ================ product page payment ========================

  // ✅ CREATE ORDER
  Future<Map<String, dynamic>> panditCreateOrder(
    PanditCreateOrderReqModel req,
  ) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(AppUrls.panditCreateOrder, req.toJson());
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // ✅ VERIFY PAYMENT
  Future<bool> panditVerifyPayment({
    required String id,
    required String razorpayOrderId,
    required String paymentId,
    required String razorpaySignature,
  }) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.postApi(
        "${AppUrls.panditCreateOrder}/$razorpayOrderId/confirm-payment",
        {
          "razorpayOrderId": razorpayOrderId,
          "razorpayPaymentId": paymentId,
          "razorpaySignature": razorpaySignature,
          "bookingIntentToken": id,
        },
      );

      return res["success"] == true;
    } catch (e) {
      rethrow;
    }
  }
}
