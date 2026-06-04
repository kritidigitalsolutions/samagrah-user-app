import 'package:samagrah/model/response/product_res/product_response_model.dart';

class ProductState {
  final List<Product> allProducts;
  final List<Product> categoryProducts;

  // customize kit
  final List<Product> customizeKitItems;
  final List<Product> categoryKitProducts;
  final String selectedKitCategory;

  // search
  final List<Product> searchResults;
  final String searchQuery;

  final String selectedCategory;
  final bool isLoading;
  final String? error;

  ProductState({
    this.allProducts = const [],
    this.categoryProducts = const [],
    this.customizeKitItems = const [],
    this.categoryKitProducts = const [],
    this.selectedKitCategory = "All",
    this.searchResults = const [],
    this.searchQuery = "",
    this.selectedCategory = "all",
    this.isLoading = false,
    this.error,
  });

  ProductState copyWith({
    List<Product>? allProducts,
    List<Product>? categoryProducts,
    List<Product>? categoryKitProducts,
    List<Product>? customizeKitItems,
    List<Product>? searchResults,
    String? selectedCategory,
    String? selectedKitCategory,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      categoryProducts: categoryProducts ?? this.categoryProducts,
      customizeKitItems: customizeKitItems ?? this.customizeKitItems,
      categoryKitProducts: categoryKitProducts ?? this.categoryKitProducts,
      searchResults: searchResults ?? this.searchResults,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedKitCategory: selectedKitCategory ?? this.selectedKitCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
