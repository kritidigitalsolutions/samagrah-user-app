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
      state = AsyncData(current.copyWith(searchResults: []));
      return;
    }

    final List<RitualData> allSource = [...current.rituals];

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

  // Tracks whether user has applied a custom location.
  // null = use LocationStorage (user's GPS city), non-null = custom city
  String? _customCity;
  String? _customPincode;

  @override
  Future<PanditState> build() async {
    // First load always uses user's saved GPS location
    final res = await _repo.getPandit();
    return PanditState(pandit: res.data);
  }

  /// Called when user selects a custom city from the location filter.
  /// Re-fetches pandits from the API for the given city/pincode.
  Future<void> fetchByLocation({
    required String city,
    String pincode = '',
  }) async {
    _customCity = city.trim();
    _customPincode = pincode.trim();

    state = const AsyncLoading();
    try {
      final res = await _repo.getPandit(
        city: _customCity,
        pincode: _customPincode,
      );
      state = AsyncData(PanditState(pandit: res.data));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Resets back to user's GPS/saved location and re-fetches.
  Future<void> resetToUserLocation() async {
    _customCity = null;
    _customPincode = null;

    state = const AsyncLoading();
    try {
      final res = await _repo.getPandit(); // no params → uses LocationStorage
      state = AsyncData(PanditState(pandit: res.data));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void searchPandit(String query) {
    final current = state.value;
    if (current == null) return;

    final String searchTerm = query.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      state = AsyncData(current.copyWith(searchResults: []));
      return;
    }

    final uniqueProducts = <PanditData>{};
    for (var p in current.pandit) {
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
