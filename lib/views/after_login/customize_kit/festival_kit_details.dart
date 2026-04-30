import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

class FestivalKitDetails extends ConsumerStatefulWidget {
  const FestivalKitDetails({super.key});

  @override
  ConsumerState<FestivalKitDetails> createState() => _FestivalKitDetailsState();
}

class _FestivalKitDetailsState extends ConsumerState<FestivalKitDetails> {
  DefaultKitData? _lastKit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final kit = ModalRoute.of(context)!.settings.arguments as DefaultKitData;

    // 👇 Only initialize if NEW kit
    if (_lastKit?.id != kit.id) {
      _lastKit = kit;

      Future.microtask(() {
        ref.read(customizeKitProvider.notifier).initializeFromDefault(kit);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kit = ModalRoute.of(context)!.settings.arguments as DefaultKitData;
    final isFestival = ref.watch(isFestivalProvider);
    final isLoading = ref.watch(defaultKitLoaderPro);

    // Watch the customized items
    final customizedItems = ref.watch(customizeKitProvider);
    final notifier = ref.read(customizeKitProvider.notifier);

    final totalPrice = notifier.totalPrice;
    // final originalTotalPrice = notifier.originalTotalPrice;
    final savings = notifier.savings;

    final isCustomizeKit =
        customizedItems.length != kit.items.length ||
        customizedItems.any(
          (item) => kit.items.every(
            (orig) =>
                orig.product?.id != item.product?.id ||
                (orig.quantity ?? 1) != (item.quantity ?? 1),
          ),
        );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: kit.name ?? "Default Kit",
        subtitle: 'A complete pooja kit specially',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/god.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text('Items Included', style: text18()),
            const SizedBox(height: 10),

            // Customize Toggle + Add Button
            if (!isFestival)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      "Customize Kit",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 0.78,
                      child: Switch(
                        value:
                            customizedItems.length != kit.items.length ||
                            customizedItems.any(
                              (item) => kit.items.every(
                                (orig) =>
                                    orig.product?.id != item.product?.id ||
                                    (orig.quantity ?? 1) !=
                                        (item.quantity ?? 1),
                              ),
                            ),
                        activeThumbColor: AppColors.button,
                        onChanged: (val) {
                          if (!val) {
                            notifier.resetToDefault();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedIconButton(
                      height: 30,
                      text: "Add More",
                      icon: Icons.add,
                      onPressed: () {
                        _showAddItemBottomSheet(context, ref);
                      },
                    ),
                  ],
                ),
              ),

            Expanded(
              child: customizedItems.isEmpty
                  ? const Center(child: Text("No items in kit"))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: customizedItems.length,
                      itemBuilder: (context, index) {
                        final item = customizedItems[index];
                        final product = item.product;
                        final qty = item.quantity ?? 1;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildCustomizableItemCard(
                            context,
                            ref,
                            product,
                            qty,
                            index,
                            !isFestival, // can customize if not festival
                          ),
                        );
                      },
                    ),
            ),

            // Price Summary
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.button,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        "Kit Price",
                        style: text15(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),

                      Text(
                        "₹${kit.totalPrice}",
                        style: text13(
                          color: AppColors.white.withOpacity(0.7),
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 8),
                      if (isCustomizeKit)
                        Text(
                          "₹$totalPrice",
                          style: text18(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      if (!isCustomizeKit)
                        Text(
                          "₹${kit.kitPrice}",
                          style: text18(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  if (isCustomizeKit)
                    if (savings > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        "You Save ₹$savings",
                        style: text13(color: Colors.white70),
                      ),
                    ],
                  if (!isCustomizeKit)
                    Text(
                      "Saving ₹${kit.savings.toString()}",
                      style: text15(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: AppButton(
                title: isLoading ? "Creating Kit..." : "Buy Now",
                isLoading: isLoading, // Add loading support in your AppButton
                onTap: isLoading
                    ? null
                    : () => _placeOrder(
                        context,
                        customizedItems,
                        kit.name ?? "Pooja Kit",
                        ref,
                        isFestival,
                        kit,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    List<Item> selectedItems,
    String kitName,
    WidgetRef ref,
    bool isFestival,
    DefaultKitData kit,
  ) async {
    try {
      final notifier = ref.read(customizeKitProvider.notifier);
      final isCustomized = notifier.isCustomized;

      // ✅ Case 1: Festival kit → direct
      if (isFestival) {
        Navigator.pushNamed(context, AppRoutes.kitOrderSummary, arguments: kit);

        return;
      }

      // ✅ Case 2: NOT customized → direct
      if (!isCustomized) {
        Navigator.pushNamed(context, AppRoutes.kitOrderSummary, arguments: kit);
        return;
      }

      // ✅ Case 3: Customized → create kit API
      if (selectedItems.isEmpty) {
        AppSnackbar.show(
          context,
          message: "Please add items to your kit",
          type: SnackBarType.warning,
        );
        return;
      }

      ref.read(defaultKitLoaderPro.notifier).state = true;

      final List<KitItem> kitItems = selectedItems.map((item) {
        return KitItem(
          productId: item.product?.id ?? '',
          quantity: item.quantity ?? 1,
        );
      }).toList();

      final request = CreateKitRequest(
        name: kitName,
        baseKit: null,
        items: kitItems,
      );

      final createdKit = await ref
          .read(userDraftKits.notifier)
          .createDraftKit(request);

      AppSnackbar.show(
        context,
        message: "Kit created successfully!",
        type: SnackBarType.success,
      );

      Navigator.pushNamed(
        context,
        AppRoutes.kitOrderSummary,
        arguments: createdKit,
      );
    } catch (e, stackTrace) {
      debugPrint("Error creating kit: $e\n$stackTrace");

      AppSnackbar.show(
        context,
        message: "Failed to create kit: ${e.toString()}",
        type: SnackBarType.error,
      );
    } finally {
      ref.read(defaultKitLoaderPro.notifier).state = false;
    }
  }

  Widget _buildCustomizableItemCard(
    BuildContext context,
    WidgetRef ref,
    UserDraftProduct? product,
    int qty,
    int index,
    bool canCustomize,
  ) {
    final notifier = ref.read(customizeKitProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 6, spreadRadius: 2, color: AppColors.grey100),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomCachedImage(
              imageUrl: product?.media?.image.firstOrNull ?? '',
              height: 55,
              width: 65,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.title ?? "Unknown Item",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "₹${product?.pricing?.price ?? 0}",
                  style: text16(
                    color: AppColors.button,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (canCustomize)
            Row(
              children: [
                IconButton(
                  onPressed: () => notifier.updateQuantity(index, qty - 1),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                ),
                Text("$qty", style: text16(fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => notifier.updateQuantity(index, qty + 1),
                  icon: const Icon(
                    Icons.add_circle_outline,
                    color: AppColors.green,
                  ),
                ),
                IconButton(
                  onPressed: () => notifier.deleteItem(index),
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                ),
              ],
            )
          else
            Text("Qty: $qty", style: text13(color: AppColors.button)),
        ],
      ),
    );
  }

  // ================== Add Item Bottom Sheet ==================
  void _showAddItemBottomSheet(BuildContext context, WidgetRef ref) {
    final kitNotifier = ref.read(customizeKitProvider.notifier);
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return CustomizeAddItemsBottomSheet(
              scrollController: scrollController,
              onItemAdded: (Product product) {
                final defaultProduct = _convertToDefaultProduct(product);
                kitNotifier.addItem(defaultProduct, quantity: 1);
              },
            );
          },
        );
      },
    ).whenComplete(() {
      // Bottom sheet band hone ke baad cart clear kar do
      cartNotifier.clearCart();
    });
  }

  UserDraftProduct _convertToDefaultProduct(Product product) {
    return UserDraftProduct(
      id: product.id,
      title: product.title,
      pricing: Pricing(
        price: product.price,
        mrp: product.oldPrice, // oldPrice ko MRP maan rahe hain
        currency: "INR",
      ),
      media: Media(
        image: product.thumbnail != null
            ? [product.thumbnail.toString()]
            : (product.images.isNotEmpty
                  ? product.images.map((e) => e.toString()).toList()
                  : []),
      ),
      slug: '',
    );
  }
}

class CustomizeAddItemsBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;
  final Function(Product) onItemAdded;

  const CustomizeAddItemsBottomSheet({
    super.key,
    required this.scrollController,
    required this.onItemAdded,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final cart = ref.watch(customizeKitCartProvider);
    final customizedItems = ref.watch(customizeKitProvider); // Real Kit
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);

    final selectedKitCategory =
        productState.value?.selectedKitCategory ?? "All";

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add Items",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),

        // Search Bar (aapke code mein missing tha, main add kar raha hoon)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: text14(
              fontWeight: FontWeight.normal,
              color: AppColors.black,
            ),
            cursorColor: AppColors.black,
            decoration: InputDecoration(
              hintText: 'Search diya, thali, agarbatti...',
              hintStyle: text14(color: AppColors.grey),
              prefixIcon: const Icon(Icons.search, color: AppColors.grey),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
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
                "garland",
                "assets/home/mala.png",
                selectedKitCategory == "garland",
                ref,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Products Grid
        Expanded(
          child: productState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: Text("Something went wrong")),
            data: (state) {
              final products = state.categoryKitProducts;

              if (products.isEmpty) {
                return const Center(child: Text("No Products Found"));
              }

              return AnimationLimiter(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];

                    // Real check from customize kit
                    final isInRealKit = customizedItems.any(
                      (item) => item.product?.id == product.id,
                    );

                    final cartQuantity = cart[product.id] ?? 0;

                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 3,
                      duration: const Duration(milliseconds: 380),
                      child: SlideAnimation(
                        verticalOffset: 40,
                        child: FadeInAnimation(
                          child: _buildProductCard(
                            context,
                            product,
                            cartQuantity,
                            isInRealKit,
                            cartNotifier,
                            onItemAdded,
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
      ],
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    int cartQuantity,
    bool isInRealKit,
    CustomizeKitCartNotifier cartNotifier,
    Function(Product) onItemAdded,
  ) {
    final bool isAdded = isInRealKit || cartQuantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                InkWell(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  onTap: () {
                    openProductBottomSheet(context, product.id ?? '');
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CustomCachedImage(
                      imageUrl: product.thumbnail ?? '',
                      height: 100,
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

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title ?? 'N/A',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text12(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.price}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Text(
                      '${product.discountPercent ?? 0}% off',
                      style: text10(color: AppColors.grey500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (!isAdded)
                  AppButton(
                    height: 32,
                    radius: 8,
                    textStyle: text12(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    title: "Add",
                    onTap: () {
                      cartNotifier.addItem(product);
                      onItemAdded(product);
                    },
                  )
                else
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.button.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.button),
                    ),
                    child: Center(
                      child: Text(
                        isInRealKit ? "In Kit" : "$cartQuantity Added",
                        style: text13(
                          fontWeight: FontWeight.bold,
                          color: AppColors.button,
                        ),
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
}

void openProductBottomSheet(BuildContext context, String productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailsBottomSheet(productId: productId),
  );
}
