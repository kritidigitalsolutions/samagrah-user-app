import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class NotificationRepo {
  final _api = NetworkApiService();

  Future<void> postFCMToken(String fcmToken) async {
    try {
      final token = await AuthLocalstorageService.getToken() ?? '';
      _api.setToken(token);
      await _api.pacthApi(AppUrls.fcmToken, {"fcmToken": fcmToken});
    } catch (e) {
      rethrow;
    }
  }
}
