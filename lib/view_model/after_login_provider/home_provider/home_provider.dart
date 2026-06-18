import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/banner_res_model.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/product_state.dart';

final bottomNavProvider = StateProvider<int>((ref) => 0);

final productProvider = AsyncNotifierProvider<ProductNotifier, ProductState>(
  () => ProductNotifier(),
);

class ProductNotifier extends AsyncNotifier<ProductState> {
  final _repo = ProductRepo();

  @override
  Future<ProductState> build() async {
    final res = await _repo.getProducts();
    final products = res.data?.products ?? [];

    return ProductState(
      allProducts: products,
      categoryProducts: products,
      customizeKitItems: products,
      categoryKitProducts: products,
      mostTrending: products.where((p) => p.isRecommended == true).toList(),
      dailyRituals: products.where((p) => p.isEveryDayRitual == true).toList(),
      popularProducts: products.where((p) => p.isMostUsed == true).toList(),
      poojaEssentials: products
          .where((p) => p.isMostPoojaEssentials == true)
          .toList(),
    );
  }

  /// ✅ categoryId._id se filter
  void filterByCategory(String? categoryId) {
    final current = state.value;
    if (current == null) return;

    final baseList = (categoryId == null || categoryId == "all")
        ? current.allProducts
        : current.allProducts
              .where((p) => (p.categoryId?.id ?? '') == categoryId)
              .toList();

    state = AsyncData(
      current.copyWith(
        selectedCategory: categoryId ?? "all",
        categoryProducts: baseList,
      ),
    );
  }

  void filterByCustKitCategory(String category) {
    final current = state.value;
    if (current == null) return;
    final norm = category.toLowerCase().trim();
    final baseList = norm == "all"
        ? current.customizeKitItems
        : current.customizeKitItems
              .where((p) => (p.category?.name ?? '').toLowerCase() == norm)
              .toList();
    state = AsyncData(
      current.copyWith(
        selectedKitCategory: norm == "all" ? "All" : norm,
        categoryKitProducts: baseList,
      ),
    );
  }

  void searchProducts(String query) {
    final current = state.value;
    if (current == null) return;
    final term = query.toLowerCase().trim();
    if (term.isEmpty) {
      state = AsyncData(
        current.copyWith(
          searchResults: [],
          searchQuery: "",
          selectedCategory: "all",
        ),
      );
      return;
    }
    final results = current.allProducts.where((p) {
      return (p.title ?? '').toLowerCase().contains(term) ||
          (p.categoryId?.name ?? '').toLowerCase().contains(term);
    }).toList();
    state = AsyncData(
      current.copyWith(searchResults: results, searchQuery: query),
    );
  }
}

final imageSliderIndexProvider = StateProvider.family<int, String>(
  (ref, productId) => 0,
);

final productRepoProvider = Provider((ref) => ProductRepo());

final bannerProvider = FutureProvider<BannerResModel>((ref) async {
  return ref.read(productRepoProvider).getBanner();
});

final showAllDetailsProvider = StateProvider<bool>((ref) => false);
