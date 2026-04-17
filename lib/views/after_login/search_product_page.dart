import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';

class SearchProductPage extends ConsumerStatefulWidget {
  const SearchProductPage({super.key});

  @override
  ConsumerState<SearchProductPage> createState() => _SearchProductPageState();
}

class _SearchProductPageState extends ConsumerState<SearchProductPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() => _currentQuery = query);
    ref.read(productProvider.notifier).searchProducts(query);
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Search Product"),
      body: Column(
        children: [
          // ====================== Search Bar ======================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: text14(color: AppColors.white),
              cursorColor: AppColors.white,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search diya, agarbatti, thali...',
                hintStyle: text14(color: AppColors.grey100),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey100),
                suffixIcon: _currentQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.grey100),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.primary,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ====================== Search Results ======================
          Expanded(
            child: productState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  const Center(child: Text("Something went wrong")),
              data: (state) {
                final results =
                    state.searchResults; // search results yahan aayenge

                if (_currentQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 80, color: AppColors.grey300),
                        const SizedBox(height: 16),
                        Text(
                          'Search for Pooja items',
                          style: text16(color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try "diya", "agarbatti", "mala"...',
                          style: text14(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  );
                }

                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: AppColors.grey300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found for "$_currentQuery"',
                          style: text15(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: text13(color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // ====================== Results Grid ======================
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Text(
                        'Found ${results.length} results for "$_currentQuery"',
                        style: text15(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: AnimationLimiter(
                        key: ValueKey("search_${results.length}"),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final product = results[index];

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3,
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                verticalOffset: 60,
                                child: FadeInAnimation(
                                  child: ScaleAnimation(
                                    scale: 0.92,
                                    child: _buildProductCard(product),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: InkWell(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.productDetails);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: CustomCachedImage(
                        imageUrl:
                            "http://192.168.1.40:8000/${product.thumbnail}",
                        height: 90,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: AppColors.grey300),
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                        style: text11(fontWeight: FontWeight.w500),
                      ),
                    ),
                    if (product.discountPercent != null)
                      Text(
                        '${product.discountPercent}% off',
                        style: text10(color: AppColors.grey500),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${product.oldPrice}/-',
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price}/-',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                AppButton(
                  height: 22,
                  radius: 4,
                  textStyle: text11(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  title: "Add",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
