// repository/complaint_repo.dart
import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/response/complaint_res_model.dart';
import 'package:samagrah/res/app_urls.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class ComplaintRepo {
  final NetworkApiService _api = NetworkApiService();

  Future<String> _getToken() async {
    return await AuthLocalstorageService.getToken() ?? '';
  }

  // 📝 POST Complaint
  Future<Complaint> raiseComplaint({
    required String orderId,
    required String issue,
    required String details,
  }) async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.postApi(AppUrls.complaints, {
        "orderId": orderId,
        "issue": issue,
        "details": details,
      });

      return Complaint.fromJson(res['data']);
    } catch (e) {
      print("❌ raiseComplaint error: $e");
      rethrow;
    }
  }

  // 🔄 GET Complaints
  Future<List<Complaint>> getComplaints() async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.getApi(AppUrls.complaints);
      final List data = res['data'] ?? [];
      return data.map((e) => Complaint.fromJson(e)).toList();
    } catch (e) {
      print("❌ getComplaints error: $e");
      rethrow;
    }
  }

  // 📞 GET Support Settings
  Future<SupportSettings> getSupportSettings() async {
    try {
      final token = await _getToken();
      _api.setToken(token);

      final res = await _api.getApi(AppUrls.supportSettings);
      return SupportSettings.fromJson(res['data']);
    } catch (e) {
      print("❌ getSupportSettings error: $e");
      rethrow;
    }
  }
}
