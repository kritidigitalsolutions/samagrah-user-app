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

    /// ✅ Extract special lists first
    final dailyEssentials = products
        .where((p) => p.isMostPoojaEssentials == true)
        .toList();

    final mostUsed = products.where((p) => p.isMostUsed == true).toList();

    /// ✅ Remove these from allProducts
    final normalProducts = products.where((p) {
      return p.isMostPoojaEssentials != true && p.isMostUsed != true;
    }).toList();

    return ProductState(
      allProducts: normalProducts, // 👈 cleaned list
      categoryProducts: normalProducts, // 👈 default

      dailyEssentials: dailyEssentials,
      mostUsed: mostUsed,
    );
  }

  /// 🔥 Category Filter
  void filterByCategory(String category) {
    final current = state.value;
    if (current == null) return;

    List<Product> filtered;

    if (category == "All") {
      filtered = current.allProducts;
    } else {
      filtered = current.allProducts
          .where((p) => p.category == category)
          .toList();
    }

    state = AsyncData(
      current.copyWith(selectedCategory: category, categoryProducts: filtered),
    );
  }

  //   void filterDailyEssentials() {
  //   final current = state.value;
  //   if (current == null) return;

  //   final filtered = current.allProducts
  //       .where((p) => p.isMostPoojaEssentials == true)
  //       .toList();

  //   state = AsyncData(
  //     current.copyWith(dailyEssentials: filtered),
  //   );
  // }

  // void filterMostUsed() {
  //   final current = state.value;
  //   if (current == null) return;

  //   final filtered = current.allProducts
  //       .where((p) => p.isMostUsed == true)
  //       .toList();

  //   state = AsyncData(
  //     current.copyWith(mostUsed: filtered),
  //   );
  // }
}
