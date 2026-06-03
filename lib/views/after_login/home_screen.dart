import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/banner_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/custom_loader.dart/product_loader.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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

    // ✅ Dynamic categories
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
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.locationPage,
                                arguments: false,
                              );
                            },
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
                            if (unreadCount == 0)
                              return const SizedBox.shrink();
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

              const SizedBox(height: 12),

              // ── Dynamic Category Chips ───────────────────────────────
              categoryAsync.when(
                loading: () => SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: 5,
                    itemBuilder: (_, __) => Padding(
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
                      // ✅ "All" chip — hamesha pehle
                      _buildChip(
                        label: 'All',
                        categoryId: 'all',
                        imageAsset: 'assets/home/select-all.png',
                        selected: selectedCategory == 'all',
                        ref: ref,
                      ),
                      // ✅ API se aayi categories
                      ...categories.map(
                        (cat) => _buildChip(
                          label: cat.name ?? '',
                          categoryId: cat.id ?? '',
                          // API mein image field hai to use karo,
                          // warna fallback asset
                          networkImage: cat.image,
                          selected: selectedCategory == cat.id,
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Products ─────────────────────────────────────────────
              Expanded(
                child: productState.when(
                  loading: () => const ProductListingSkeleton(),
                  error: (e, _) =>
                      const Center(child: Text("Something went wrong")),
                  data: (state) {
                    final products = state.categoryProducts.take(6).toList();
                    final dailyEss = state.dailyEssentials.take(20).toList();
                    final mostUsed = state.mostUsed.take(20).toList();
                    final hasMoreProducts = state.categoryProducts.length > 6;

                    final bool allEmpty =
                        products.isEmpty &&
                        dailyEss.isEmpty &&
                        mostUsed.isEmpty;

                    if (allEmpty) {
                      return const Center(child: Text("No Products Found"));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(productProvider);
                        ref.invalidate(categoryProvider);
                        await ref.read(productProvider.future);
                      },
                      child: ListView(
                        padding: const EdgeInsets.only(top: 8),
                        children: [
                          // Banners
                          bannerAsync.when(
                            data: (res) => CarouselSlider(
                              options: CarouselOptions(
                                height: 120,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1,
                                autoPlayInterval: const Duration(seconds: 3),
                              ),
                              items: res.data
                                  .map((b) => poojaOfferBanner(b))
                                  .toList(),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => const Text("Something went wrong"),
                          ),
                          const SizedBox(height: 10),

                          // Main product grid
                          AnimationLimiter(
                            key: ValueKey("grid_${products.length}"),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.70,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  columnCount: 2,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    horizontalOffset: 50,
                                    child: FadeInAnimation(
                                      child: ScaleAnimation(
                                        scale: 0.9,
                                        child: ProductCard(
                                          product: products[index],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          if (hasMoreProducts)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TypeOfCategoryPage(
                                      title: 'Buy Item for Pooja',
                                      categoryType: 'allItems',
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "View More",
                                style: text13(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningDark,
                                ),
                              ),
                            ),

                          // Daily Pooja Essentials
                          if (dailyEss.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Daily Pooja Essentials',
                                    style: text15(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TypeOfCategoryPage(
                                              title: 'Daily Pooja Essentials',
                                              categoryType: 'daily',
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
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 175,
                              child: AnimationLimiter(
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: dailyEss.length,
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: SlideAnimation(
                                        horizontalOffset: 50,
                                        child: FadeInAnimation(
                                          child: ProductCard(
                                            product: dailyEss[index],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Most Used Items
                          if (mostUsed.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Most Used Items in Pooja',
                                    style: text15(fontWeight: FontWeight.bold),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const TypeOfCategoryPage(
                                              title: 'Most Used Items in Pooja',
                                              categoryType: 'mostUsed',
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
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 175,
                              child: AnimationLimiter(
                                key: ValueKey("mostUsed_${mostUsed.length}"),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  itemCount: mostUsed.length,
                                  itemBuilder: (context, index) {
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      child: SlideAnimation(
                                        horizontalOffset: 50,
                                        child: FadeInAnimation(
                                          child: GestureDetector(
                                            onTap: () => Navigator.pushNamed(
                                              context,
                                              AppRoutes.productDetails,
                                            ),
                                            child: ProductCard(
                                              product: mostUsed[index],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 100),
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

  /// ✅ Dynamic chip — asset ya network image support karta hai
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
        onTap: () {
          ref.read(productProvider.notifier).filterByCategory(categoryId);
        },
        child: Chip(
          avatar: avatar,
          label: Text(
            label,
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

  Widget poojaOfferBanner(BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B1A), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/icon/mala.png',
              fit: BoxFit.fitWidth,
              height: 28,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: AppColors.white),
                      children: [
                        TextSpan(
                          text: "${banner.title}\n",
                          style: text15(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ).copyWith(height: 1.5),
                        ),
                        TextSpan(
                          text: "${banner.subTitle}.",
                          style: text12(
                            color: AppColors.white.withAlpha(150),
                            fontWeight: FontWeight.w400,
                          ).copyWith(height: 1.5),
                        ),
                        TextSpan(
                          text: ' perfect Pooja ',
                          style: text13(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ).copyWith(height: 1.2),
                        ),
                        const TextSpan(text: '🪔'),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCachedImage(
                      imageUrl: banner.image ?? '',
                      height: 40,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '🎉 Get ',
                            style: text12(color: AppColors.white),
                          ),
                          TextSpan(
                            text: banner.priceOff,
                            style: text14(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' OFF 🎉',
                            style: text12(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget buildDiyaCard(Product product, WidgetRef ref, BuildContext context) {
//   final cartNotifier = ref.read(cartProvider.notifier);
//   final quantity = ref.watch(cartQuantityProvider(product.id ?? '')); // ✅ Fixed

//   final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
//   final currentIndex = ref.watch(imageSliderIndexProvider(product.id ?? ''));

//   return Container(
//     width: 130,

//     margin: const EdgeInsets.only(right: 12),
//     decoration: BoxDecoration(
//       color: AppColors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Image + Heart Icon (same as before)
//         Expanded(
//           child: Stack(
//             children: [
//               Positioned.fill(
//                 child: InkWell(
//                   borderRadius: const BorderRadius.vertical(
//                     top: Radius.circular(12),
//                   ),
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       AppRoutes.productDetails,
//                       arguments: product,
//                     );
//                   },
//                   child: CarouselSlider(
//                     options: CarouselOptions(
//                       autoPlay: false,
//                       viewportFraction: 1,

//                       enlargeCenterPage: false,
//                       onPageChanged: (index, reason) {
//                         ref
//                                 .read(
//                                   imageSliderIndexProvider(
//                                     product.id ?? '',
//                                   ).notifier,
//                                 )
//                                 .state =
//                             index;
//                       },
//                     ),
//                     items: product.images.map((image) {
//                       final cleanImage = image.replaceAll("\\", "/");

//                       return CustomCachedImage(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(12),
//                         ),
//                         imageUrl: cleanImage,
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ),

//               if (product.isRecommended == true)
//                 Positioned(
//                   top: 6,
//                   left: 6,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 3,
//                     ),
//                     margin: const EdgeInsets.only(bottom: 4),
//                     decoration: BoxDecoration(
//                       color: AppColors.warning.withValues(alpha: 0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(Icons.star, color: AppColors.warning, size: 12),
//                   ),
//                 ),

//               Positioned(
//                 top: 6,
//                 right: 6,
//                 child: GestureDetector(
//                   onTap: () {
//                     ref
//                         .read(wishlistProvider.notifier)
//                         .toggle(product.id ?? '');
//                   },
//                   child: Icon(
//                     isWishlisted ? Icons.favorite : Icons.favorite_border,
//                     size: 16,
//                     color: isWishlisted ? AppColors.error : AppColors.grey,
//                   ),
//                 ),
//               ),
//               if (product.images.length >
//                   1) // ← only show dots if more than 1 image
//                 Positioned(
//                   bottom: 5,
//                   left: 5,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.5),
//                           blurRadius: 8,
//                           spreadRadius: 2,
//                         ),
//                       ],
//                     ),
//                     child: AnimatedSmoothIndicator(
//                       activeIndex: currentIndex.clamp(
//                         0,
//                         product.images.length - 1,
//                       ), // ← clamp safety
//                       count: product.images.length,
//                       effect: product.images.length <= 5
//                           ? WormEffect(
//                               dotHeight: 7,
//                               dotWidth: 7,
//                               activeDotColor: AppColors.black,
//                               dotColor: AppColors.white.withOpacity(0.5),
//                             )
//                           : ScrollingDotsEffect(
//                               activeDotColor: AppColors.black,
//                               dotColor: AppColors.white.withOpacity(0.5),
//                               dotHeight: 7,
//                               dotWidth: 7,
//                               spacing: 4,
//                               maxVisibleDots: 5,
//                             ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),

//         Container(height: 1, color: AppColors.grey300),

//         Padding(
//           padding: const EdgeInsets.all(6),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 capitalizeWords(product.title ?? ''),
//                 overflow: TextOverflow.ellipsis,
//                 style: text12(fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 2),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         'Rs. ${product.oldPrice}/-',
//                         style: text8(
//                           color: AppColors.grey,
//                         ).copyWith(decoration: TextDecoration.lineThrough),
//                       ),
//                       SizedBox(width: 8),

//                       Text(
//                         '${product.discountPercent}% off',
//                         style: text10(color: AppColors.grey500),
//                       ),
//                     ],
//                   ),
//                   Text(
//                     'Rs. ${product.price}/-',
//                     style: text11(
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.button,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 5),

//               AnimatedSwitcher(
//                 duration: Duration(milliseconds: 200),
//                 transitionBuilder: (child, animation) {
//                   return ScaleTransition(scale: animation, child: child);
//                 },
//                 child: quantity == 0
//                     ? AppButton(
//                         key: ValueKey('add_button_${product.id}'),
//                         height: 22,
//                         radius: 4,
//                         textStyle: text11(
//                           color: AppColors.white,
//                           fontWeight: FontWeight.w600,
//                         ),
//                         title: "Add",
//                         onTap: () {
//                           cartNotifier.addItem(
//                             CartItem(
//                               productId: product.id ?? '',
//                               title: product.title ?? '',
//                               thumbnail: product.thumbnail ?? '',
//                               price: product.price?.toDouble() ?? 0.0,
//                             ),
//                           );
//                         },
//                       )
//                     : Container(
//                         key: ValueKey('quantity_control_${product.id}'),
//                         height: 22,
//                         decoration: BoxDecoration(
//                           color: AppColors.button,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             InkWell(
//                               onTap: () {
//                                 cartNotifier.decreaseQuantity(product.id ?? '');
//                               },
//                               child: Container(
//                                 width: 22,
//                                 height: 22,
//                                 alignment: Alignment.center,
//                                 child: Icon(
//                                   Icons.remove,
//                                   size: 12,
//                                   color: AppColors.white,
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 color: AppColors.white,
//                                 child: Text(
//                                   '$quantity',
//                                   style: text11(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.button,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             InkWell(
//                               onTap: () {
//                                 cartNotifier.increaseQuantity(product.id ?? '');
//                               },
//                               child: Container(
//                                 width: 22,
//                                 height: 22,
//                                 alignment: Alignment.center,
//                                 child: Icon(
//                                   Icons.add,
//                                   size: 12,
//                                   color: AppColors.white,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
