import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';

class CustomizekitState {
  final UserDraftKitResModel? userKit; // 👈 model 1
  final String? kitId;
  final bool isLoading;
  final String? error;

  CustomizekitState({
    this.userKit,
    this.isLoading = false,
    this.error,
    this.kitId,
  });

  CustomizekitState copyWith({
    UserDraftKitResModel? userKit,
    String? kitId,
    bool? isLoading,
    String? error,
  }) {
    return CustomizekitState(
      userKit: userKit ?? this.userKit,
      kitId: kitId ?? this.kitId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
