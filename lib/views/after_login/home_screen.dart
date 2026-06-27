import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/banner_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/pending_review_provider.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/custom_loader.dart/product_loader.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/custom_widget/pending_review_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';

import '../../view_model/after_login_provider/home_provider/notification_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final productState = ref.watch(productProvider);
    final selectedCategory = productState.value?.selectedCategory ?? "all";
    final location = ref.watch(locationProvider);
    final bannerAsync = ref.watch(bannerProvider);
    final categoryAsync = ref.watch(categoryProvider);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(color: AppColors.background),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────
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
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.locationPage,
                              arguments: false,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 14,
                                  color: AppColors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (location?.city != null &&
                                          location?.state != null)
                                      ? "${location!.city}, ${location.state}"
                                      : "Select Location",
                                  style: text12(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      userAsync.when(
                        data: (user) => GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, AppRoutes.profile),
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

              // ── Search + Icons ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.searchProduct,
                        ),
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
                    const SizedBox(width: 8),
                    _buildFeature(
                      "assets/icon/purse.png",
                      AppColors.infoLight.withAlpha(50),
                      "Wallet",
                      () => Navigator.pushNamed(context, AppRoutes.myWallet),
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildFeature(
                          "assets/icon/notification.png",
                          AppColors.warningLighter,
                          "Notification",
                          () => Navigator.pushNamed(
                            context,
                            AppRoutes.notification,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, _) {
                            final unreadCount = ref.watch(
                              notificationProvider.select((s) => s.unreadCount),
                            );
                            if (unreadCount == 0) {
                              return const SizedBox.shrink();
                            }
                            return Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Pending Review Card ──────────────────────────────────
              Consumer(
                builder: (context, ref, _) {
                  final reviewsAsync = ref.watch(pendingReviewProvider);
                  return reviewsAsync.when(
                    data: (items) {
                      if (items.isEmpty) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: PendingReviewCard(item: items.first),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  );
                },
              ),

              // ── Category Chips ───────────────────────────────────────
              categoryAsync.when(
                loading: () => SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (_, _) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.grey300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (categories) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildChip(
                        label: 'All',
                        categoryId: 'all',
                        imageAsset: 'assets/home/select-all.png',
                        selected: selectedCategory == 'all',
                        ref: ref,
                      ),
                      ...categories.map(
                        (cat) => _buildChip(
                          label: cat.name ?? '',
                          categoryId: cat.id ?? '',
                          networkImage: cat.image,
                          selected: selectedCategory == cat.id,
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Products Area ────────────────────────────────────────
              Expanded(
                child: productState.when(
                  loading: () => const ProductListingSkeleton(),
                  error: (e, _) =>
                      const Center(child: Text("Something went wrong")),
                  data: (state) {
                    final isFiltered = state.selectedCategory != 'all';

                    // ── Filtered: flat grid ──────────────────────────
                    if (isFiltered) {
                      final products = state.categoryProducts;
                      if (products.isEmpty) {
                        return const Center(child: Text("No Products Found"));
                      }
                      return RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 100),
                          children: [_buildProductGrid(products, ref)],
                        ),
                      );
                    }

                    // ── Default: Sectioned Home ──────────────────────
                    final hasSections =
                        state.mostTrending.isNotEmpty ||
                        state.dailyRituals.isNotEmpty ||
                        state.popularProducts.isNotEmpty ||
                        state.poojaEssentials.isNotEmpty;

                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 100),
                        children: [
                          // ── Banners ──────────────────────────────
                          bannerAsync.when(
                            data: (res) => CarouselSlider(
                              options: CarouselOptions(
                                height: 120,
                                autoPlay: true,

                                enlargeCenterPage: true,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 6),
                              ),
                              items: res.data
                                  .map((b) => poojaOfferBanner(b))
                                  .toList(),
                            ),
                            loading: () => const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (e, _) => const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),

                          if (hasSections) ...[
                            // ── Most Trending ───────────────────────
                            if (state.mostTrending.isNotEmpty) ...[
                              _buildSectionHeader('🔥 Most Trending', context),
                              _buildHorizontalScroll(state.mostTrending),
                              const SizedBox(height: 16),
                            ],

                            // ── Daily Rituals ───────────────────────
                            if (state.dailyRituals.isNotEmpty) ...[
                              _buildSectionHeader('🪔 Daily Rituals', context),
                              _buildHorizontalScroll(state.dailyRituals),
                              const SizedBox(height: 16),
                            ],

                            // ── Popular ─────────────────────────────
                            if (state.popularProducts.isNotEmpty) ...[
                              _buildSectionHeader('⭐ Popular', context),
                              _buildHorizontalScroll(state.popularProducts),
                              const SizedBox(height: 16),
                            ],

                            // ── Pooja Essentials (grid) ─────────────
                            if (state.poojaEssentials.isNotEmpty) ...[
                              _buildSectionHeader(
                                '🛕 Pooja Essentials',
                                context,
                              ),
                              _buildProductGrid(
                                state.poojaEssentials.take(6).toList(),
                                ref,
                              ),
                              if (state.poojaEssentials.length > 6)
                                _buildViewMore(context),
                              const SizedBox(height: 16),
                            ],
                          ] else ...[
                            // ── Fallback: All Products grid ──────────
                            _buildSectionHeader('All Products', context),
                            _buildProductGrid(
                              state.allProducts.take(6).toList(),
                              ref,
                            ),
                            if (state.allProducts.length > 6)
                              _buildViewMore(context),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const BottomCartBar(),
      ],
    );
  }

  // ── Refresh ────────────────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    ref.invalidate(productProvider);
    ref.invalidate(categoryProvider);
    ref.invalidate(pendingReviewProvider);
    await ref.read(productProvider.future);
  }

  // ── Section Header ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: text15(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TypeOfCategoryPage(
                  title: 'Buy Item for Pooja',
                  categoryType: 'allItems',
                ),
              ),
            ),
            child: Text(
              'See All',
              style: text12(
                color: AppColors.button,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Horizontal Scroll Row ──────────────────────────────────────────────────
  Widget _buildHorizontalScroll(List<Product> products) {
    return SizedBox(
      height: 228,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: products.length,
        itemBuilder: (context, index) => SizedBox(
          width: 140,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ProductCard(product: products[index]),
          ),
        ),
      ),
    );
  }

  // ── 3-col Animated Grid ────────────────────────────────────────────────────
  Widget _buildProductGrid(List<Product> products, WidgetRef ref) {
    return AnimationLimiter(
      key: ValueKey("grid_${products.length}_${products.hashCode}"),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = (constraints.maxWidth - 16 - 12) / 3;
          final imageHeight = cardWidth;
          const infoHeight = 105.0;
          final ratio = cardWidth / (imageHeight + infoHeight);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: ratio,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: products.length,
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
                      child: ProductCard(product: products[index]),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ── View More Button ───────────────────────────────────────────────────────
  Widget _buildViewMore(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const TypeOfCategoryPage(
            title: 'Buy Item for Pooja',
            categoryType: 'allItems',
          ),
        ),
      ),
      child: Text(
        "View More",
        style: text13(
          fontWeight: FontWeight.w600,
          color: AppColors.warningDark,
        ),
      ),
    );
  }

  // ── Feature Icon (Wallet / Notification) ──────────────────────────────────
  Widget _buildFeature(
    String image,
    Color color,
    String title,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: Image.asset(image, width: 20, height: 20),
          ),
          const SizedBox(height: 2),
          Text(title, style: text8(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  // ── Category Chip ──────────────────────────────────────────────────────────
  Widget _buildChip({
    required String label,
    required String categoryId,
    String? imageAsset,
    String? networkImage,
    required bool selected,
    required WidgetRef ref,
  }) {
    Widget avatar;
    if (networkImage != null && networkImage.isNotEmpty) {
      avatar = ClipOval(
        child: CustomCachedImage(
          imageUrl: networkImage,
          width: 18,
          height: 18,
          fit: BoxFit.cover,
        ),
      );
    } else if (imageAsset != null) {
      avatar = Image.asset(imageAsset, width: 18, height: 18);
    } else {
      avatar = const SizedBox(width: 18, height: 18);
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () =>
            ref.read(productProvider.notifier).filterByCategory(categoryId),
        child: Chip(
          avatar: avatar,
          label: Text(
            capitalizeWords(label),
            style: text13(color: selected ? AppColors.button : AppColors.black),
          ),
          backgroundColor: selected
              ? AppColors.button.withAlpha(30)
              : AppColors.white,
          side: BorderSide(color: selected ? AppColors.button : AppColors.grey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ── Banner Widget (with key offer/coupon details) ───────────────────────────
  // ── Banner Widget (compact, same fixed size, no overflow) ───────────────────
  Widget poojaOfferBanner(BannerData banner) {
    final coupon = banner.coupon;
    Widget imageOnlyBanner() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: (banner.image ?? '').isNotEmpty
              ? CustomCachedImage(
                  imageUrl: banner.image!,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                )
              : Container(
                  height: 120,
                  color: AppColors.grey200,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.grey500,
                    ),
                  ),
                ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        final code = coupon?.code;
        if (code != null && code.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: code));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Coupon code '$code' copied!"),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.button,
            ),
          );
        }
      },
      child: imageOnlyBanner(),
    );

  }
}
