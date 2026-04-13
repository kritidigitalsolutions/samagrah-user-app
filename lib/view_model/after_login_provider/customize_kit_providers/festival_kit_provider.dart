import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/repo/kit/festival_kit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/festivalkit_state.dart';


final festivalProvider = AsyncNotifierProvider<FestivalNotifier, FestivalkitState>(
  () => FestivalNotifier(),
);


class FestivalNotifier extends AsyncNotifier<FestivalkitState> {
  final _repo = FestivalKitRepo();

  @override
  FutureOr<FestivalkitState> build() {
    return FestivalkitState();
  }

  Future<void> getFestivalKits() async {
    state = AsyncLoading();

     state = await AsyncValue.guard(() async {
      final res = await _repo.getFestivalKits();

      return state.value!.copyWith(
        festivalKit: res, // 👈 store register response
      );
    });
  }
}
