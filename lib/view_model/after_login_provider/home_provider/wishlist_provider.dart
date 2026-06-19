import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/product_res/cart_res_model.dart';
import 'package:samagrah/repo/wishlist_repo.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>(
  (ref) {
    return WishlistNotifier(WishlistRepo());
  },
);

class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistRepo _repo;

  WishlistNotifier(this._repo)
    : super(WishlistState(items: [], isLoading: false)) {
    loadWishlist();
  }

  bool _isToggling = false;

  // 🔄 Load Wishlist
  Future<void> loadWishlist() async {
    try {
      state = state.copyWith(isLoading: true);

      final res = await _repo.getWishlist();

      // ✅ sirf valid items rakho — product null/id empty wale hata do
      final validItems = res.data
          .where(
            (item) =>
                item.product != null &&
                (item.product!.id ?? '').trim().isNotEmpty,
          )
          .toList();

      state = state.copyWith(items: validItems, isLoading: false);
    } catch (e) {
      print("❌ Wishlist load failed: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  // ❤️ Toggle Wishlist
  Future<void> toggle(String productId) async {
    if (productId.trim().isEmpty) return; // ❗ safety guard
    if (_isToggling) return;
    _isToggling = true;

    final exists = state.items.any((item) => item.product?.id == productId);

    // ── Remove: optimistic UI theek hai (fast feel) ──────────────────
    if (exists) {
      final updated = [...state.items]
        ..removeWhere((e) => e.product?.id == productId);
      state = state.copyWith(items: updated);
    }
    // ── Add: optimistic dummy mat dalo, seedha API call karke fresh list lao ──

    try {
      await _repo.toggleWishlist(productId);
      await loadWishlist(); // ✅ hamesha real data se sync
    } catch (e) {
      print("⚠️ Toggle failed: $e");
      await loadWishlist(); // rollback safe
    } finally {
      _isToggling = false;
    }
  }
}

final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  if (productId.trim().isEmpty) return false; // ❗ empty id kabhi match na ho
  return ref.watch(
    wishlistProvider.select(
      (state) => state.items.any((item) => item.product?.id == productId),
    ),
  );
});

class WishlistState {
  final List<Datum> items;
  final bool isLoading;

  WishlistState({required this.items, required this.isLoading});

  WishlistState copyWith({List<Datum>? items, bool? isLoading}) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
