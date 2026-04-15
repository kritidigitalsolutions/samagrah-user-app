import 'package:samagrah/model/response/product_res/product_response_model.dart';

class ProductState {
  final List<Product> allProducts;
  final List<Product> categoryProducts;

  // customize kit product
  final List<Product> customizeKitItems;
  final List<Product> categoryKitProducts;
  final String selectedKitCategory;

  // ✅ Original lists (never filtered)
  final List<Product> originalDailyEssentials;
  final List<Product> originalMostUsed;
  final List<Product> originalRitualItems;

  // ✅ Filtered lists (displayed in UI)
  final List<Product> dailyEssentials;
  final List<Product> mostUsed;

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
    this.originalDailyEssentials = const [],
    this.originalMostUsed = const [],
    this.originalRitualItems = const [],
    this.dailyEssentials = const [],
    this.mostUsed = const [],
    this.searchResults = const [],
    this.selectedCategory = "All",
    this.selectedKitCategory = "All",
    this.isLoading = false,
    this.searchQuery = "",
    this.error,
  });

  ProductState copyWith({
    List<Product>? allProducts,
    List<Product>? categoryProducts,
    List<Product>? categoryKitProducts,
    List<Product>? customizeKitItems,
    List<Product>? originalDailyEssentials,
    List<Product>? originalMostUsed,
    List<Product>? originalRitualItems,
    List<Product>? dailyEssentials,
    List<Product>? mostUsed,
    List<Product>? searchResults, // ← New
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
      originalDailyEssentials:
          originalDailyEssentials ?? this.originalDailyEssentials,
      originalMostUsed: originalMostUsed ?? this.originalMostUsed,
      originalRitualItems: originalRitualItems ?? this.originalRitualItems,
      dailyEssentials: dailyEssentials ?? this.dailyEssentials,
      mostUsed: mostUsed ?? this.mostUsed,
      searchResults: searchResults ?? this.searchResults, // ← New
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedKitCategory: selectedKitCategory ?? this.selectedKitCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
