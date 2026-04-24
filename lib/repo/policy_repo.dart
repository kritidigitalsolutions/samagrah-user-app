import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/policy_res/aboutus_res_model.dart';
import 'package:samagrah/model/response/policy_res/policy_res_model.dart';
import 'package:samagrah/res/app_urls.dart';

class PolicyRepo {
  final _api = NetworkApiService();

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
}
