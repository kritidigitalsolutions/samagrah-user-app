import 'package:samagrah/model/response/auth_response/Auth_response.dart';

class AuthState {
  final UserRegisterResponseModel? registerModel; // 👈 model 1
  final VerifyOtpResponseModel? verifyModel; // 👈 model 2
  final bool isLoading;
  final String? error;

  AuthState({
    this.registerModel,
    this.verifyModel,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserRegisterResponseModel? registerModel,
    VerifyOtpResponseModel? verifyModel,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      registerModel: registerModel ?? this.registerModel,
      verifyModel: verifyModel ?? this.verifyModel,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
