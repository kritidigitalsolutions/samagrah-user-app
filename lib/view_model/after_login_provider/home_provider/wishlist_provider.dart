import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/product_res/cart_res_model.dart';
import 'package:samagrah/repo/wishlist_repo.dart';

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>(
  (ref) => WishlistNotifier(WishlistRepo()),
);

class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier(this._repo)
    : super(WishlistState(items: [], isLoading: false)) {
    loadWishlist();
  }

  final WishlistRepo _repo;
  final Set<String> _togglingProductIds = <String>{};

  Future<void> loadWishlist() async {
    try {
      state = state.copyWith(isLoading: true);
      final res = await _repo.getWishlist();
      final validItems = res.data
          .where(
            (item) =>
                item.product != null &&
                (item.product!.id ?? '').trim().isNotEmpty,
          )
          .toList();
      state = state.copyWith(items: validItems, isLoading: false);
    } catch (e) {
      print('Wishlist load failed: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggle(String productId) async {
    productId = productId.trim();
    if (productId.isEmpty || _togglingProductIds.contains(productId)) return;
    _togglingProductIds.add(productId);

    final optimisticAdded = {...state.optimisticAdded};
    final optimisticRemoved = {...state.optimisticRemoved};
    final togglingProductIds = {...state.togglingProductIds}..add(productId);
    if (state.isWishlisted(productId)) {
      optimisticAdded.remove(productId);
      optimisticRemoved.add(productId);
    } else {
      optimisticRemoved.remove(productId);
      optimisticAdded.add(productId);
    }
    state = state.copyWith(
      optimisticAdded: optimisticAdded,
      optimisticRemoved: optimisticRemoved,
      togglingProductIds: togglingProductIds,
    );

    try {
      await _repo.toggleWishlist(productId);
      await loadWishlist();
    } catch (e) {
      print('Wishlist toggle failed: $e');
      await loadWishlist();
    } finally {
      _togglingProductIds.remove(productId);
      final added = {...state.optimisticAdded}..remove(productId);
      final removed = {...state.optimisticRemoved}..remove(productId);
      final toggling = {...state.togglingProductIds}..remove(productId);
      state = state.copyWith(
        optimisticAdded: added,
        optimisticRemoved: removed,
        togglingProductIds: toggling,
      );
    }
  }
}

final isWishlistedProvider = Provider.family<bool, String>((ref, productId) {
  if (productId.trim().isEmpty) return false;
  return ref.watch(
    wishlistProvider.select((state) => state.isWishlisted(productId)),
  );
});

final isWishlistTogglingProvider = Provider.family<bool, String>((
  ref,
  productId,
) {
  return ref.watch(
    wishlistProvider.select(
      (state) => state.togglingProductIds.contains(productId),
    ),
  );
});

class WishlistState {
  WishlistState({
    required this.items,
    required this.isLoading,
    this.optimisticAdded = const <String>{},
    this.optimisticRemoved = const <String>{},
    this.togglingProductIds = const <String>{},
  });

  final List<Datum> items;
  final bool isLoading;
  final Set<String> optimisticAdded;
  final Set<String> optimisticRemoved;
  final Set<String> togglingProductIds;

  bool isWishlisted(String productId) {
    if (optimisticRemoved.contains(productId)) return false;
    if (optimisticAdded.contains(productId)) return true;
    return items.any((item) => item.product?.id == productId);
  }

  WishlistState copyWith({
    List<Datum>? items,
    bool? isLoading,
    Set<String>? optimisticAdded,
    Set<String>? optimisticRemoved,
    Set<String>? togglingProductIds,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      optimisticAdded: optimisticAdded ?? this.optimisticAdded,
      optimisticRemoved: optimisticRemoved ?? this.optimisticRemoved,
      togglingProductIds: togglingProductIds ?? this.togglingProductIds,
    );
  }
}
