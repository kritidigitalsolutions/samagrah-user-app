// view_model/after_login_provider/pandit_provider/pandit_review_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/repo/pandit_repo.dart';

final panditReviewRepoProvider = Provider((ref) => PanditRepo());

class PanditReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final PanditRepo _repo;
  PanditReviewNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.submitReview(
        bookingId: bookingId,
        rating: rating,
        comment: comment,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      return false;
    }
  }
}

final panditReviewProvider =
    StateNotifierProvider<PanditReviewNotifier, AsyncValue<void>>((ref) {
      return PanditReviewNotifier(ref.read(panditReviewRepoProvider));
    });
