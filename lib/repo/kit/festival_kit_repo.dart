import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/res/app_urls.dart';

class FestivalKitRepo {
  final _api = NetworkApiService();

  // ✅ Get festival
  Future<DefaultKitResModel> getFestivalKits() async {
    try {
      final res = await _api.getApi(AppUrls.festivalKit);
      return DefaultKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // search kit

  Future<DefaultKitResModel> searchFestivalKits(String type) async {
    try {
      final uri = "${AppUrls.festivalKit}?search=$type";
      final res = await _api.getApi(uri);
      return DefaultKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
