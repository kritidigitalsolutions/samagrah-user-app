import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';

import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final productState = ref.watch(productProvider);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  decoration: BoxDecoration(color: AppColors.headerCard),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prepare for your',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Pooja today',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        userAsync.when(
                          data: (user) => GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.profile);
                            },
                            child: CircleAvatar(
                              radius: 30,
                              child: CustomCachedImage(
                                imageUrl: user?['profileImage'] ?? '',

                                borderRadius: BorderRadius.circular(35),
                              ),
                            ),
                          ),
                          loading: () => const CircularProgressIndicator(),
                          error: (e, _) => const Text("Error loading user"),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.searchProduct);
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        style: text14(
                          fontWeight: FontWeight.normal,
                          color: AppColors.white,
                        ),
                        cursorColor: AppColors.white,
                        decoration: InputDecoration(
                          hintText: 'diya, agarbatti thali...',
                          hintStyle: text14(color: AppColors.grey100),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.grey100,
                          ),
                          filled: true,
                          fillColor: AppColors.primary,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Expanded(
                  child: productState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        const Center(child: Text("Something went wrong")),
                    data: (state) {
                      final ritualItems = state.originalRitualItems
                          .take(20)
                          .toList();
                      final dailyEss = state.originalDailyEssentials
                          .take(20)
                          .toList();
                      final mostUsed = state.originalMostUsed.take(20).toList();
                      final otherProduct = state.allProducts.take(15).toList();

                      final bool allEmpty =
                          ritualItems.isEmpty &&
                          dailyEss.isEmpty &&
                          mostUsed.isEmpty &&
                          otherProduct.isEmpty;

                      if (allEmpty) {
                        return const Center(child: Text("No Products Found"));
                      }

                      return ListView(
                        padding: const EdgeInsets.only(top: 8),
                        children: [
                          // Everyday Ritual Items
                          _buildSection(
                            context,
                            'Everyday Ritual Items',
                            dailyEss,
                          ),

                          // Most Used Items
                          _buildSection(
                            context,
                            'Most Used Items in Samagri',
                            mostUsed,
                          ),

                          // Ritual Essentials
                          _buildSection(
                            context,
                            'Ritual Essentials',
                            ritualItems,
                          ),

                          // Others
                          _buildSection(
                            context,
                            'Others Essentials',
                            otherProduct,
                          ),

                          const SizedBox(height: 100), // Space for bottom cart
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const BottomCartBar(),
        ],
      ),
    );
  }

  // ✅ Reusable section builder
  Widget _buildSection(
    BuildContext context,
    String title,
    List<Product> products,
  ) {
    if (products.isEmpty) return const SizedBox.shrink();

    // Determine categoryType based on title
    String categoryType = "";
    if (title.contains("Everyday Ritual")) {
      categoryType = "daily";
    } else if (title.contains("Most Used")) {
      categoryType = "mostUsed";
    } else if (title.contains("Ritual Essentials")) {
      categoryType = "ritualItems";
    } else {
      categoryType = "others";
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: text15(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TypeOfCategoryPage(
                        title: title,
                        categoryType: categoryType,
                      ),
                    ),
                  );
                },
                child: Text(
                  'View all >',
                  style: text13(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimationLimiter(
          key: ValueKey('grid_${title}_${products.length}'),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return AnimationConfiguration.staggeredGrid(
                position: index,
                columnCount: 3,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  horizontalOffset: 50,
                  child: FadeInAnimation(
                    child: ScaleAnimation(
                      scale: 0.9,
                      // ✅ Use new widget - only this rebuilds
                      child: ProductCard(product: product),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
