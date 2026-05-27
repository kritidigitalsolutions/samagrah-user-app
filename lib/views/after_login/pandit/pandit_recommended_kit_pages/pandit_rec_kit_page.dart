import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

import '../../../../model/request/payment_req/payment_reqs_models.dart';
import '../../../../view_model/after_login_provider/checkout_providers/address.provider.dart';

class PanditRecKitPage extends ConsumerStatefulWidget {
  const PanditRecKitPage({super.key});

  @override
  ConsumerState<PanditRecKitPage> createState() => _PanditRecKitPageState();
}

class _PanditRecKitPageState extends ConsumerState<PanditRecKitPage> {
  List<CustomSamagriItem>? _kitItems;
  final Map<String, int> _quantities = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_kitItems != null) return;
    final args = ModalRoute.of(context)?.settings.arguments;
    final items = args is List<CustomSamagriItem>
        ? List<CustomSamagriItem>.from(args)
        : <CustomSamagriItem>[];
    _kitItems = items;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      _quantities[_itemKey(item, i)] = item.quantity ?? 1;
    }
  }

  double _calculateTotalPrice() {
    final kitItems = _kitItems ?? [];
    if (kitItems.isEmpty) return 0.0;

    final productState = ref.read(productProvider).value;
    final allProducts = productState?.allProducts ?? [];

    double total = 0.0;

    for (var i = 0; i < kitItems.length; i++) {
      final samagriItem = kitItems[i];
      final product = _findProduct(allProducts, samagriItem);
      final qty = _quantities[_itemKey(samagriItem, i)] ?? 1;

      if (product != null) {
        total += (product.price ?? 0) * qty;
      }
    }
    return total;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final kitItems = _kitItems ?? [];

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
              errorBuilder: (_, _, _) => Container(
                width: 70,
                height: 70,
                color: AppColors.grey500,
                child: const Icon(Icons.image),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: productState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('Something went wrong')),
          data: (state) {
            final allProducts = state.allProducts;
            final matchedItems = kitItems.asMap().entries.map((entry) {
              final item = entry.value;
              return _KitProductItem(
                index: entry.key,
                samagriItem: item,
                product: _findProduct(allProducts, item),
              );
            }).toList();

            return Column(
              children: [
                // ── Summary Banner ──
                _KitSummary(
                  itemCount: kitItems.length,
                  totalQuantity: _totalQuantity(kitItems),
                  totalPrice: _calculateTotalPrice(), // ← Added
                ),

                // ── Items List ──
                Expanded(
                  child: matchedItems.isEmpty
                      ? const _EmptyKit()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          itemCount: matchedItems.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = matchedItems[index];
                            final key = _itemKey(
                              entry.samagriItem,
                              entry.index,
                            );
                            final quantity = _quantities[key] ?? 1;
                            return _KitItemCard(
                              item: entry.samagriItem,
                              product: entry.product,
                              quantity: quantity,
                              onDecrease: () => _decreaseQuantity(key),
                              onIncrease: () => _increaseQuantity(key),
                              onRemove: () => _removeItem(entry.index, key),
                              onViewProduct: entry.product == null
                                  ? null
                                  : () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.productDetails,
                                      arguments: entry.product,
                                    ),
                            );
                          },
                        ),
                ),

                // ── Bottom Buttons (Buy Now + Add More Items) ──
                _BottomActions(
                  onBuyNow: () => _navigateToOrderSummary(context),
                  onAddMore: () => _openAddMoreSheet(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _navigateToOrderSummary(BuildContext context) {
    final kitItems = _kitItems ?? [];
    if (kitItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items in kit to proceed.')),
      );
      return;
    }

    final productState = ref.read(productProvider).value;
    final allProducts = productState?.allProducts ?? [];

    // Create customizedItems for booking
    final customizedItems = kitItems.map((item) {
      final qty = _quantities[_itemKey(item, kitItems.indexOf(item))] ?? 1;
      return VerifyItem(productId: item.id ?? '', quantity: qty);
    }).toList();

    // Calculate total price
    double totalPrice = 0.0;
    for (var i = 0; i < kitItems.length; i++) {
      final samagriItem = kitItems[i];
      final product = _findProduct(allProducts, samagriItem);
      final qty = _quantities[_itemKey(samagriItem, i)] ?? 1;
      if (product != null) {
        totalPrice += (product.price ?? 0) * qty;
      }
    }

    // Set providers
    ref.read(bookingItemProvider.notifier).state = customizedItems;
    ref.read(totalPriceProvider.notifier).state = totalPrice;

    // Navigate to Address Page
    Navigator.pushNamed(context, AppRoutes.addressPage);
  }

  void _openAddMoreSheet(BuildContext context) {
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.6,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return _AddMoreSheet(
              currentItems: List<CustomSamagriItem>.from(_kitItems ?? []),
              scrollController: scrollController,
              onAddProduct: (product) => _addProductToKit(product),
              onRemoveItem: (index, key) => _removeItem(index, key),
              onIncrease: (key) => _increaseQuantity(key),
              onDecrease: (key) => _decreaseQuantity(key),
              quantities: _quantities,
              itemKey: _itemKey,
            );
          },
        );
      },
    ).whenComplete(() => cartNotifier.clearCart());
  }

  // ─── Product Helpers ──────────────────────────────────────────────────────

  void _addProductToKit(Product product) {
    setState(() {
      final existingIndex =
          _kitItems?.indexWhere(
            (e) => e.id != null && e.id!.isNotEmpty && e.id == product.id,
          ) ??
          -1;

      if (existingIndex >= 0) {
        final key = _itemKey(_kitItems![existingIndex], existingIndex);
        _quantities[key] = (_quantities[key] ?? 1) + 1;
      } else {
        final newItem = CustomSamagriItem(
          id: product.id,
          itemName: product.title,
          size: '',
          quantity: 1,
          approvalStatus: '',
          reviewedAt: null,
          reviewedBy: '',
        );
        final newIndex = _kitItems?.length ?? 0;
        _kitItems?.add(newItem);
        _quantities[_itemKey(newItem, newIndex)] = 1;
      }
    });
  }

  Product? _findProduct(List<Product> products, CustomSamagriItem item) {
    final id = item.id?.trim() ?? '';
    if (id.isEmpty) return null;
    try {
      return products.firstWhere((p) => (p.id?.trim() ?? '') == id);
    } catch (_) {
      return null;
    }
  }

  // UserDraftProduct _toUserDraftProduct(Product product) => UserDraftProduct(
  //   id: product.id,
  //   title: product.title,
  //   pricing: Pricing(
  //     price: product.price,
  //     mrp: product.oldPrice,
  //     currency: 'INR',
  //     basePrice: null,
  //     gstAmount: null,
  //     gstPercent: null,
  //     priceIncludesGst: null,
  //   ),
  //   media: Media(
  //     image: product.thumbnail != null
  //         ? [product.thumbnail.toString()]
  //         : (product.images).map((e) => e.toString()).toList(),
  //   ),
  //   slug: '',
  //   category: null,
  // );

  // ─── Quantity & State Helpers ─────────────────────────────────────────────

  String _itemKey(CustomSamagriItem item, int index) =>
      item.id?.isNotEmpty == true ? item.id! : 'kit_item_$index';

  int _totalQuantity(List<CustomSamagriItem> items) {
    var total = 0;
    for (var i = 0; i < items.length; i++) {
      total += _quantities[_itemKey(items[i], i)] ?? 1;
    }
    return total;
  }

  void _decreaseQuantity(String key) {
    final current = _quantities[key] ?? 1;
    if (current <= 1) return;
    setState(() => _quantities[key] = current - 1);
  }

  void _increaseQuantity(String key) {
    setState(() => _quantities[key] = (_quantities[key] ?? 1) + 1);
  }

  void _removeItem(int index, String key) {
    setState(() {
      _kitItems?.removeAt(index);
      _quantities.remove(key);
    });
  }
}

// ════════════════════════════════════════════════════════════
//  BOTTOM ACTIONS — Buy Now + Add More Items
// ════════════════════════════════════════════════════════════

class _BottomActions extends StatelessWidget {
  const _BottomActions({required this.onBuyNow, required this.onAddMore});

  final VoidCallback onBuyNow;
  final VoidCallback onAddMore;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(title: 'Buy Now', onTap: onBuyNow),
          const SizedBox(height: 10),
          AppOutlineButton(title: 'Add More Items ➕', onTap: onAddMore),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  ADD MORE ITEMS BOTTOM SHEET
// ════════════════════════════════════════════════════════════

class _AddMoreSheet extends ConsumerStatefulWidget {
  final List<CustomSamagriItem> currentItems;
  final ScrollController scrollController;
  final void Function(Product product) onAddProduct;
  final void Function(int index, String key) onRemoveItem;
  final void Function(String key) onIncrease;
  final void Function(String key) onDecrease;
  final Map<String, int> quantities;
  final String Function(CustomSamagriItem item, int index) itemKey;

  const _AddMoreSheet({
    required this.currentItems,
    required this.scrollController,
    required this.onAddProduct,
    required this.onRemoveItem,
    required this.onIncrease,
    required this.onDecrease,
    required this.quantities,
    required this.itemKey,
  });

  @override
  ConsumerState<_AddMoreSheet> createState() => _AddMoreSheetState();
}

class _AddMoreSheetState extends ConsumerState<_AddMoreSheet> {
  // Local copy so sheet UI reflects add/remove without closing
  late List<CustomSamagriItem> _localItems;
  late Map<String, int> _localQty;

  @override
  void initState() {
    super.initState();
    _localItems = List<CustomSamagriItem>.from(widget.currentItems);
    _localQty = Map<String, int>.from(widget.quantities);
  }

  String _key(CustomSamagriItem item, int index) =>
      item.id?.isNotEmpty == true ? item.id! : 'kit_item_$index';

  void _localIncrease(String key) =>
      setState(() => _localQty[key] = (_localQty[key] ?? 1) + 1);

  void _localDecrease(String key) {
    final current = _localQty[key] ?? 1;
    if (current <= 1) return;
    setState(() => _localQty[key] = current - 1);
  }

  void _localRemove(int index, String key) {
    setState(() {
      _localItems.removeAt(index);
      _localQty.remove(key);
    });
    widget.onRemoveItem(index, key);
  }

  void _localAdd(Product product) {
    final existingIndex = _localItems.indexWhere(
      (e) => e.id != null && e.id == product.id,
    );
    if (existingIndex >= 0) {
      final key = _key(_localItems[existingIndex], existingIndex);
      setState(() => _localQty[key] = (_localQty[key] ?? 1) + 1);
    } else {
      final newItem = CustomSamagriItem(
        id: product.id,
        itemName: product.title,
        size: '',
        quantity: 1,
        approvalStatus: '',
        reviewedAt: null,
        reviewedBy: '',
      );
      setState(() {
        _localItems.add(newItem);
        _localQty[_key(newItem, _localItems.length - 1)] = 1;
      });
    }
    widget.onAddProduct(product);
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final cart = ref.watch(customizeKitCartProvider);
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);
    final selectedCategory = productState.value?.selectedKitCategory ?? 'All';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Handle ──
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize Kit',
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add, remove or adjust items',
                        style: text12(color: AppColors.grey600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // ── Info Banner ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
                    'You can add, remove or change quantity of items',
                    style: text12(color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),

          // ── Section label ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Text('Kit Items', style: text14(fontWeight: FontWeight.bold)),
                const SizedBox(width: 4),
                Text(
                  '(${_localItems.length})',
                  style: text12(color: AppColors.grey600),
                ),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                // ── Current Items (editable) ──
                ..._localItems.asMap().entries.map((e) {
                  final item = e.value;
                  final index = e.key;
                  final key = _key(item, index);
                  final qty = _localQty[key] ?? 1;
                  return _EditableItemRow(
                    item: item,
                    quantity: qty,
                    onIncrease: () {
                      _localIncrease(key);
                      widget.onIncrease(key);
                    },
                    onDecrease: () {
                      _localDecrease(key);
                      widget.onDecrease(key);
                    },
                    onRemove: () => _localRemove(index, key),
                  );
                }),

                // ── Divider ──
                const Divider(
                  height: 24,
                  thickness: 6,
                  color: Color(0xFFF5F5F5),
                ),

                // ── Add More Label ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Text(
                    'Add More Items',
                    style: text14(fontWeight: FontWeight.bold),
                  ),
                ),

                // ── Category Filter Chips ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _CategoryChip(
                        label: 'All',
                        type: 'All',
                        imgPath: 'assets/home/select-all.png',
                        selected: selectedCategory == 'All',
                      ),
                      _CategoryChip(
                        label: 'Agri Batti',
                        type: 'agarbatti',
                        imgPath: 'assets/home/incense.png',
                        selected: selectedCategory == 'agarbatti',
                      ),
                      _CategoryChip(
                        label: 'Fruits',
                        type: 'fruits',
                        imgPath: 'assets/home/fruit.png',
                        selected: selectedCategory == 'fruits',
                      ),
                      _CategoryChip(
                        label: 'Flowers',
                        type: 'flowers',
                        imgPath: 'assets/home/flower.png',
                        selected: selectedCategory == 'flowers',
                      ),
                      _CategoryChip(
                        label: 'Mala',
                        type: 'garland',
                        imgPath: 'assets/home/mala.png',
                        selected: selectedCategory == 'garland',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Product Grid ──
                productState.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (state) {
                    final products = state.categoryKitProducts;
                    if (products.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No products in this category',
                            style: text13(color: AppColors.grey600),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.70,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final product = products[index];
                        final isInKit = _localItems.any(
                          (i) => i.id != null && i.id == product.id,
                        );
                        final cartQty = cart[product.id] ?? 0;

                        return _AddProductCard(
                          product: product,
                          isInKit: isInKit,
                          cartQty: cartQty,
                          onAdd: () {
                            cartNotifier.addItem(product);
                            _localAdd(product);
                          },
                          onViewDetail: () =>
                              _openProductDetail(context, product.id ?? ''),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
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
//  CATEGORY CHIP
// ════════════════════════════════════════════════════════════

class _CategoryChip extends ConsumerWidget {
  const _CategoryChip({
    required this.label,
    required this.type,
    required this.imgPath,
    required this.selected,
  });

  final String label;
  final String type;
  final String imgPath;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => ref
            .read(productProvider.notifier)
            .filterByCustKitCategory(type.toLowerCase()),
        child: Chip(
          avatar: Image.asset(imgPath, width: 16, height: 16),
          label: Text(
            label,
            style: text12(color: selected ? AppColors.button : AppColors.black),
          ),
          backgroundColor: selected
              ? AppColors.button.withAlpha(30)
              : AppColors.white,
          side: BorderSide(
            color: selected ? AppColors.button : AppColors.grey200,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  EDITABLE ITEM ROW (inside sheet — current kit items)
// ════════════════════════════════════════════════════════════

class _EditableItemRow extends StatelessWidget {
  const _EditableItemRow({
    required this.item,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CustomSamagriItem item;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Placeholder image (no product matched yet in sheet)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 50,
              width: 50,
              color: AppColors.grey100,
              child: const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.grey500,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName?.trim().isNotEmpty == true
                      ? item.itemName!.trim()
                      : 'Samagri Item',
                  style: text14(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.size?.trim().isNotEmpty == true)
                  Text(
                    item.size!.trim(),
                    style: text11(color: AppColors.grey500),
                  ),
              ],
            ),
          ),

          // Qty stepper + delete
          Row(
            children: [
              _qtyBtn(Icons.remove, Colors.redAccent, onDecrease),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$quantity',
                  style: text15(fontWeight: FontWeight.bold),
                ),
              ),
              _qtyBtn(Icons.add, AppColors.green, onIncrease),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      );
}

// ════════════════════════════════════════════════════════════
//  ADD PRODUCT CARD (grid inside sheet)
// ════════════════════════════════════════════════════════════

class _AddProductCard extends StatelessWidget {
  const _AddProductCard({
    required this.product,
    required this.isInKit,
    required this.cartQty,
    required this.onAdd,
    required this.onViewDetail,
  });

  final Product product;
  final bool isInKit;
  final int cartQty;
  final VoidCallback onAdd;
  final VoidCallback onViewDetail;

  @override
  Widget build(BuildContext context) {
    final isAdded = isInKit || cartQty > 0;

    return GestureDetector(
      onTap: onViewDetail,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
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
                child: CustomCachedImage(
                  imageUrl: product.thumbnail ?? '',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(7),
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
                  Text(
                    '₹${product.price}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Add / Added button
                  if (!isAdded)
                    AppButton(
                      height: 28,
                      radius: 8,
                      textStyle: text12(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      title: 'Add',
                      onTap: onAdd,
                    )
                  else
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.button.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.button),
                      ),
                      child: Center(
                        child: Text(
                          isInKit ? 'In Kit ✓' : '$cartQty Added',
                          style: text12(
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
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  KIT ITEM CARD (main page list)
// ════════════════════════════════════════════════════════════

class _KitProductItem {
  const _KitProductItem({
    required this.index,
    required this.samagriItem,
    required this.product,
  });

  final int index;
  final CustomSamagriItem samagriItem;
  final Product? product;
}

class _KitSummary extends StatelessWidget {
  const _KitSummary({
    required this.itemCount,
    required this.totalQuantity,
    required this.totalPrice, // ← New parameter
  });

  final int itemCount;
  final int totalQuantity;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.headerCard,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side - Icon + Info
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_outlined),
          ),
          const SizedBox(width: 12),

          // Middle - Items Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Items Included', style: text18()),
                const SizedBox(height: 2),
                Text(
                  '$itemCount items • $totalQuantity total quantity',
                  style: text13(color: AppColors.grey600),
                ),
              ],
            ),
          ),

          // Right Side - Total Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total', style: text13(color: AppColors.grey600)),
              const SizedBox(height: 2),
              Text(
                '₹${totalPrice.toStringAsFixed(0)}',
                style: text20(
                  color: AppColors.button,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KitItemCard extends StatelessWidget {
  const _KitItemCard({
    required this.item,
    required this.product,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
    required this.onViewProduct,
  });

  final CustomSamagriItem item;
  final Product? product;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;
  final VoidCallback? onViewProduct;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(product);
    final itemSize = item.size?.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 4),
            color: Color(0x14000000),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductThumb(imageUrl: imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _resolveTitle(),
                        style: text14(fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: onRemove,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.grey600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  itemSize != null && itemSize.isNotEmpty
                      ? itemSize
                      : 'Standard size',
                  style: text12(color: AppColors.grey600),
                ),
                if (product?.price != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '₹${product!.price}',
                    style: text13(
                      color: AppColors.button,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _QuantityStepper(
                      quantity: quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onViewProduct,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.button,
                        disabledForegroundColor: AppColors.grey400,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 34),
                      ),
                      child: Text(
                        onViewProduct != null ? 'View' : 'Not listed',
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

  String _resolveTitle() {
    final name = item.itemName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final productTitle = product?.title?.trim() ?? '';
    if (productTitle.isNotEmpty) return productTitle;
    return 'Samagri Item';
  }

  String? _resolveImageUrl(Product? product) {
    if (product == null) return null;
    final thumbnail = product.thumbnail?.trim() ?? '';
    if (thumbnail.isNotEmpty) return thumbnail;
    final images = product.images;
    for (final img in images) {
      final url = img.trim();
      if (url.isNotEmpty) return url;
    }
    return null;
  }
}

// ════════════════════════════════════════════════════════════
//  PRODUCT THUMBNAIL
// ════════════════════════════════════════════════════════════

class _ProductThumb extends StatelessWidget {
  const _ProductThumb({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final placeholder = _placeholder();
    if (imageUrl == null || imageUrl!.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CustomCachedImage(
        imageUrl: imageUrl!,
        height: 72,
        width: 72,
        fit: BoxFit.cover,
        errorWidget: placeholder,
      ),
    );
  }

  Widget _placeholder() => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
      height: 72,
      width: 72,
      color: AppColors.grey100,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.grey500,
      ),
    ),
  );
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
      height: 34,
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrease),
          SizedBox(
            width: 38,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: text14(fontWeight: FontWeight.w700),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 34,
        width: 34,
        child: Icon(icon, size: 18, color: AppColors.button),
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
              Icons.inventory_2_outlined,
              size: 46,
              color: AppColors.grey500,
            ),
            const SizedBox(height: 12),
            Text('No items in this kit', style: text16()),
            const SizedBox(height: 4),
            Text(
              'Add items to customize your samagri kit.',
              textAlign: TextAlign.center,
              style: text13(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }
}
