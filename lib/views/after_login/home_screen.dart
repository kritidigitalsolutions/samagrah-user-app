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
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/wishlist_provider.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/custom_loader.dart/product_loader.dart';
import 'package:samagrah/views/custom_widget/Product_card.dart';
import 'package:samagrah/views/global_widgets/bottom_cart_bar.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

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
    final selectedCategory = productState.value?.selectedCategory ?? "All";
    final location = ref.watch(locationProvider);
    final bannerAsync = ref.watch(bannerProvider);
    return Stack(
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
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.locationPage,
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
                                  (location != null &&
                                          location.city != null &&
                                          location.state != null)
                                      ? "${location.city}, ${location.state}"
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

              // Search Bar
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
                    SizedBox(width: 8),

                    SizedBox(width: 8),
                    _buildFeature(
                      "assets/icon/purse.png",
                      AppColors.infoLight.withAlpha(50),
                      "Wallet",
                      () {
                        Navigator.pushNamed(context, AppRoutes.myWallet);
                      },
                    ),
                    SizedBox(width: 8),
                    _buildFeature(
                      "assets/icon/noti.png",
                      AppColors.warningLighter,

                      "Notification",
                      () {
                        Navigator.pushNamed(context, AppRoutes.notification);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Category Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildChip(
                      'All',
                      "All",
                      "assets/home/select-all.png",
                      selectedCategory == "All",
                      ref,
                    ),
                    _buildChip(
                      'Agri batti',
                      "agarbatti",
                      "assets/home/incense.png",
                      selectedCategory == "agarbatti",
                      ref,
                    ),
                    _buildChip(
                      'Fruits',
                      "fruits",
                      "assets/home/fruit.png",
                      selectedCategory == "fruits",
                      ref,
                    ),
                    _buildChip(
                      'Flowers',
                      "flowes",
                      "assets/home/flower.png",
                      selectedCategory == "flowes",
                      ref,
                    ),
                    _buildChip(
                      'Mala(Gralands)',
                      "mala",
                      "assets/home/mala.png",
                      selectedCategory == "mala",
                      ref,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: productState.when(
                  loading: () => GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemBuilder: (_, __) => const ProductCardSkeleton(),
                  ),

                  error: (e, _) =>
                      const Center(child: Text("Something went wrong")),

                  data: (state) {
                    final products = state.categoryProducts;
                    final dailyEss = state.dailyEssentials;
                    final mostUsed = state.mostUsed;

                    // ✅ Check if ALL lists are empty
                    final bool allEmpty =
                        products.isEmpty &&
                        dailyEss.isEmpty &&
                        mostUsed.isEmpty;

                    if (allEmpty) {
                      return const Center(child: Text("No Products Found"));
                    }
                    return ListView(
                      padding: EdgeInsets.only(top: 8),
                      children: [
                        // Promotional Banner
                        bannerAsync.when(
                          data: (res) {
                            final banners = res.data;

                            return CarouselSlider(
                              options: CarouselOptions(
                                height: 120,
                                autoPlay: true,
                                enlargeCenterPage: true,
                                viewportFraction: 1,
                                autoPlayInterval: Duration(seconds: 3),
                              ),
                              items: banners.map((banner) {
                                return poojaOfferBanner(banner); // ✅ pass data
                              }).toList(),
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => const Text("Something went wrong"),
                        ),
                        const SizedBox(height: 10),

                        AnimationLimiter(
                          key: ValueKey(
                            "grid_${products.length}",
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
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];

                              return AnimationConfiguration.staggeredGrid(
                                position: index,
                                columnCount: 3, // ⚠️ MUST match crossAxisCount
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  horizontalOffset: 50, // 👇 bottom se aayega
                                  child: FadeInAnimation(
                                    child: ScaleAnimation(
                                      scale: 0.9, // 🔥 slight zoom-in effect
                                      child: ProductCard(product: product),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Daily Pooja Essentials
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daily Pooja Essentials',
                                style: text15(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TypeOfCategoryPage(
                                            title: 'Daily Pooja Essentials',
                                            categoryType: 'daily',
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 140,
                          child: AnimationLimiter(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: dailyEss.length,
                              itemBuilder: (context, index) {
                                final product = dailyEss[index];

                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    horizontalOffset: 50, // 👉 right se aayega
                                    child: FadeInAnimation(
                                      child: _buildDiyaCard(product),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Most Used Items
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Most Used Items in Pooja',
                                style: text15(fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TypeOfCategoryPage(
                                            title: 'Most Used Items in Pooja',
                                            categoryType: 'mostUsed',
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 140,
                          child: AnimationLimiter(
                            key: ValueKey(
                              "mostUsed_${mostUsed.length}",
                            ), // 🔥 re-animation support
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: mostUsed.length,
                              itemBuilder: (context, index) {
                                final product = mostUsed[index];

                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 400),
                                  child: SlideAnimation(
                                    horizontalOffset: 50, // 👉 right se slide
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.productDetails,
                                          );
                                        },
                                        child: _buildDiyaCard(product),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ), // Space for bottom nav
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
            child: Center(child: Image.asset(image, width: 20, height: 20)),
          ),
          SizedBox(height: 2),
          Text(title, style: text8(fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildChip(
    String label,
    String type,
    String img,
    bool selected,
    WidgetRef ref,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          ref
              .read(productProvider.notifier)
              .filterByCategory(type.toLowerCase());
        },
        child: Chip(
          avatar: Image.asset(img, width: 18, height: 18),
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

  Widget _buildDiyaCard(Product product) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final quantity = ref.watch(
      cartQuantityProvider(product.id ?? ''),
    ); // ✅ Fixed

    final isWishlisted = ref.watch(isWishlistedProvider(product.id ?? ''));
    final currentIndex = ref.watch(imageSliderIndexProvider(product.id ?? ''));

    return Container(
      width: 120,

      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Heart Icon (same as before)
          Expanded(
            child: Stack(
              children: [
                InkWell(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetails,
                      arguments: product,
                    );
                  },
                  child: CarouselSlider(
                    options: CarouselOptions(
                      autoPlay: false,
                      viewportFraction: 1,

                      enlargeCenterPage: false,
                      onPageChanged: (index, reason) {
                        ref
                                .read(
                                  imageSliderIndexProvider(
                                    product.id ?? '',
                                  ).notifier,
                                )
                                .state =
                            index;
                      },
                    ),
                    items: product.images.map((image) {
                      final cleanImage = image.replaceAll("\\", "/");

                      return CustomCachedImage(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        imageUrl: cleanImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(wishlistProvider.notifier)
                          .toggle(product.id ?? '');
                    },
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: isWishlisted ? AppColors.error : AppColors.grey,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: AnimatedSmoothIndicator(
                      activeIndex: currentIndex,
                      count: product.images.length,
                      effect: product.images.length <= 5
                          ? WormEffect(
                              dotHeight: 7,
                              dotWidth: 7,
                              activeDotColor: AppColors.black,
                              dotColor: AppColors.white.withOpacity(0.5),
                            )
                          : ScrollingDotsEffect(
                              activeDotColor: AppColors.black,
                              dotColor: AppColors.white.withOpacity(0.5),
                              dotHeight: 7,
                              dotWidth: 7,
                              spacing: 4,
                              maxVisibleDots: 5,
                            ),
                    ),
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
                        product.title ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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

                AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: quantity == 0
                      ? AppButton(
                          key: ValueKey('add_button_${product.id}'),
                          height: 22,
                          radius: 4,
                          textStyle: text11(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          title: "Add",
                          onTap: () {
                            cartNotifier.addItem(
                              CartItem(
                                productId: product.id ?? '',
                                title: product.title ?? '',
                                thumbnail: product.thumbnail ?? '',
                                price: product.price?.toDouble() ?? 0.0,
                              ),
                            );
                          },
                        )
                      : Container(
                          key: ValueKey('quantity_control_${product.id}'),
                          height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  cartNotifier.decreaseQuantity(
                                    product.id ?? '',
                                  );
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.remove,
                                    size: 12,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.center,
                                  color: AppColors.white,
                                  child: Text(
                                    '$quantity',
                                    style: text11(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.button,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  cartNotifier.increaseQuantity(
                                    product.id ?? '',
                                  );
                                },
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.add,
                                    size: 12,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget poojaOfferBanner(BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A1B1A), // dark maroon
            Color(0xFFB71C1C), // red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // 🔶 Top Decoration (mala image)
          Positioned(
            top: 0,
            left: 0,
            right: 0, // 👈 important (full width)
            child: Image.asset(
              'assets/icon/mala.png',
              fit: BoxFit.fitWidth, // 👈 fills full width nicely
              height: 28, // adjust as needed
            ),
          ),

          // 🔻 Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                // Left Text
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
                        TextSpan(text: '🪔'),
                      ],
                    ),
                  ),
                ),

                // Right Section
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
