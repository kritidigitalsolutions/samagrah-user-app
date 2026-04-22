import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/checkout/address_req_model.dart';
import 'package:samagrah/model/response/address_res/address_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class AddressRepo {
  final _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // // ✅ GET Addresses
  Future<AddressResModel> getAddress() async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.getApi(AppUrls.address);
      return AddressResModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // ✅ POST Address
  Future<void> postAddress(AddressReqModel model) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      await _api.postApi(AppUrls.address, model.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // // ✅ UPDATE Address
  Future<void> updateAddress(String id, AddressReqModel model) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      await _api.pacthApi("${AppUrls.address}/$id", model.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // // ✅ UPDATE Address
  Future<void> deleteAddress(String id) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      await _api.deleteApi("${AppUrls.address}/$id", {});
    } catch (e) {
      rethrow;
    }
  }
}
