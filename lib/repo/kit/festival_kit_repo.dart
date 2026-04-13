import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/kit_response/festival_kit_response.dart';
import 'package:samagrah/res/app_urls.dart';

class FestivalKitRepo {
  final _api = NetworkApiService();

  // ✅ REGISTER
  Future<FestivalKitResponse> getFestivalKits() async {
    try {
      final res = await _api.getApi(AppUrls.registerUser,);
      return FestivalKitResponse.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
