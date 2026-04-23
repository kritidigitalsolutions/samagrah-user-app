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

      state = state.copyWith(
        items: res.data, // ✅ full data store
        isLoading: false,
      );
    } catch (e) {
      print("❌ Wishlist load failed: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  // ❤️ Toggle Wishlist
  Future<void> toggle(String productId) async {
    if (_isToggling) return;
    _isToggling = true;

    final exists = state.items.any((item) => item.product?.id == productId);

    List<Datum> updated = [...state.items];

    if (exists) {
      updated.removeWhere((e) => e.product?.id == productId);
    } else {
      // 🔥 optimistic add (dummy item)
      updated.add(
        Datum(
          id: '',
          user: '',
          product: CartProduct(
            id: productId,
            title: '',
            slug: '',
            tags: [],
            category: null,
            pricing: null,
            media: null,
            ratings: null,
            stock: null,
            flags: null,
          ),
          quantity: 1,
          priceAtAdd: 0,
        ),
      );
    }

    state = state.copyWith(items: updated);

    try {
      await _repo.toggleWishlist(productId);
      loadWishlist();
    } catch (e) {
      print("⚠️ Toggle failed: $e");
      await loadWishlist(); // 🔥 rollback safe
    } finally {
      _isToggling = false;
    }
  }
}

final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
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
