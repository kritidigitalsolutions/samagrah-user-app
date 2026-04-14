import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/repo/kit/festival_kit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/festivalkit_state.dart';

final festivalProvider =
    AsyncNotifierProvider<FestivalNotifier, FestivalkitState>(
      () => FestivalNotifier(),
    );

class FestivalNotifier extends AsyncNotifier<FestivalkitState> {
  final _repo = FestivalKitRepo();

  @override
  Future<FestivalkitState> build() async {
    final res = await _repo.getFestivalKits();

    return FestivalkitState(festivalKit: res);
  }

  /// 🔍 Search API
  Future<void> searchFestival(String query) async {
    if (query.isEmpty) {
      // empty → reload default data
      final res = await _repo.getFestivalKits();
      state = AsyncData(FestivalkitState(festivalKit: res));
      return;
    }

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final res = await _repo.searchFestivalKits(query);
      return FestivalkitState(festivalKit: res);
    });
  }
}
