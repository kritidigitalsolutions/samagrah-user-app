import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/repo/policy_repo.dart';
import 'package:samagrah/repo/profile_repo.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

final userProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = await AuthLocalstorageService.getToken();
  print(token);
  return await AuthLocalstorageService.getUser();
});

// ===================== edit profile ================================

final profileApiProvider = Provider((ref) => ProfileApi());

final updateProfileProvider =
    StateNotifierProvider<UpdateProfileNotifier, AsyncValue<void>>(
      (ref) => UpdateProfileNotifier(ref),
    );

class UpdateProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  UpdateProfileNotifier(this.ref) : super(const AsyncData(null));

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String address,
    File? imageFile,
  }) async {
    state = const AsyncLoading();

    try {
      final api = ref.read(profileApiProvider);
      final token = await AuthLocalstorageService.getToken() ?? '';

      final res = await api.updateProfile(
        userId: userId,
        name: name,
        email: email,
        address: address,
        imageFile: imageFile,
        token: token,
      );

      final updatedUser = res['data'];

      await AuthLocalstorageService.saveUser(
        token: token,
        userJson: {
          "phone": updatedUser['phone'],
          "name": updatedUser['name'],
          "email": updatedUser['email'],
          "address": updatedUser['address'],
          "profileImage": updatedUser['profileImage'],
          "isProfileComplete": updatedUser['isProfileComplete'],
          "id": updatedUser['_id'],
        },
      );

      /// 🔄 Refresh UI
      ref.invalidate(userProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// =============== delete account ============================

final deleteAccountProvider =
    StateNotifierProvider<DeleteAccountNotifier, AsyncValue<void>>(
      (ref) => DeleteAccountNotifier(PolicyRepo()),
    );

class DeleteAccountNotifier extends StateNotifier<AsyncValue<void>> {
  DeleteAccountNotifier(this._repository) : super(const AsyncData(null));

  final PolicyRepo _repository;

  Future<bool> deleteAccount(String reason) async {
    state = const AsyncLoading();

    try {
      await _repository.deleteAccount(reason);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
