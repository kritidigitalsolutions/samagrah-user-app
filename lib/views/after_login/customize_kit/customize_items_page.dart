import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';

class CustomizeItemsPage extends ConsumerStatefulWidget {
  const CustomizeItemsPage({super.key});

  @override
  ConsumerState<CustomizeItemsPage> createState() => _CustomizeItemsPageState();
}

class _CustomizeItemsPageState extends ConsumerState<CustomizeItemsPage> {
  @override
  Widget build(BuildContext context) {
    final nameOfKit = ref.read(kitNameProvider);
    final productState = ref.watch(productProvider);
    final cart = ref.watch(customizeKitCartProvider); // ← Watch cart
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);
    final selectedKitCategory =
        productState.value?.selectedKitCategory ?? "All";
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: nameOfKit,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset("assets/icon/plate.png", width: 70, height: 70),
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: text14(
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
              cursorColor: AppColors.black,
              decoration: InputDecoration(
                hintText: 'diya, puja thali...',
                hintStyle: text14(color: AppColors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.white,
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

          // Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildChip(
                  'All',
                  "All",
                  "assets/home/select-all.png",
                  selectedKitCategory == "All",
                  ref,
                ),
                _buildChip(
                  'Agri batti',
                  "agarbatti",
                  "assets/home/incense.png",
                  selectedKitCategory == "agarbatti",
                  ref,
                ),
                _buildChip(
                  'Fruits',
                  "fruits",
                  "assets/home/fruit.png",
                  selectedKitCategory == "fruits",
                  ref,
                ),
                _buildChip(
                  'Flowers',
                  "flowes",
                  "assets/home/flower.png",
                  selectedKitCategory == "flowes",
                  ref,
                ),
                _buildChip(
                  'Mala(Gralands)',
                  "mala",
                  "assets/home/mala.png",
                  selectedKitCategory == "mala",
                  ref,
                ),
              ],
            ),
          ),
          // Promotional Banners
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildPromoBanner(
                    Icons.local_offer,
                    'Get 5% Off on your first\npooja package order',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPromoBanner(
                    Icons.delivery_dining,
                    'Free Delivery on Puja Essentials\nOn orders above ₹499',
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: productState.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) =>
                  const Center(child: Text("Something went wrong")),

              data: (state) {
                final products = state.categoryKitProducts;

                if (products.isEmpty) {
                  return const Center(child: Text("No Products Found"));
                }
                return AnimationLimiter(
                  key: ValueKey(
                    "grid_${products.length}",
                  ), // 🔥 re-animation on change
                  child: GridView.builder(
                    // shrinkWrap: true,
                    // physics: const NeverScrollableScrollPhysics(),
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
                      final quantity = cart[product.id] ?? 0;

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: 3, // ⚠️ MUST match crossAxisCount
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          verticalOffset: 50, // 👇 bottom se aayega
                          child: FadeInAnimation(
                            child: ScaleAnimation(
                              scale: 0.9, // 🔥 slight zoom-in effect
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.productDetails,
                                  );
                                },
                                child: _buildProductCard(
                                  product,
                                  quantity,
                                  cartNotifier,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          //  SizedBox(height: 50),

          // Next Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.button,
              // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
            child: AppButton(
              title: "Next",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.selectedCusKit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.button, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
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
              .filterByCustKitCategory(type.toLowerCase());
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

  Widget _buildProductCard(
    Product product,
    int quantity,
    CustomizeKitCartNotifier cartNotifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image + Heart
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CustomCachedImage(
                      imageUrl: "http://192.168.1.40:8000/${product.thumbnail}",
                      height: 90,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned(
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

          // Details
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

                const SizedBox(height: 8),

                // Add / Quantity Controls
                if (quantity == 0)
                  AppButton(
                    height: 26,
                    radius: 4,
                    textStyle: text11(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    title: "Add",
                    onTap: () => cartNotifier.addItem(product),
                  )
                else
                  Container(
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.button.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.button),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              cartNotifier.removeItem(product.id ?? ''),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.remove,
                              size: 16,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        Text(
                          quantity.toString(),
                          style: text13(
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => cartNotifier.addItem(product),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: AppColors.button,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
