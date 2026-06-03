import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';

class CustomizeKitRepo {
  final _api = NetworkApiService();

  // //  // Default  kit

  Future<DefaultKitResModel> defaultKit() async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      final city = await LocationStorage.getCity();
      final res = await _api.getApi("${AppUrls.defaultKit}?city=$city");
      return DefaultKitResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
