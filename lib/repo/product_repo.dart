import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_urls.dart';

class ProductRepo {
  final _api = NetworkApiService();

  // ✅ REGISTER
  Future<ProductResModel> getProducts() async {
    try {
      final res = await _api.getApi(AppUrls.getProduct);
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
