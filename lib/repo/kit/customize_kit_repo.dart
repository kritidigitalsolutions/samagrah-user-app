import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class CustomizeKitRepo {
  final _api = NetworkApiService();

  // ✅ Get festival
  Future<Map<String, dynamic>> createCustoizeKits(
    CreateKitRequest model,
  ) async {
    try {
      final res = await _api.postApi(AppUrls.userKit, model.toJson());
      return res;
    } catch (e) {
      rethrow;
    }
  }

  // search kit

  Future<UserDraftKitResModel> getMyKit() async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.getMyKit);
      return UserDraftKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
