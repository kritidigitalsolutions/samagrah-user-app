import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';

class PanditState {
  final List<PanditData> pandit;

  final List<PanditData> searchResults;

  final bool isLoading;
  final String? error;

  PanditState({
    this.pandit = const [],

    this.searchResults = const [],

    this.isLoading = false,

    this.error,
  });

  PanditState copyWith({
    List<PanditData>? pandit,

    List<PanditData>? searchResults, // ← New

    bool? isLoading,
    String? error,
  }) {
    return PanditState(
      pandit: pandit ?? this.pandit,

      searchResults: searchResults ?? this.searchResults, // ← New

      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
