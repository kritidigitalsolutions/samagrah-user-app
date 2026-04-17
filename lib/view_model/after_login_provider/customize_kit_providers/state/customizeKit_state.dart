import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';

class CustomizekitState {
  final UserDraftKitResModel? userKit; // 👈 model 1
  final DefaultKitResModel? defaultKit;
  final String? kitId;
  final bool isLoading;
  final String? error;

  CustomizekitState({
    this.userKit,
    this.defaultKit,
    this.isLoading = false,
    this.error,
    this.kitId,
  });

  CustomizekitState copyWith({
    UserDraftKitResModel? userKit,
    DefaultKitResModel? defaultKit,
    String? kitId,
    bool? isLoading,
    String? error,
  }) {
    return CustomizekitState(
      userKit: userKit ?? this.userKit,
      defaultKit: defaultKit ?? this.defaultKit,
      kitId: kitId ?? this.kitId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
