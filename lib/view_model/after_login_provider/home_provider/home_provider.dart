import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/banner_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
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

    final dailyEssentials = products
        .where((p) => p.isMostPoojaEssentials == true)
        .toList();
    final mostUsed = products.where((p) => p.isMostUsed == true).toList();
    final ritualItems = products.where((p) => p.isRitualItems == true).toList();

    final normalProducts = products.where((p) {
      return p.isMostPoojaEssentials != true &&
          p.isMostUsed != true &&
          p.isRitualItems != true;
    }).toList();

    return ProductState(
      allProducts: normalProducts,
      categoryProducts: normalProducts,
      customizeKitItems: products,
      categoryKitProducts: products,
      originalDailyEssentials: dailyEssentials,
      originalMostUsed: mostUsed,
      originalRitualItems: ritualItems,
      dailyEssentials: dailyEssentials,
      mostUsed: mostUsed,
    );
  }

  /// ✅ Category filter ab categoryId (_id) se hoga, category.name se nahi
  void filterByCategory(String? categoryId) {
    final current = state.value;
    if (current == null) return;

    List<Product> baseList;
    List<Product> dailyEss;
    List<Product> mostU;

    if (categoryId == null || categoryId == "all") {
      // "All" selected — sab dikhao
      baseList = current.allProducts;
      dailyEss = current.originalDailyEssentials;
      mostU = current.originalMostUsed;
    } else {
      // categoryId se filter (product.category._id match karo)
      baseList = current.allProducts
          .where((p) => (p.categoryId?.id ?? '') == categoryId)
          .toList();

      dailyEss = current.originalDailyEssentials
          .where((p) => (p.categoryId?.id ?? '') == categoryId)
          .toList();

      mostU = current.originalMostUsed
          .where((p) => (p.categoryId?.id ?? '') == categoryId)
          .toList();
    }

    state = AsyncData(
      current.copyWith(
        selectedCategory: categoryId ?? "all",
        categoryProducts: baseList,
        dailyEssentials: dailyEss,
        mostUsed: mostU,
      ),
    );
  }

  /// Customize kit filter (category name se — wahi rakha)
  void filterByCustKitCategory(String category) {
    final current = state.value;
    if (current == null) return;

    final String normalizedCategory = category.toLowerCase().trim();

    List<Product> baseList;
    if (normalizedCategory == "all") {
      baseList = current.customizeKitItems;
    } else {
      baseList = current.customizeKitItems
          .where(
            (p) => (p.category?.name ?? '').toLowerCase() == normalizedCategory,
          )
          .toList();
    }

    state = AsyncData(
      current.copyWith(
        selectedKitCategory: normalizedCategory == "all"
            ? "All"
            : normalizedCategory,
        categoryKitProducts: baseList,
      ),
    );
  }

  /// Search products
  void searchProducts(String query) {
    final current = state.value;
    if (current == null) return;

    final String searchTerm = query.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      state = AsyncData(
        current.copyWith(
          searchResults: [],
          searchQuery: "",
          selectedCategory: "all",
        ),
      );
      return;
    }

    final List<Product> allSource = [
      ...current.originalDailyEssentials,
      ...current.originalMostUsed,
      ...current.originalRitualItems,
      ...current.allProducts,
    ];

    final uniqueProducts = <Product>{};
    for (var p in allSource) {
      if (p.id != null) uniqueProducts.add(p);
    }

    final filteredResults = uniqueProducts.where((p) {
      final title = (p.title ?? '').toLowerCase();
      final category = (p.category?.name ?? '').toLowerCase();
      return title.contains(searchTerm) || category.contains(searchTerm);
    }).toList();

    state = AsyncData(
      current.copyWith(searchResults: filteredResults, searchQuery: query),
    );
  }
}

// Image slider index provider
final imageSliderIndexProvider = StateProvider.family<int, String>(
  (ref, productId) => 0,
);

// Banner provider
final productRepoProvider = Provider((ref) => ProductRepo());

final bannerProvider = FutureProvider<BannerResModel>((ref) async {
  final repo = ref.read(productRepoProvider);
  return repo.getBanner();
});

// Product details
final showAllDetailsProvider = StateProvider<bool>((ref) => false);
