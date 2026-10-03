import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/product_booked_res/review_res_model.dart';
import 'package:samagrah/model/response/product_res/product_details_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart'
    hide Pagination;
import 'package:samagrah/repo/product_repo.dart';

final productDetailsRepo = Provider((ref) => ProductRepo());

final productDetailsProvider =
    FutureProvider.family<ProductDetailsResModel, String>((ref, id) async {
      final repo = ref.read(productDetailsRepo);
      return repo.productDetails(id);
    });

// ─── State ────────────────────────────────────────────────────────────────────

class ReviewState {
  final List<Review> reviews;
  final Ratings? ratings;
  final Pagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  const ReviewState({
    this.reviews = const [],
    this.ratings,
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  bool get hasMore =>
      pagination != null &&
      (pagination!.currentPage ?? 0) < (pagination!.totalPages ?? 0);

  ReviewState copyWith({
    List<Review>? reviews,
    Ratings? ratings,
    Pagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) => ReviewState(
    reviews: reviews ?? this.reviews,
    ratings: ratings ?? this.ratings,
    pagination: pagination ?? this.pagination,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    error: error,
  );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class ReviewNotifier extends StateNotifier<ReviewState> {
  final ProductRepo _repo;

  ReviewNotifier(this._repo) : super(const ReviewState());

  /// First load — called automatically when product detail page opens
  Future<void> fetchReviews(String productId, {int limit = 3}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.getReview(productId, 1, limit);
      state = state.copyWith(
        isLoading: false,
        reviews: res.data?.reviews ?? [],
        ratings: res.data?.ratings,
        pagination: res.data?.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load more pages — called when bottom sheet scrolls to end
  Future<void> loadMore(String productId, {int limit = 10}) async {
    if (!state.hasMore || state.isLoadingMore) return;
    final nextPage = (state.pagination?.currentPage ?? 1) + 1;
    state = state.copyWith(isLoadingMore: true);
    try {
      final res = await _repo.getReview(productId, nextPage, limit);
      state = state.copyWith(
        isLoadingMore: false,
        reviews: [...state.reviews, ...(res.data?.reviews ?? [])],
        pagination: res.data?.pagination,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void reset() => state = const ReviewState();
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final reviewProvider =
    StateNotifierProvider.autoDispose<ReviewNotifier, ReviewState>((ref) {
      return ReviewNotifier(ProductRepo());
    });

// =================== custom samagri kit ========================

final selectedSamagriItemsProvider = StateProvider<List<CustomSamagriItem>>(
  (ref) => [],
);
