import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:samagrah/views/service_pages/location_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final selectedCategory = productState.value?.selectedCategory ?? "All";
    final location = ref.watch(locationProvider);
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
                    // _buildFeature(
                    //   "assets/icon/category.png",
                    //   AppColors.button.withAlpha(20),
                    //   "Categories",
                    //   () {
                    //     Navigator.pushNamed(context, AppRoutes.comparisionPage);
                    //   },
                    // ),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),

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
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 120,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 1,
                            autoPlayInterval: Duration(seconds: 3),
                          ),
                          items: [
                            poojaOfferBanner(),
                            poojaOfferBanner(),
                            poojaOfferBanner(),
                          ],
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
                                      child: _buildProductCard(product),
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
                              Text(
                                'View all >',
                                style: text13(color: AppColors.warningDark),
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

        // // Replace your old Positioned + rainbowButton() with this:
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            // ← Ye center mein rakhega
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10, // left-right padding
                vertical: 8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.button,
                        radius: 20,
                        child: Center(
                          child: Image.asset(
                            "assets/icon/diya2.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "View Cart >",
                        style: text15(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "3 items",
                        style: text13(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildDiyaCard(Product product) {
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
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey.shade300),

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

  Widget poojaOfferBanner() {
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
            padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                // Left Text
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'Get Everything\n',
                          style: text20(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ).copyWith(height: 1.5),
                        ),

                        TextSpan(
                          text: 'you need for a\n',
                          style: text14(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ).copyWith(height: 1.5),
                        ),
                        TextSpan(
                          text: 'perfect Pooja ',
                          style: text14(
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
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: '🎉 ', style: TextStyle(fontSize: 16)),
                          TextSpan(
                            text: 'Get ',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: '20%',
                            style: text18(
                              color: AppColors.warning,

                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' OFF 🎉',
                            style: text16(color: AppColors.white),
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
