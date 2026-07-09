// lib/data/repository/product_repo.dart

import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/banner_res_model.dart';
import 'package:samagrah/model/response/product_booked_res/review_res_model.dart';
import 'package:samagrah/model/response/product_res/brands_res_model.dart';
import 'package:samagrah/model/response/product_res/cart_res_model.dart';
import 'package:samagrah/model/response/product_res/category_res_model.dart';
import 'package:samagrah/model/response/product_res/delivered_res_model.dart';
import 'package:samagrah/model/response/product_res/product_details_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/model/response/product_res/sub_category_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';

class ProductRepo {
  final _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // get category

  Future<CategoryResModel> getCategories() async {
    try {
      final city = await LocationStorage.getCity() ?? "Agra";
      final pincode = await LocationStorage.getPincode() ?? '';

      final res = await _api.getApi(
        '${AppUrls.category}?city=$city&pincode=$pincode',
      );
      return CategoryResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // get category

  Future<BrandsResModel> getBrands() async {
    try {
      final city = await LocationStorage.getCity() ?? "Agra";
      final pincode = await LocationStorage.getPincode() ?? '';
      final res = await _api.getApi(
        '${AppUrls.brands}?city=$city&pincode=$pincode',
      );
      return BrandsResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // 📦 Get all products
  Future<SubCategoryResModel> getSubCategories() async {
    try {
      final city = await LocationStorage.getCity() ?? "Agra";
      final pincode = await LocationStorage.getPincode() ?? '';
      final res = await _api.getApi(
        "${AppUrls.subCategories}?city=$city&pincode=$pincode",
      );
      return SubCategoryResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<ProductResModel> getProducts() async {
    try {
      final token = await _getToken();
      final city = await LocationStorage.getCity() ?? "Agra";
      final pincode = await LocationStorage.getPincode() ?? '';
      _api.setToken(token);
      final res = await _api.getApi(
        '${AppUrls.getProduct}?city=$city&pincode=$pincode',
      );
      return ProductResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // 🛒 Get user's cart from server
  Future<CartResModel> getMyCart() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.myCart);
      return CartResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ➕ Add to cart (with productId and quantity)
  Future<void> addToCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final body = {'productId': productId, 'quantity': quantity};

      await _api.postApi(AppUrls.addCart, body);
    } catch (e) {
      rethrow;
    }
  }

  // ❌ Remove from cart
  Future<void> removeFromCart({
    required String productId,
    required int quantity,
  }) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final body = {'productId': productId, 'quantity': quantity};

      await _api.postApi(AppUrls.removeCart, body);
    } catch (e) {
      rethrow;
    }
  }

  // // 🗑️ Delete cart
  Future<void> deleteCart({required String id}) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      await _api.deleteApi("${AppUrls.myCart}/$id", {});
    } catch (e) {
      rethrow;
    }
  }

  //   // 📦 Get product details
  Future<ProductDetailsResModel> productDetails(String productId) async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi("${AppUrls.getProduct}/$productId");
      return ProductDetailsResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  //   // 📦 Get product details
  Future<BannerResModel> getBanner() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.banner);
      return BannerResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // =======================  Review api ===========================

  Future<ReviewResModel> getReview(String id, int page, int limit) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final uri = '${AppUrls.getProduct}/$id/ratings?page=$page&limit=$limit';

      final res = await _api.getApi(uri);

      return ReviewResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // delivered charge

  Future<DeliveredResModel> getDeliveredCharge() async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.getApi(AppUrls.getDelivery);
      return DeliveredResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
