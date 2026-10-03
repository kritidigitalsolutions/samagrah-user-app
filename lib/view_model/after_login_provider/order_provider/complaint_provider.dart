// view_model/after_login_provider/complaint_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/complaint_res_model.dart';
import 'package:samagrah/repo/complaint_repo.dart';

final complaintRepoProvider = Provider<ComplaintRepo>((ref) => ComplaintRepo());

// ── Submit complaint (with loading/error state) ────────────────────────
class ComplaintSubmitNotifier extends StateNotifier<AsyncValue<void>> {
  final ComplaintRepo _repo;
  ComplaintSubmitNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String orderId,
    required String issue,
    required String details,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.raiseComplaint(
        orderId: orderId,
        issue: issue,
        details: details,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      return false;
    }
  }
}

final complaintSubmitProvider =
    StateNotifierProvider<ComplaintSubmitNotifier, AsyncValue<void>>((ref) {
      return ComplaintSubmitNotifier(ref.read(complaintRepoProvider));
    });

// ── Complaints list ─────────────────────────────────────────────────────
final complaintListProvider = FutureProvider<List<Complaint>>((ref) async {
  return ref.read(complaintRepoProvider).getComplaints();
});

// ── Support settings ────────────────────────────────────────────────────
final supportSettingsProvider = FutureProvider<SupportSettings>((ref) async {
  return ref.read(complaintRepoProvider).getSupportSettings();
});
