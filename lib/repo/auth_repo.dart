import 'package:samagrah/data/network/network_api_service.dart';
import 'package:samagrah/model/request/auth_models/user_request_model.dart';
import 'package:samagrah/model/response/auth_response/Auth_response.dart';
import 'package:samagrah/res/app_urls.dart';

class AuthRepository {
  final api = NetworkApiService();

  // ✅ REGISTER
  Future<UserRegisterResponseModel> register(UserRequestModel model) async {
    try {
      final res = await api.postApi(AppUrls.registerUser, model.toJson());
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
