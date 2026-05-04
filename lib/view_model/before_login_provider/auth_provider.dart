import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/auth_models/user_request_model.dart';
import 'package:samagrah/repo/auth_repo.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/view_model/before_login_provider/auth_state.dart';

final phoneProvider = StateProvider<String>((ref) => '');

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _repo = AuthRepository();

  @override
  Future<AuthState> build() async {
    return AuthState();
  }

  // ✅ REGISTER
  // ✅ REGISTER
  Future<void> register({required UserRequestModel model}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.register(model);
      return state.value!.copyWith(
        registerModel: res,
        verifyModel: null, // ← clear others
        resendModel: null,
      );
    });
  }

  // 🔐 LOGIN
  Future<void> login({required String mobile}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.login(mobile);
      return state.value!.copyWith(
        registerModel: res,
        verifyModel: null, // ← clear others
        resendModel: null,
      );
    });
  }

  // 🔐 RESEND
  Future<void> resend({required String mobile}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.resendOtp(mobile);
      return state.value!.copyWith(
        resendModel: res,
        registerModel: null, // ← clear others
        verifyModel: null,
      );
    });
  }

  // 🔐 VERIFY OTP
  Future<void> verifyOtp({required String mobile, required String otp}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await _repo.verifyOtp(mobile, otp);
      if (res.success == true && res.data != null) {
        final token = res.data!.token ?? "";
        final user = res.data!.user;
        await AuthLocalstorageService.saveUser(
          token: token,
          userJson: {
            "phone": user?.phone,
            "name": user?.name,
            "email": user?.email,
            "address": user?.address,
            "profileImage": user?.profileImage,
            "isProfileComplete": user?.isProfileComplete,
            "id": user?.id,
          },
        );
      }
      return state.value!.copyWith(
        verifyModel: res,
        registerModel: null, // ← clear others
        resendModel: null,
      );
    });
  }

  void reset() {
    state = AsyncData(
      AuthState(),
    ); // ← clears registerModel, verifyModel, everything
  }
}

final otpProvider = StateProvider<List<String>>(
  (ref) => ['', '', '', '', '', ''],
);
