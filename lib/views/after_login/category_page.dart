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

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    return Scaffold(
      body: Container(
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.grey500,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
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
                loading: () => const Center(child: CircularProgressIndicator()),

                error: (e, _) =>
                    const Center(child: Text("Something went wrong")),
                data: (state) {
                  final ritualItems = state.originalRitualItems;
                  final dailyEss = state.originalDailyEssentials;
                  final mostUsed = state.originalMostUsed;
                  final otherProduct = state.allProducts;

                  // ✅ Check if ALL lists are empty
                  final bool allEmpty =
                      ritualItems.isEmpty &&
                      dailyEss.isEmpty &&
                      mostUsed.isEmpty &&
                      otherProduct.isEmpty;

                  if (allEmpty) {
                    return const Center(child: Text("No Products Found"));
                  }
                  return ListView(
                    padding: EdgeInsets.only(top: 8),
                    children: [
                      //=================================================================
                      // Everyday Ritual Items
                      //=====================================================
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Everyday Ritual Items',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dalityPujaE,
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
                        key: ValueKey(
                          "grid_${dailyEss.length}",
                        ), // 🔥 re-animation on change
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: dailyEss.length,
                          itemBuilder: (context, index) {
                            final product = dailyEss[index];

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3, // ⚠️ MUST match crossAxisCount
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                horizontalOffset: 50, // 👇 bottom se aayega
                                child: FadeInAnimation(
                                  child: ScaleAnimation(
                                    scale: 0.9, // 🔥 slight zoom-in effect
                                    child: _buildProductCard(context, product),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      //==========================================================
                      // Most Used Items in Samagri
                      //==========================================================
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Most Used Items in Samagri',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dalityPujaE,
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
                        key: ValueKey(
                          "grid_${mostUsed.length}",
                        ), // 🔥 re-animation on change
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: mostUsed.length,
                          itemBuilder: (context, index) {
                            final product = mostUsed[index];

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3, // ⚠️ MUST match crossAxisCount
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                horizontalOffset: 50, // 👇 bottom se aayega
                                child: FadeInAnimation(
                                  child: ScaleAnimation(
                                    scale: 0.9, // 🔥 slight zoom-in effect
                                    child: _buildProductCard(context, product),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      //============================================================
                      // Ritual Essentials
                      //===================================================================
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ritual Essentials',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dalityPujaE,
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
                        key: ValueKey(
                          "grid_${ritualItems.length}",
                        ), // 🔥 re-animation on change
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: ritualItems.length,
                          itemBuilder: (context, index) {
                            final product = ritualItems[index];

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3, // ⚠️ MUST match crossAxisCount
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                horizontalOffset: 50, // 👇 bottom se aayega
                                child: FadeInAnimation(
                                  child: ScaleAnimation(
                                    scale: 0.9, // 🔥 slight zoom-in effect
                                    child: _buildProductCard(context, product),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      //============================================================
                      // Others Essentials
                      //===================================================================
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Others Essentials',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.dalityPujaE,
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
                        key: ValueKey(
                          "grid_${otherProduct.length}",
                        ), // 🔥 re-animation on change
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: otherProduct.length,
                          itemBuilder: (context, index) {
                            final product = otherProduct[index];

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              columnCount: 3, // ⚠️ MUST match crossAxisCount
                              duration: const Duration(milliseconds: 400),
                              child: SlideAnimation(
                                horizontalOffset: 50, // 👇 bottom se aayega
                                child: FadeInAnimation(
                                  child: ScaleAnimation(
                                    scale: 0.9, // 🔥 slight zoom-in effect
                                    child: _buildProductCard(context, product),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 Image + Heart Icon
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

          // Divider
          Container(height: 1, color: AppColors.grey300),

          // 🔽 Details Section
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Discount
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
                    Text(
                      '${product.discountPercent}% off',
                      style: text10(color: AppColors.grey500),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Old Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. ${product.oldPrice}/-',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Rs. ${product.price}/-',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),

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
