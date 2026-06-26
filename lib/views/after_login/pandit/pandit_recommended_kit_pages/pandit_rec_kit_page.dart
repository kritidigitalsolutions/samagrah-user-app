import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/model/response/product_res/sub_category_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/sub_category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

import '../../../../model/request/payment_req/payment_reqs_models.dart';
import '../../../../view_model/after_login_provider/checkout_providers/address.provider.dart';

// ─── Helper ──────────────────────────────────────────────────────────────────

SubCategoryData? _findSubCategoryById(
  List<SubCategoryData> subCategories,
  String? id,
) {
  if (id == null || id.isEmpty) return null;
  try {
    return subCategories.firstWhere((c) => (c.id?.trim() ?? '') == id.trim());
  } catch (_) {
    return null;
  }
}

// ════════════════════════════════════════════════════════════
//  MAIN PAGE — Category list → tap → products sheet with cart
// ════════════════════════════════════════════════════════════

class PanditRecKitPage extends ConsumerStatefulWidget {
  const PanditRecKitPage({super.key});

  @override
  ConsumerState<PanditRecKitPage> createState() => _PanditRecKitPageState();
}

class _PanditRecKitPageState extends ConsumerState<PanditRecKitPage> {
  /// Pandit ke recommended subcategories (CustomSamagriItem list)
  List<CustomSamagriItem>? _kitItems;

  /// User ka cart: productId → quantity
  final Map<String, int> _cart = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_kitItems != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    _kitItems = args is List<CustomSamagriItem>
        ? List<CustomSamagriItem>.from(args)
        : <CustomSamagriItem>[];
  }

  // ─── Cart helpers ─────────────────────────────────────────

  int _cartTotal() => _cart.values.fold(0, (a, b) => a + b);

  double _cartPrice(List<Product> allProducts) {
    double total = 0;
    _cart.forEach((productId, qty) {
      try {
        final p = allProducts.firstWhere((p) => p.id == productId);
        total += (p.price ?? 0) * qty;
      } catch (_) {}
    });
    return total;
  }

  void _addToCart(String productId) =>
      setState(() => _cart[productId] = (_cart[productId] ?? 0) + 1);

  void _removeFromCart(String productId) {
    final current = _cart[productId] ?? 0;
    setState(() {
      if (current <= 1) {
        _cart.remove(productId);
      } else {
        _cart[productId] = current - 1;
      }
    });
  }

  // ─── Buy Now ──────────────────────────────────────────────

  void _navigateToOrderSummary(
    BuildContext context,
    List<Product> allProducts,
  ) {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to cart first.')),
      );
      return;
    }

    final customizedItems = _cart.entries
        .map((e) => VerifyItem(productId: e.key, quantity: e.value))
        .toList();

    ref.read(bookingItemProvider.notifier).state = customizedItems;
    ref.read(totalPriceProvider.notifier).state = _cartPrice(allProducts);

    Navigator.pushNamed(context, AppRoutes.addressPage);
  }

  // ─── Build ────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final kitItems = _kitItems ?? [];
    final subCategoryAsync = ref.watch(subCategoryProvider);
    final productState = ref.watch(productProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Samagri Kit',
        subtitle: 'Pandit Ji Recommended',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/god.png',
              width: 70,
              height: 70,
              errorBuilder: (_, _, _) => const SizedBox(width: 70),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Summary Banner ──
            _KitSummary(
              subCategoryCount: kitItems.length,
              cartItemCount: _cartTotal(),
            ),

            // ── Info ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap a subcategory to browse & add products to cart',
                      style: text12(color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Category Cards ──
            Expanded(
              child: kitItems.isEmpty
                  ? const _EmptyKit()
                  : subCategoryAsync.when(
                      loading: () => _buildList(kitItems, [], isLoading: true),
                      error: (_, _) => _buildList(kitItems, []),
                      data: (subCategories) =>
                          _buildList(kitItems, subCategories),
                    ),
            ),
          ],
        ),
      ),

      // ── Bottom Bar ──
      bottomNavigationBar: productState.maybeWhen(
        data: (state) => _BottomBar(
          cartCount: _cartTotal(),
          cartPrice: _cartPrice(state.allProducts),
          onBuyNow: () => _navigateToOrderSummary(context, state.allProducts),
        ),
        orElse: () => _BottomBar(cartCount: 0, cartPrice: 0, onBuyNow: () {}),
      ),
    );
  }

  // ─── Category list ────────────────────────────────────────

  Widget _buildList(
    List<CustomSamagriItem> kitItems,
    List<SubCategoryData> subCategories, {
    bool isLoading = false,
  }) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: kitItems.length,
      itemBuilder: (context, index) {
        final item = kitItems[index];
        final subCategoryData = _findSubCategoryById(subCategories, item.id);
        final imageUrl = subCategoryData?.image ?? '';
        final subCategoryName =
            subCategoryData?.name ?? item.itemName ?? 'Subcategory';

        // Count how many products from this subcategory are in cart
        final productState = ref.read(productProvider).value;
        final subCategoryProducts =
            productState?.allProducts
                .where(
                  (p) =>
                      (p.subCategoryId?.id?.trim() ?? '') ==
                      (item.id?.trim() ?? ''),
                )
                .toList() ??
            [];
        final subCategoryCartCount = subCategoryProducts
            .where((p) => (_cart[p.id] ?? 0) > 0)
            .fold<int>(0, (sum, p) => sum + (_cart[p.id] ?? 0));

        return _CategoryCard(
          categoryName: subCategoryName,
          imageUrl: imageUrl,
          isLoading: isLoading,
          cartCount: subCategoryCartCount,
          onTap: () => _openCategorySheet(
            context,
            categoryId: item.id ?? '',
            categoryName: subCategoryName,
            categoryImage: imageUrl,
          ),
        );
      },
    );
  }

  // ─── Category products bottom sheet ──────────────────────

  void _openCategorySheet(
    BuildContext context, {
    required String categoryId,
    required String categoryName,
    required String categoryImage,
  }) {
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.90,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => _CategoryProductsSheet(
          categoryId: categoryId,
          categoryName: categoryName,
          categoryImage: categoryImage,
          cart: Map.from(_cart),
          scrollController: scrollController,
          onAdd: (productId) {
            _addToCart(productId);
            cartNotifier.addItem(
              ref
                  .read(productProvider)
                  .value!
                  .allProducts
                  .firstWhere((p) => p.id == productId),
            );
          },
          onRemove: (productId) => _removeFromCart(productId),
          onViewDetail: (productId) => _openProductDetail(context, productId),
        ),
      ),
    ).whenComplete(() => cartNotifier.clearCart());
  }

  void _openProductDetail(BuildContext context, String productId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductDetailsBottomSheet(productId: productId),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CATEGORY CARD — column list mein horizontal card
// ════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.categoryName,
    required this.imageUrl,
    required this.cartCount,
    required this.onTap,
    this.isLoading = false,
  });

  final String categoryName;
  final String imageUrl;
  final int cartCount;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: cartCount > 0
                ? AppColors.button.withOpacity(0.5)
                : AppColors.grey200,
            width: cartCount > 0 ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isLoading || imageUrl.isEmpty
                  ? Container(
                      width: 60,
                      height: 60,
                      color: AppColors.grey100,
                      child: const Icon(
                        Icons.category_outlined,
                        size: 26,
                        color: AppColors.grey500,
                      ),
                    )
                  : CustomCachedImage(
                      imageUrl: imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 14),

            // Name + cart badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryName,
                    style: text14(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartCount > 0
                        ? '$cartCount item${cartCount > 1 ? "s" : ""} added'
                        : 'Tap to browse products',
                    style: text12(
                      color: cartCount > 0
                          ? AppColors.button
                          : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),

            // Cart badge + arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (cartCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$cartCount',
                      style: text11(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (cartCount > 0) const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.button.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.button,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  CATEGORY PRODUCTS SHEET — products with add/remove
// ════════════════════════════════════════════════════════════

class _CategoryProductsSheet extends ConsumerStatefulWidget {
  const _CategoryProductsSheet({
    required this.categoryId,
    required this.categoryName,
    required this.categoryImage,
    required this.cart,
    required this.scrollController,
    required this.onAdd,
    required this.onRemove,
    required this.onViewDetail,
  });

  final String categoryId;
  final String categoryName;
  final String categoryImage;
  final Map<String, int> cart;
  final ScrollController scrollController;
  final void Function(String productId) onAdd;
  final void Function(String productId) onRemove;
  final void Function(String productId) onViewDetail;

  @override
  ConsumerState<_CategoryProductsSheet> createState() =>
      _CategoryProductsSheetState();
}

class _CategoryProductsSheetState
    extends ConsumerState<_CategoryProductsSheet> {
  late Map<String, int> _localCart;

  @override
  void initState() {
    super.initState();
    _localCart = Map.from(widget.cart);
  }

  void _add(String productId) {
    setState(() => _localCart[productId] = (_localCart[productId] ?? 0) + 1);
    widget.onAdd(productId);
  }

  void _remove(String productId) {
    final current = _localCart[productId] ?? 0;
    setState(() {
      if (current <= 1) {
        _localCart.remove(productId);
      } else {
        _localCart[productId] = current - 1;
      }
    });
    widget.onRemove(productId);
  }

  int _sheetCartTotal() => _localCart.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                if (widget.categoryImage.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomCachedImage(
                      imageUrl: widget.categoryImage,
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoryName,
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Select products to add to cart',
                        style: text12(color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                // Cart count badge
                if (_sheetCartTotal() > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_sheetCartTotal()} in cart',
                      style: text11(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          const Divider(height: 20),

          // Products
          Expanded(
            child: productState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Something went wrong', style: text14())),
              data: (state) {
                final products = state.allProducts
                    .where(
                      (p) =>
                          (p.subCategoryId?.id?.trim() ?? '') ==
                          widget.categoryId.trim(),
                    )
                    .toList();

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 46,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No products found',
                          style: text15(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No products available in ${widget.categoryName}',
                          style: text12(color: AppColors.grey600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final product = products[i];
                    final qty = _localCart[product.id] ?? 0;
                    return _ProductCard(
                      product: product,
                      quantity: qty,
                      onAdd: () => _add(product.id ?? ''),
                      onIncrease: () => _add(product.id ?? ''),
                      onDecrease: () => _remove(product.id ?? ''),
                      onViewDetail: () => widget.onViewDetail(product.id ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // Sheet bottom — Done button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: AppButton(
                title: _sheetCartTotal() > 0
                    ? 'Done  •  ${_sheetCartTotal()} items added'
                    : 'Done',
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  PRODUCT CARD — Add / qty stepper
// ════════════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
    required this.onViewDetail,
  });

  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.thumbnail?.trim() ?? '';
    final isAdded = quantity > 0;

    return GestureDetector(
      onTap: onViewDetail,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAdded
                ? AppColors.button.withOpacity(0.5)
                : AppColors.grey200,
            width: isAdded ? 1.5 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: imageUrl.isNotEmpty
                    ? CustomCachedImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: AppColors.grey100,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.grey500,
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text12(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  if (product.price != null)
                    Text(
                      '₹${product.price}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 6),

                  // Add button OR qty stepper
                  if (!isAdded)
                    AppButton(
                      height: 30,
                      radius: 8,
                      textStyle: text12(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      title: 'Add',
                      onTap: onAdd,
                    )
                  else
                    _QuantityStepper(
                      quantity: quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  QUANTITY STEPPER
// ════════════════════════════════════════════════════════════

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.button.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove,
            color: Colors.redAccent,
            onTap: onDecrease,
          ),
          Expanded(
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: text13(
                fontWeight: FontWeight.bold,
                color: AppColors.button,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, color: AppColors.green, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 30,
        width: 30,
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  KIT SUMMARY BANNER
// ════════════════════════════════════════════════════════════

class _KitSummary extends StatelessWidget {
  const _KitSummary({
    required this.subCategoryCount,
    required this.cartItemCount,
  });

  final int subCategoryCount;
  final int cartItemCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.headerCard,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.category_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recommended Subcategories', style: text15()),
                const SizedBox(height: 2),
                Text(
                  '$subCategoryCount subcategories recommended',
                  style: text12(color: AppColors.grey600),
                ),
              ],
            ),
          ),
          if (cartItemCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.button,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$cartItemCount in cart',
                style: text12(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  BOTTOM BAR — cart summary + buy now
// ════════════════════════════════════════════════════════════

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.cartCount,
    required this.cartPrice,
    required this.onBuyNow,
  });

  final int cartCount;
  final double cartPrice;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: cartCount == 0
            ? AppOutlineButton(
                title: 'Add items from subcategories above',
                onTap: () {},
              )
            : Row(
                children: [
                  // Price summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$cartCount item${cartCount > 1 ? "s" : ""} selected',
                          style: text12(color: AppColors.grey600),
                        ),
                        Text(
                          '₹${cartPrice.toStringAsFixed(0)}',
                          style: text18(
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Buy now
                  Expanded(
                    child: AppButton(title: 'Proceed to Buy', onTap: onBuyNow),
                  ),
                ],
              ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  EMPTY STATE
// ════════════════════════════════════════════════════════════

class _EmptyKit extends StatelessWidget {
  const _EmptyKit();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 46,
              color: AppColors.grey500,
            ),
            const SizedBox(height: 12),
            Text('No subcategories recommended', style: text16()),
            const SizedBox(height: 4),
            Text(
              'Pandit ji has not added any samagri subcategories yet.',
              textAlign: TextAlign.center,
              style: text13(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
