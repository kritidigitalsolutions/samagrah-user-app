import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/policy_res/aboutus_res_model.dart';
import 'package:samagrah/model/response/policy_res/policy_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class PolicyRepo {
  final _api = NetworkApiService();
  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // ✅ term api
  Future<PolicyResModel> getTerm() async {
    try {
      final res = await _api.getApi(AppUrls.term);
      return PolicyResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // privacy api
  Future<PolicyResModel> getPrivacy() async {
    try {
      final res = await _api.getApi(AppUrls.privacy);
      return PolicyResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // privacy api
  Future<AboutusResModel> getAboutUs() async {
    try {
      final res = await _api.getApi(AppUrls.aboutUs);
      return AboutusResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // delete account

  Future<void> deleteAccount(String reason) async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      await _api.postApi(AppUrls.deleteAccount, {"reason": reason});
    } catch (e) {
      rethrow;
    }
  }
}
