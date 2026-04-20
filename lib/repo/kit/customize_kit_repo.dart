import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class CustomizeKitRepo {
  final _api = NetworkApiService();

  // ✅ Get festival
  Future<UserKitResModel> createCustoizeKits(CreateKitRequest model) async {
    try {
      final res = await _api.postApi(AppUrls.userKit, model.toJson());
      return UserKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // my kit history

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

  Future<void> deleteMyKit(String id) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      await _api.deleteApi("${AppUrls.userKit}/$id", {});
    } catch (e) {
      rethrow;
    }
  }

  //  // Default  kit

  Future<DefaultKitResModel> defaultKit() async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.defaultKit);
      return DefaultKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
