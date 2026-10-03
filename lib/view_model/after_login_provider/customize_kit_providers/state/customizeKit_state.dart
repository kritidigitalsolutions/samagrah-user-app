import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';

class CustomizekitState {
  final DefaultKitResModel? defaultKit;
  final bool isLoading;
  final String? error;

  CustomizekitState({this.defaultKit, this.isLoading = false, this.error});

  CustomizekitState copyWith({
    DefaultKitResModel? defaultKit,

    bool? isLoading,
    String? error,
  }) {
    return CustomizekitState(
      defaultKit: defaultKit ?? this.defaultKit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
