import 'package:samagrah/model/response/kit_response/festival_kit_response.dart';

class FestivalkitState {
  final FestivalKitResponse? festivalKit; // 👈 model 1
  final bool isLoading;
  final String? error;

  FestivalkitState({this.festivalKit, this.isLoading = false, this.error});

  FestivalkitState copyWith({
    FestivalKitResponse? festivalKit,
    bool? isLoading,
    String? error,
  }) {
    return FestivalkitState(
      festivalKit: festivalKit ?? this.festivalKit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
