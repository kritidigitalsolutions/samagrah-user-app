import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';

// ─── Toggle: expanded / collapsed ───────────────────────────────────────────
final availabilityExpandedProvider = StateProvider<bool>((ref) => false);

// ─── Async availability data per panditId ───────────────────────────────────
final availabilityProvider =
FutureProvider.family<AvailabilityResModel, String>((ref, panditId) async {
  final repo = PanditRepo();
  return repo.getAvailability(panditId);
});