import 'package:dio/dio.dart';
import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/auth_models/user_request_model.dart';
import 'package:samagrah/model/response/auth_response/Auth_response.dart';
import 'package:samagrah/res/app_urls.dart';

class AuthRepository {
  final api = NetworkApiService();

  // ✅ REGISTER

  Future<FormData> _buildFormData(UserRequestModel model) async {
    final map = <String, dynamic>{"name": model.name, "phone": model.phone};

    if (model.email != null) {
      map["email"] = model.email;
    }

    if (model.address != null) {
      map["address"] = model.address;
    }

    /// HANDLE IMAGE FILE (IMPORTANT)
    if (model.profileImage != null && model.profileImage!.isNotEmpty) {
      map["profileImage"] = await MultipartFile.fromFile(
        model.profileImage!,
        filename: model.profileImage!.split('/').last,
      );
    }

    return FormData.fromMap(map);
  }

  Future<UserRegisterResponseModel> register(UserRequestModel model) async {
    try {
      final formData = await _buildFormData(model);

      final res = await api.postApi(AppUrls.registerUser, formData);

      return UserRegisterResponseModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // 📱 SEND OTP
  Future<UserRegisterResponseModel> login(String mobile) async {
    try {
      final res = await api.postApi(AppUrls.login, {"phone": mobile});
      return UserRegisterResponseModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // resend otp
  Future<UserRegisterResponseModel> resendOtp(String mobile) async {
    try {
      final res = await api.postApi(AppUrls.resendOtp, {"phone": mobile});
      return UserRegisterResponseModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  // 🔐 VERIFY OTP
  Future<VerifyOtpResponseModel> verifyOtp(String mobile, String otp) async {
    try {
      final res = await api.postApi(AppUrls.verifyOtp, {
        "phone": mobile,
        "otp": otp,
      });

      return VerifyOtpResponseModel.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }
}
