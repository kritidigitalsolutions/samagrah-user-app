import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/product_res/cart_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class WishlistRepo {
  final NetworkApiService _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // 🔄 GET Wishlist
  Future<CartResModel> getWishlist() async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.getApi(AppUrls.wishlist);

      return CartResModel.fromJson(res);
    } catch (e) {
      print("❌ getWishlist error: $e");
      rethrow; // 🔥 important so provider handle kar sake
    }
  }

  // ❤️ TOGGLE Wishlist
  Future<void> toggleWishlist(String productId) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      await _api.postApi(AppUrls.wishlistToggle, {"productId": productId});
    } catch (e) {
      print("❌ toggleWishlist error: $e");
      rethrow; // 🔥 rollback ke liye important
    }
  }
}
