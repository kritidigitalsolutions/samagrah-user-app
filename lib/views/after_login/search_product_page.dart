import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

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
      body: Stack(
        children: [
          Column(
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
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.grey100,
                    ),
                    suffixIcon: _currentQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.grey100,
                            ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                            Icon(
                              Icons.search,
                              size: 80,
                              color: AppColors.grey300,
                            ),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final cardWidth =
                                    (constraints.maxWidth - 16 - 12) / 3;
                                final imageHeight = cardWidth;
                                const infoHeight = 85.0;
                                final ratio =
                                    cardWidth / (imageHeight + infoHeight);

                                return GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    8,
                                    0,
                                    0,
                                    0,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: ratio, // ← dynamic
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    final product = results[index];

                                    return AnimationConfiguration.staggeredGrid(
                                      position: index,
                                      columnCount: 3,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: SlideAnimation(
                                        verticalOffset: 60,
                                        child: FadeInAnimation(
                                          child: ScaleAnimation(
                                            scale: 0.92,
                                            child: ProductCard(
                                              product: product,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
          BottomCartBar(),
        ],
      ),
    );
  }
}
