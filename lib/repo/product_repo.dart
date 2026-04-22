import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class ProductRepo {
  final _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // ✅ REGISTER
  Future<ProductResModel> getProducts() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.getProduct);
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // my cart

  Future<ProductResModel> getMyCart() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.myCart);
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductResModel> addToCart() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.addCart);
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductResModel> removeToCart() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.removeCart);
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
