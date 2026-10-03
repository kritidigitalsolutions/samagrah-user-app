import 'package:samagrah/model/response/product_res/product_response_model.dart';

class ProductState {
  final List<Product> allProducts;
  final List<Product> categoryProducts;

  final List<Product> mostTrending; // flags.isRecommended
  final List<Product> dailyRituals; // flags.isEveryDayRitual
  final List<Product> popularProducts; // flags.isMostUsed
  final List<Product> poojaEssentials; // flags.isMostPoojaEssentials

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
    this.mostTrending = const [],
    this.dailyRituals = const [],
    this.popularProducts = const [],
    this.poojaEssentials = const [],
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
    List<Product>? mostTrending,
    List<Product>? dailyRituals,
    List<Product>? popularProducts,
    List<Product>? poojaEssentials,
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
      mostTrending: mostTrending ?? this.mostTrending,
      dailyRituals: dailyRituals ?? this.dailyRituals,
      popularProducts: popularProducts ?? this.popularProducts,
      poojaEssentials: poojaEssentials ?? this.poojaEssentials,
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
