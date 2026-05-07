import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class TypeOfCategoryPage extends ConsumerStatefulWidget {
  final String title;
  final String categoryType; // "daily", "mostUsed", "ritualItems", "others"

  const TypeOfCategoryPage({
    super.key,
    required this.title,
    required this.categoryType,
  });

  @override
  ConsumerState<TypeOfCategoryPage> createState() => _TypeOfCategoryPageState();
}

class _TypeOfCategoryPageState extends ConsumerState<TypeOfCategoryPage> {
  final leftController = ScrollController();
  final rightController = ScrollController();

  String selectedCategory = "All";

  @override
  void dispose() {
    leftController.dispose();
    rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.title,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.searchProduct);
              },
              child: CircleAvatar(
                backgroundColor: AppColors.white,
                radius: 18,
                child: Center(
                  child: Icon(Icons.search, size: 20, color: AppColors.grey400),
                ),
              ),
            ),
          ),
        ],
      ),
      body: productState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text("Something went wrong")),
        data: (state) {
          // Get products based on categoryType
          List<Product> sourceProducts = [];

          switch (widget.categoryType) {
            case "allItems":
              sourceProducts = state.categoryProducts;
              break;
            case "daily":
              sourceProducts = state.originalDailyEssentials;
              break;
            case "mostUsed":
              sourceProducts = state.originalMostUsed;
              break;
            case "ritualItems":
              sourceProducts = state.originalRitualItems;
              break;
            case "others":
              sourceProducts = state.allProducts;
              break;
            default:
              sourceProducts = state.allProducts;
          }

          if (sourceProducts.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          print('source ---------------------------${sourceProducts.length}');

          // Extract unique categories from source products
          final categorySet = <String>{};
          for (var product in sourceProducts) {
            if (product.category != null &&
                product.category!.name!.isNotEmpty) {
              categorySet.add(product.category!.name!);
            }
          }

          // Create category list with "All" at the beginning
          final List<String> categories = ["All", ...categorySet];

          // Filter products based on selected category
          List<Product> filteredProducts = selectedCategory == "All"
              ? sourceProducts
              : sourceProducts
                    .where(
                      (p) =>
                          (p.category?.name ?? '').toLowerCase() ==
                          selectedCategory.toLowerCase(),
                    )
                    .toList();

          return SafeArea(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Category List
                    _buildCategoryList(categories),

                    // Vertical Divider
                    Container(
                      width: 1,
                      color: AppColors.grey200,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                    ),

                    // Right Product Grid
                    _buildProductGrid(filteredProducts),
                  ],
                ),
                const BottomCartBar(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Get emoji for category
  String _getCategoryEmoji(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('all')) {
      return "assets/home/select-all.png";
    } else if (categoryLower.contains('agarbatti') ||
        categoryLower.contains('incense')) {
      return "assets/home/incense.png";
    } else if (categoryLower.contains('fruit')) {
      return "assets/home/fruit.png";
    } else if (categoryLower.contains('flower') ||
        categoryLower.contains('flowes')) {
      return "assets/home/flower.png";
    } else if (categoryLower.contains('garland')) {
      return "assets/home/mala.png";
    } else if (categoryLower.contains('diya')) {
      return "assets/home/incense.png";
    }

    return "assets/home/select-all.png"; // default pooja symbol
  }

  // Build left category list
  Widget _buildCategoryList(List<String> categories) {
    return SizedBox(
      width: 90,
      child: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(AppColors.button),
          trackColor: WidgetStateProperty.all(AppColors.grey200),
          thickness: WidgetStateProperty.all(4),
          radius: const Radius.circular(10),
        ),
        child: Scrollbar(
          controller: leftController,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 2,
          radius: const Radius.circular(5),
          child: ListView.builder(
            controller: leftController,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final bool isSelected = selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: isSelected
                          ? const Border(
                              left: BorderSide(
                                color: AppColors.button,
                                width: 3,
                              ),
                            )
                          : null,
                      color: Colors.transparent,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.button.withAlpha(30)
                                : AppColors.grey200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Image.asset(
                              _getCategoryEmoji(category),
                              height: 25,
                              width: 25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            category,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: text11(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color.fromARGB(255, 68, 37, 37)
                                  : AppColors.grey700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Build right product grid
  Widget _buildProductGrid(List<Product> products) {
    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: AppColors.grey300,
              ),
              const SizedBox(height: 16),
              Text(
                'No products in this category',
                style: text14(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: SingleChildScrollView(
        controller: rightController,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category title (if not "All")
            if (selectedCategory != "All")
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(
                      selectedCategory,
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${products.length} items)',
                      style: text13(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),

            // Product Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(product: product);
              },
            ),

            const SizedBox(height: 24),

            // Promotional Banner (show if more than 6 products)
            if (products.length > 6) _buildPromotionalBanner(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B1A), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/icon/mala.png',
              fit: BoxFit.fitWidth,
              height: 28,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get ₹50 OFF',
                  style: text20(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add items worth ₹200 more',
                  style: text14(color: AppColors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
