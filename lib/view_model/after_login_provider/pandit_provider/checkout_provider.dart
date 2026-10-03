import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/response/address_res/address_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/temple_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/service_selection_screen.dart';

// Pandit selection

final selectedPanditProvider = StateProvider<PanditData?>((ref) => null);

// service selection
final serviceSelected = StateProvider<int?>((ref) => null);
final selectedServiceProvider = StateProvider<ServiceModel?>((ref) => null);

// temple selection

final selectedTempleIdProvider = StateProvider<String?>((ref) => null);

// date and time slot select

final selectedDateProvider = StateProvider<List<Map<String, String>>>(
  (ref) => [],
);

// address selected

final selectedAddressProvider = StateProvider<AddressRes?>((ref) => null);

final selectedOnlineProvider = StateProvider<OnlineDetails?>((ref) => null);

final panditRepoProvider = Provider((ref) => PanditRepo());

final templeProvider = FutureProvider<TempleResModel>((ref) async {
  final repo = ref.read(panditRepoProvider);
  return repo.getTemple();
});

// wallet_provider.dart
final useWalletProvider = StateProvider<bool>((ref) => false);

final walletBalanceProvider = FutureProvider<double>((ref) async {
  // Replace with your actual API call
  // final res = await YourApiService().getWalletBalance();
  // return res.balance;
  return 350.0; // placeholder
});
