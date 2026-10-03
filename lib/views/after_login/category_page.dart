import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_res/category_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/utils/auth_guard.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final productState = ref.watch(productProvider);
    final categoryAsync = ref.watch(categoryProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.background),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header
                Container(
                  decoration: BoxDecoration(color: AppColors.headerCard),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (Navigator.canPop(context)) ...[
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_left,
                                  color: AppColors.black,
                                  size: 30,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Everything for your',
                                  style: text15(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Puja',
                                  style: text15(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        userAsync.when(
                          data: (user) {
                            final imgUrl = (user?['profileImage'] ?? '').toString();
                            // ── Apple 5.1.1(v): profile is account-based → auth gate
                            return GestureDetector(
                              onTap: () => AuthGuard.run(
                                context,
                                message:
                                    'Sign in to view and manage your profile.',
                                onAuthed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.profile,
                                ),
                              ),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.grey200,
                                ),
                                child: ClipOval(
                                  child: imgUrl.isNotEmpty
                                      ? CustomCachedImage(
                                          imageUrl: imgUrl,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          shape: BoxShape.circle,
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 30,
                                          color: AppColors.grey,
                                        ),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          error: (e, _) => GestureDetector(
                            onTap: () => AuthGuard.run(
                              context,
                              message:
                                  'Sign in to view and manage your profile.',
                              onAuthed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.profile,
                              ),
                            ),
                            child: const Icon(Icons.person, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.searchProduct),
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
                          contentPadding: const EdgeInsets.symmetric(
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

                // ── Body
                Expanded(
                  child: productState.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        const Center(child: Text("Something went wrong")),
                    data: (state) {
                      // Saare products ek pool (deduplicated)
                      final allProducts = state.allProducts;

                      return categoryAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => const Center(
                          child: Text("Could not load categories"),
                        ),
                        data: (categories) {
                          if (categories.isEmpty) {
                            return const Center(
                              child: Text("No categories found"),
                            );
                          }

                          // Har category ke liye filtered products
                          final sections = categories.map((cat) {
                            final filtered = allProducts.where((p) {
                              final catId = p.categoryId?.id ?? '';
                              return catId.isNotEmpty &&
                                  catId == (cat.id ?? '');
                            }).toList();
                            return _Section(category: cat, products: filtered);
                          }).toList();

                          final allEmpty = sections.every(
                            (s) => s.products.isEmpty,
                          );
                          if (allEmpty) {
                            return const Center(
                              child: Text("No Products Found"),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(productProvider);
                              ref.invalidate(categoryProvider);
                              await ref.read(productProvider.future);
                            },
                            child: ListView.builder(
                              padding: EdgeInsets.only(top: 10),
                              itemCount: sections.length,
                              itemBuilder: (context, i) {
                                final s = sections[i];
                                if (s.products.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return _buildSection(context, s);
                              },
                            ),
                          );
                        },
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

  Widget _buildSection(BuildContext context, _Section s) {
    final preview = s.products.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (s.category.image != null &&
                      s.category.image!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CustomCachedImage(
                        imageUrl: s.category.image!,
                        width: 22,
                        height: 22,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    capitalizeWords(s.category.name ?? ''),
                    style: text15(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TypeOfCategoryPage(
                      title: s.category.name ?? '',
                      categoryType: s.category.id ?? '',
                    ),
                  ),
                ),
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

        // Grid
        AnimationLimiter(
          key: ValueKey('cat_${s.category.id}_${preview.length}'),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textScale =
                  MediaQuery.maybeTextScalerOf(context)?.scale(1.0) ?? 1.0;
              final cardWidth = (constraints.maxWidth - 16 - 12) / 3;
              final imageHeight = cardWidth;
              final dynamicInfoHeight =
                  (120.0 * textScale).clamp(115.0, 160.0);
              final ratio = cardWidth / (imageHeight + dynamicInfoHeight);

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: ratio, // ← dynamic
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: preview.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    columnCount: 3,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      horizontalOffset: 50,
                      child: FadeInAnimation(
                        child: ScaleAnimation(
                          scale: 0.9,
                          child: ProductCard(product: preview[index]),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Section {
  final CategoryData category;
  final List<Product> products;
  const _Section({required this.category, required this.products});
}
