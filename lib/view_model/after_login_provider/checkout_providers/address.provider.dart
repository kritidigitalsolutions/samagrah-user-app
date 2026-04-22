import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/checkout/address_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/address_res/address_res_model.dart';
import 'package:samagrah/repo/address_repo.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/state/address_state.dart';

final storeAddressProvider = StateProvider<Address?>((ref) => null);
final bookingItemProvider = StateProvider<List<VerifyItem>>((ref) => []);
final totalPrice = StateProvider<num>((ref) => 0);

// ====================== address store get update=====================

final saveAddressProvider = StateProvider<bool>((ref) => false);
final showFormProvider = StateProvider<bool>((ref) => false);
final isEditProvider = StateProvider<bool>((ref) => false);
final selectedAddressType = StateProvider<String>((ref) => "work");
final addressIdProvider = StateProvider<String>((ref) => "");

final addressProvider = AsyncNotifierProvider<AddressNotifier, AddressState>(
  () => AddressNotifier(),
);

class AddressNotifier extends AsyncNotifier<AddressState> {
  final _repo = AddressRepo();

  @override
  Future<AddressState> build() async {
    return await fetchAddresses();
  }

  Future<AddressState> fetchAddresses() async {
    try {
      final res = await _repo.getAddress();

      return AddressState(addresses: res);
    } catch (e) {
      return AddressState(error: e.toString());
    }
  }

  // ✅ Select Address
  void selectAddress(AddressRes? address) {
    state = AsyncData(state.value!.copyWith(selectedAddress: address));
  }

  // ✅ Add Address
  Future<void> addAddress(AddressReqModel model) async {
    state = const AsyncLoading();

    try {
      await _repo.postAddress(model);

      final updated = await fetchAddresses();
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ✅ Update Address
  Future<void> updateAddress(String id, AddressReqModel model) async {
    state = const AsyncLoading();

    try {
      await _repo.updateAddress(id, model);

      final updated = await fetchAddresses();
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // ✅ Delete Address
  Future<void> deleteAddress(String id) async {
    state = const AsyncLoading();

    try {
      await _repo.deleteAddress(id);

      final updated = await fetchAddresses();
      state = AsyncData(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
