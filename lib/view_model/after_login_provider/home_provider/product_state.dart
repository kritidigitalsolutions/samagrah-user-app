import 'package:samagrah/model/response/product_res/product_response_model.dart';

class ProductState {
  final List<Product> allProducts;

  final List<Product> categoryProducts;
  final List<Product> dailyEssentials;
  final List<Product> mostUsed;

  final String selectedCategory;

  final bool isLoading;
  final String? error;

  ProductState({
    this.allProducts = const [],
    this.categoryProducts = const [],
    this.dailyEssentials = const [],
    this.mostUsed = const [],
    this.selectedCategory = "All",
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? allProducts,
    List<Product>? categoryProducts,
    List<Product>? dailyEssentials,
    List<Product>? mostUsed,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      dailyEssentials: dailyEssentials ?? this.dailyEssentials,
      mostUsed: mostUsed ?? this.mostUsed,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
