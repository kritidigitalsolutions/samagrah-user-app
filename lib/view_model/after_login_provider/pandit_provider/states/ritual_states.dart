import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';

class RitualState {
  final List<RitualData> rituals;

  final List<RitualData> searchResults;

  final bool isLoading;
  final String? error;

  RitualState({
    this.rituals = const [],

    this.searchResults = const [],

    this.isLoading = false,

    this.error,
  });

  RitualState copyWith({
    List<RitualData>? rituals,

    List<RitualData>? searchResults, // ← New

    bool? isLoading,
    String? error,
  }) {
    return RitualState(
      rituals: rituals ?? this.rituals,

      searchResults: searchResults ?? this.searchResults, // ← New

      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
