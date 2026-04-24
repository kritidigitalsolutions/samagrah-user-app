import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class PanditRepo {
  final _api = NetworkApiService();

  // ================ Get ritual ========================

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  //  Get all ritual
  Future<RitualResModel> getRituals() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.rituals);
      return RitualResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // =========================  Get all pandit ==============================

  Future<PanditResModel> getPandit() async {
    try {
      final token = await _getToken();
      _api.setToken(token);
      final res = await _api.getApi(AppUrls.pandit);
      return PanditResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
