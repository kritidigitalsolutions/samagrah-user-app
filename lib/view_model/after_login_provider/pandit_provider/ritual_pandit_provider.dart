// ================== Ritual provider ===================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/states/pandit_state.dart';
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

// ======================== Pandit ====================================

final panditProvider = AsyncNotifierProvider<PanditNotifier, PanditState>(
  () => PanditNotifier(),
);

class PanditNotifier extends AsyncNotifier<PanditState> {
  final _repo = PanditRepo();

  @override
  Future<PanditState> build() async {
    final res = await _repo.getPandit();
    final pandits = res.data;

    return PanditState(pandit: pandits);
  }

  void searchPandit(String query) {
    final current = state.value;
    if (current == null) return;

    final String searchTerm = query.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      // Reset search
      state = AsyncData(current.copyWith(searchResults: []));
      return;
    }

    // Search across all original products
    final List<PanditData> allSource = [...current.pandit];

    // Remove duplicate products (by id)
    final uniqueProducts = <PanditData>{};
    for (var p in allSource) {
      if (p.id != null) uniqueProducts.add(p);
    }

    final filteredResults = current.pandit.where((p) {
      final name = (p.fullName ?? "").toLowerCase();
      final city = (p.address?.city ?? "").toLowerCase();
      final stateName = (p.address?.state ?? "").toLowerCase();
      final line1 = (p.address?.line1 ?? "").toLowerCase();
      final line2 = (p.address?.line2 ?? "").toLowerCase();

      final languages = p.languagesSpoken.map((e) => e.toLowerCase()).join(" ");
      final yearOfExp = p.yearsOfExperience.toString();
      final poojaNames = p.poojaOfferings
          .map((e) => (e.name ?? "").toLowerCase())
          .join(" ");

      return name.contains(searchTerm) ||
          city.contains(searchTerm) ||
          stateName.contains(searchTerm) ||
          languages.contains(searchTerm) ||
          poojaNames.contains(searchTerm) ||
          line1.contains(searchTerm) ||
          line2.contains(searchTerm) ||
          yearOfExp.contains(searchTerm);
    }).toList();

    state = AsyncData(current.copyWith(searchResults: filteredResults));
  }
}
