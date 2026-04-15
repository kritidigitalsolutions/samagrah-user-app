import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

    /// ✅ Extract special lists
    final dailyEssentials = products
        .where((p) => p.isMostPoojaEssentials == true)
        .toList();

    final mostUsed = products.where((p) => p.isMostUsed == true).toList();
    final ritualItems = products.where((p) => p.isRitualItems == true).toList();

    /// ✅ Normal products (excluding special ones)
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

      // ✅ Store originals
      originalDailyEssentials: dailyEssentials,
      originalMostUsed: mostUsed,
      originalRitualItems: ritualItems,

      // ✅ Initially same as originals
      dailyEssentials: dailyEssentials,
      mostUsed: mostUsed,
    );
  }

  /// 🔥 Category Filter - Fixed
  void filterByCategory(String category) {
    final current = state.value;
    if (current == null) return;

    final String normalizedCategory = category.toLowerCase().trim();

    List<Product> baseList;
    List<Product> dailyEss;
    List<Product> mostU;

    if (normalizedCategory == "all") {
      // ✅ "All" selected - Show everything
      baseList = current.allProducts;
      dailyEss = current.originalDailyEssentials; // ← Original full list
      mostU = current.originalMostUsed; // ← Original full list
    } else {
      // ✅ Specific category selected - Filter everything
      baseList = current.allProducts
          .where((p) => (p.category ?? '').toLowerCase() == normalizedCategory)
          .toList();

      // Filter from original lists (not from already filtered lists)
      dailyEss = current.originalDailyEssentials
          .where((p) => (p.category ?? '').toLowerCase() == normalizedCategory)
          .toList();

      mostU = current.originalMostUsed
          .where((p) => (p.category ?? '').toLowerCase() == normalizedCategory)
          .toList();
    }

    state = AsyncData(
      current.copyWith(
        selectedCategory: normalizedCategory == "all"
            ? "All"
            : normalizedCategory,
        categoryProducts: baseList,
        dailyEssentials: dailyEss,
        mostUsed: mostU,
      ),
    );
  }

  // filter inside of customize kit

  void filterByCustKitCategory(String category) {
    final current = state.value;
    if (current == null) return;

    final String normalizedCategory = category.toLowerCase().trim();

    List<Product> baseList;

    if (normalizedCategory == "all") {
      // ✅ "All" selected - Show everything
      baseList = current.customizeKitItems;
    } else {
      // ✅ Specific category selected - Filter everything
      baseList = current.customizeKitItems
          .where((p) => (p.category ?? '').toLowerCase() == normalizedCategory)
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

  // search product

  /// 🔥 Search Products - Dedicated List
  void searchProducts(String query) {
    final current = state.value;
    if (current == null) return;

    final String searchTerm = query.toLowerCase().trim();

    if (searchTerm.isEmpty) {
      // Reset search
      state = AsyncData(
        current.copyWith(
          searchResults: [],
          searchQuery: "",
          selectedCategory: "All", // ya current.selectedCategory
        ),
      );
      return;
    }

    // Search across all original products
    final List<Product> allSource = [
      ...current.originalDailyEssentials,
      ...current.originalMostUsed,
      ...current.originalRitualItems,
      ...current.allProducts,
    ];

    // Remove duplicate products (by id)
    final uniqueProducts = <Product>{};
    for (var p in allSource) {
      if (p.id != null) uniqueProducts.add(p);
    }

    final filteredResults = uniqueProducts.where((p) {
      final title = (p.title ?? '').toLowerCase();
      final category = (p.category ?? '').toLowerCase();
      return title.contains(searchTerm) || category.contains(searchTerm);
    }).toList();

    state = AsyncData(
      current.copyWith(searchResults: filteredResults, searchQuery: query),
    );
  }
}
