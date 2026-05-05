// lib/data/repository/notification_repo.dart

import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

import '../model/response/notification_list_res.dart';

class NotificationRepo {
  final _api = NetworkApiService();

  Future<void> _setAuth() async {
    final token = await AuthLocalstorageService.getToken() ?? '';
    _api.setToken(token);
  }

  Future<void> postFCMToken(String fcmToken) async {
    try {
      await _setAuth();
      await _api.pacthApi(AppUrls.fcmToken, {"fcmToken": fcmToken});
    } catch (e) {
      rethrow;
    }
  }

  Future<NotificationListResponse> getNotifications({
    String status = 'all',
    int page = 1,
    int limit = 20,
  }) async {
    try {
      await _setAuth();
      final res = await _api.getApi(
        '${AppUrls.notifications}?status=$status&page=$page&limit=$limit',
      );
      return NotificationListResponse.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _setAuth();
      await _api.pacthApi(AppUrls.notificationRead(id), {});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _setAuth();
      await _api.deleteApi(AppUrls.notificationDelete(id),{});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _setAuth();
      await _api.deleteApi(AppUrls.notifications, {});
    } catch (e) {
      rethrow;
    }
  }
}