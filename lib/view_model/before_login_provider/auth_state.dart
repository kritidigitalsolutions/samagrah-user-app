import 'package:samagrah/model/response/auth_response/Auth_response.dart';

// ← Sentinel to distinguish "not passed" from "explicitly null"
const _sentinel = Object();

class AuthState {
  final UserRegisterResponseModel? registerModel;
  final VerifyOtpResponseModel? verifyModel;
  final UserRegisterResponseModel? resendModel;
  final bool isLoading;
  final String? error;

  AuthState({
    this.registerModel,
    this.verifyModel,
    this.resendModel,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    Object? registerModel = _sentinel,
    Object? verifyModel = _sentinel,
    Object? resendModel = _sentinel,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      registerModel: registerModel == _sentinel
          ? this.registerModel
          : registerModel as UserRegisterResponseModel?,
      verifyModel: verifyModel == _sentinel
          ? this.verifyModel
          : verifyModel as VerifyOtpResponseModel?,
      resendModel: resendModel == _sentinel
          ? this.resendModel
          : resendModel as UserRegisterResponseModel?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
