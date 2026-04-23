// ================== Ritual provider ===================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/states/ritual_states.dart';

final ritualProvider = AsyncNotifierProvider<RitualNotifier, RitualState>(
  () => RitualNotifier(),
);

class RitualNotifier extends AsyncNotifier<RitualState> {
  final _repo = PanditRepo();

  @override
  Future<RitualState> build() async {
    final res = await _repo.getRituals();
    final rituals = res.data;

    return RitualState(rituals: rituals);
  }

  void searchProducts(String query) {
    final current = state.value;
    if (current == null) return;

    final String searchTerm = query.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      // Reset search
      state = AsyncData(current.copyWith(searchResults: []));
      return;
    }

    // Search across all original products
    final List<RitualData> allSource = [...current.rituals];

    // Remove duplicate products (by id)
    final uniqueProducts = <RitualData>{};
    for (var p in allSource) {
      if (p.id != null) uniqueProducts.add(p);
    }

    final filteredResults = uniqueProducts.where((p) {
      final title = (p.title ?? '').toLowerCase();

      return title.contains(searchTerm);
    }).toList();

    state = AsyncData(current.copyWith(searchResults: filteredResults));
  }
}

final selectedRitualProvider = StateProvider<RitualData?>((ref) => null);
