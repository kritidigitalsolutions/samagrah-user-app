import 'package:samagrah/model/response/address_res/address_res_model.dart';

class AddressState {
  final bool isLoading;
  final String? error;
  final AddressResModel? addresses;
  final AddressRes? selectedAddress;
  final bool isSaved;

  AddressState({
    this.isLoading = false,
    this.error,
    this.addresses,
    this.selectedAddress,
    this.isSaved = false,
  });

  AddressState copyWith({
    bool? isLoading,
    String? error,
    AddressResModel? addresses,
    AddressRes? selectedAddress,
    bool? isSaved,
  }) {
    return AddressState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
