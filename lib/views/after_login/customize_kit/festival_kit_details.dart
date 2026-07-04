import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/category_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/after_login/customize_kit/kit_order_summary_page.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

class FestivalKitDetails extends ConsumerStatefulWidget {
  const FestivalKitDetails({super.key});

  @override
  ConsumerState<FestivalKitDetails> createState() => _FestivalKitDetailsState();
}

class _FestivalKitDetailsState extends ConsumerState<FestivalKitDetails> {
  DefaultKitData? _lastKit;
  bool _showAllItems = false;
  List<Item> _originalItems = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final kit = ModalRoute.of(context)!.settings.arguments as DefaultKitData;
    if (_lastKit?.id != kit.id) {
      _lastKit = kit;
      _originalItems = kit.items
          .map((e) => Item(product: e.product, quantity: e.quantity, id: e.id))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final kit = ModalRoute.of(context)!.settings.arguments as DefaultKitData;
    final isLoading = ref.watch(defaultKitLoaderPro);

    final bool isSpecialKit = (kit.kitType ?? '').toLowerCase() == 'special';
    final bool isPanditApproved = kit.isPanditApproved == true;
    final bool isMostUsed = kit.isMostUserUse == true;
    final bool isPopular = kit.isMostPopularKit == true;

    final displayItems = _showAllItems
        ? _originalItems
        : _originalItems.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.white,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CustomCachedImage(
                    imageUrl: kit.image ?? '',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    left: 16,
                    child: Wrap(
                      spacing: 6,
                      children: [
                        if (isPopular)
                          _overlayBadge(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Most Popular',
                            color: Colors.orange.shade600,
                          ),
                        if (isSpecialKit)
                          _overlayBadge(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Special Kit',
                            color: Colors.purple.shade600,
                          ),
                        if (isPanditApproved)
                          _overlayBadge(
                            icon: Icons.verified_rounded,
                            label: 'Pandit Approved',
                            color: Colors.green.shade600,
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kit.name ?? '',
                          style: text20(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _statBadge(
                              Icons.check_circle_outline,
                              'Complete Kit',
                            ),
                            const SizedBox(width: 8),
                            _statBadge(
                              Icons.inventory_2_outlined,
                              '${kit.items.length} Items',
                            ),
                            const SizedBox(width: 8),
                            _statBadge(
                              Icons.auto_awesome_outlined,
                              'Ready for Pooja',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Special Kit Notice Banner ──
                if (isSpecialKit)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.purple.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This is a Special Kit',
                                style: text13(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'This kit has been specially curated by our pandits and cannot be customized. You can purchase it as-is.',
                                style: text12(color: Colors.purple.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Price ──
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '₹${kit.kitPrice ?? 0}',
                            style: text24(
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if ((kit.totalPrice ?? 0) > (kit.kitPrice ?? 0))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '₹${kit.totalPrice}',
                                style: text14(color: AppColors.grey500)
                                    .copyWith(
                                      decoration: TextDecoration.lineThrough,
                                    ),
                              ),
                            ),
                          const Spacer(),
                          if ((kit.savings ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Save ₹${kit.savings}',
                                style: text12(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          if (isPanditApproved)
                            _trustRow(
                              icon: Icons.verified,
                              label: 'Pandit Approved',
                              color: Colors.green.shade600,
                            ),
                          if (isMostUsed)
                            _trustRow(
                              icon: Icons.people_outline,
                              label: '98% users chose this',
                              color: AppColors.grey600,
                            ),
                          if (isPopular)
                            _trustRow(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Most Popular',
                              color: Colors.orange.shade600,
                            ),
                          if (kit.category != null && kit.category!.isNotEmpty)
                            _trustRow(
                              icon: Icons.category_outlined,
                              label: kit.category!,
                              color: AppColors.button,
                            ),
                          if (kit.festivalType != null &&
                              kit.festivalType!.isNotEmpty)
                            _trustRow(
                              icon: Icons.celebration_outlined,
                              label: kit.festivalType!,
                              color: Colors.deepOrange.shade400,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Items Included ──
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Row(
                    children: [
                      Text(
                        'Items Included',
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${_originalItems.length})',
                        style: text14(color: AppColors.grey600),
                      ),
                      const Spacer(),
                      if (kit.kitType != null && kit.kitType!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isSpecialKit
                                ? Colors.purple.shade50
                                : AppColors.button.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSpecialKit
                                  ? Colors.purple.shade200
                                  : AppColors.button.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            kit.kitType!,
                            style: text10(
                              color: isSpecialKit
                                  ? Colors.purple.shade700
                                  : AppColors.button,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                Container(
                  color: AppColors.white,
                  child: Column(
                    children: [
                      ...displayItems.map(
                        (item) =>
                            _buildReadOnlyItemRow(context, item, isSpecialKit),
                      ),
                      if (_originalItems.length > 5)
                        InkWell(
                          onTap: () =>
                              setState(() => _showAllItems = !_showAllItems),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _showAllItems
                                      ? 'Show Less'
                                      : 'View all ${_originalItems.length} items',
                                  style: text13(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(
                                  _showAllItems
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: AppColors.button,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Trust Badges ──
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _trustBadge(Icons.security, 'Secure\nPackaging'),
                      _divider(),
                      _trustBadge(
                        Icons.local_shipping_outlined,
                        'On-time\nDelivery',
                      ),
                      _divider(),
                      _trustBadge(
                        Icons.workspace_premium_outlined,
                        'Premium\nQuality',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Bottom Buttons ──
      bottomNavigationBar: SafeArea(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                title: isLoading ? "Creating Kit..." : "Buy Now",
                onTap: isLoading
                    ? null
                    : () => Navigator.pushNamed(
                        context,
                        AppRoutes.kitOrderSummary,
                        arguments: KitOrderArgs(kit: kit, isCustomized: false),
                      ),
              ),
              const SizedBox(height: 10),
              if (!isSpecialKit)
                AppOutlineButton(
                  title: 'Customize This Kit ✏️',
                  onTap: () => _openCustomizeSheet(context, ref, kit),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 15,
                        color: Colors.purple.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Special kits cannot be customized',
                        style: text12(color: Colors.purple.shade700),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyItemRow(
    BuildContext context,
    Item item,
    bool isSpecialKit,
  ) {
    final product = item.product;
    final imageUrl = product?.media?.image.firstOrNull ?? '';
    final categoryName = product?.category?.name ?? '';
    final categorySlug = categoryName.toLowerCase();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomCachedImage(
                  imageUrl: imageUrl,
                  height: 56,
                  width: 56,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalizeWords(product?.title ?? ''),
                      style: text14(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (categoryName.isNotEmpty)
                      Text(
                        categoryName,
                        style: text11(color: AppColors.grey600),
                      ),
                    const SizedBox(height: 4),
                    if (!isSpecialKit)
                      GestureDetector(
                        onTap: () => _showCategoryProductsSheet(
                          context,
                          categorySlug,
                          categoryName.isNotEmpty
                              ? categoryName
                              : product?.title ?? '',
                        ),
                        child: Text(
                          'View Products',
                          style: text11(
                            color: AppColors.button,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Text(
                        'Fixed item',
                        style: text11(color: Colors.purple.shade400),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '× ${item.quantity ?? 1}',
                      style: text12(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${product?.pricing?.price ?? ''}',
                    style: text14(
                      fontWeight: FontWeight.w600,
                      color: AppColors.button,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: Color(0xFFF0F0F0),
        ),
      ],
    );
  }

  void _showCategoryProductsSheet(
    BuildContext context,
    String categorySlug,
    String categoryLabel,
  ) {
    ref
        .read(productProvider.notifier)
        .filterByCustKitCategory(categorySlug.toLowerCase());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) {
            return _CategoryProductsSheet(
              categoryLabel: categoryLabel,
              categorySlug: categorySlug,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────

  Widget _statBadge(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: text11(color: Colors.white)),
      ],
    ),
  );

  Widget _overlayBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white),
        const SizedBox(width: 4),
        Text(
          label,
          style: text11(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _trustRow({
    required IconData icon,
    required String label,
    required Color color,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 4),
      Text(label, style: text12(color: color)),
    ],
  );

  Widget _trustBadge(IconData icon, String label) => Column(
    children: [
      Icon(icon, color: AppColors.button, size: 22),
      const SizedBox(height: 4),
      Text(
        label,
        textAlign: TextAlign.center,
        style: text11(color: AppColors.grey700),
      ),
    ],
  );

  Widget _divider() =>
      Container(height: 36, width: 1, color: AppColors.grey200);

  void _openCustomizeSheet(
    BuildContext context,
    WidgetRef ref,
    DefaultKitData kit,
  ) {
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
            return _CustomizeSheet(
              kit: kit,
              originalItems: _originalItems,
              scrollController: scrollController,
              onProceed: (List<Item> finalItems, num finalTotal) {
                Navigator.pop(sheetContext);

                final customizedKit = DefaultKitData(
                  id: kit.id,
                  name: kit.name,
                  image: kit.image,
                  description: kit.description,
                  kitPrice: finalTotal,
                  totalPrice: kit.totalPrice,
                  savings: kit.totalPrice != null
                      ? (kit.totalPrice! - finalTotal)
                      : kit.savings,
                  status: kit.status,
                  items: finalItems,
                  festivalType: kit.festivalType ?? '',
                  kitType: kit.kitType ?? '',
                  category: kit.category ?? '',
                  isMostPopularKit: kit.isMostPopularKit,
                  isMostUserUse: kit.isMostUserUse,
                  isPanditApproved: kit.isPanditApproved,
                );

                Navigator.pushNamed(
                  context,
                  AppRoutes.kitOrderSummary,
                  arguments: KitOrderArgs(
                    kit: customizedKit,
                    isCustomized: true,
                  ),
                );
              },
            );
          },
        );
      },
    ).whenComplete(() => cartNotifier.clearCart());
  }
}

// ════════════════════════════════════════════════════════════
//  CATEGORY PRODUCTS BOTTOM SHEET  (dynamic categories)
// ════════════════════════════════════════════════════════════
class _CategoryProductsSheet extends ConsumerWidget {
  final String categoryLabel;
  final String categorySlug;
  final ScrollController scrollController;

  const _CategoryProductsSheet({
    required this.categoryLabel,
    required this.categorySlug,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productState = ref.watch(productProvider);
    final categoryAsync = ref.watch(categoryProvider); // ← dynamic
    final selectedCategory = productState.value?.selectedKitCategory ?? 'All';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        categoryLabel.isNotEmpty ? categoryLabel : 'Products',
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Similar items you can choose from',
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

          // ── Dynamic category chips ────────────────────────────────
          categoryAsync.when(
            loading: () => SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 4,
                itemBuilder: (_, _) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 80,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.grey200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _categoryChip(
                    context: context,
                    ref: ref,
                    label: 'All',
                    categoryId: 'All',
                    imageAsset: 'assets/home/select-all.png',
                    selected: selectedCategory == 'All',
                  ),
                  ...categories.map(
                    (cat) => _categoryChip(
                      context: context,
                      ref: ref,
                      label: cat.name ?? '',
                      categoryId: (cat.name ?? '').toLowerCase(),
                      networkImage: cat.image,
                      selected:
                          selectedCategory == (cat.name ?? '').toLowerCase(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: productState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load products',
                  style: text14(color: AppColors.grey600),
                ),
              ),
              data: (state) {
                final products = state.categoryKitProducts;

                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: AppColors.grey600,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No products in this category',
                          style: text14(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProductDetailsBottomSheet(productId: product.id ?? ''),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: text12(
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                      if ((product.discountPercent ?? 0) > 0) ...[
                        const Spacer(),
                        Text(
                          '${product.discountPercent}%',
                          style: text10(color: AppColors.grey500),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 26,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.button.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.button.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'View',
                        style: text11(
                          color: AppColors.button,
                          fontWeight: FontWeight.w600,
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

  Widget _categoryChip({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String categoryId,
    String? imageAsset,
    String? networkImage,
    required bool selected,
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
        onTap: () => ref
            .read(productProvider.notifier)
            .filterByCustKitCategory(categoryId.toLowerCase()),
        child: Chip(
          avatar: avatar,
          label: Text(
            capitalizeWords(label),
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
//  CUSTOMIZE SHEET
// ════════════════════════════════════════════════════════════
class _CustomizeSheet extends ConsumerStatefulWidget {
  final DefaultKitData kit;
  final List<Item> originalItems;
  final ScrollController scrollController;
  final void Function(List<Item> finalItems, num finalTotal) onProceed;

  const _CustomizeSheet({
    required this.kit,
    required this.originalItems,
    required this.scrollController,
    required this.onProceed,
  });

  @override
  ConsumerState<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends ConsumerState<_CustomizeSheet> {
  late List<Item> _localItems;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _localItems = widget.originalItems
        .map((e) => Item(product: e.product, quantity: e.quantity, id: e.id))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  num get _localTotal => _localItems.fold(0, (sum, item) {
    final price = item.product?.pricing?.price ?? 0;
    return sum + (price * (item.quantity ?? 1));
  });

  void _updateQuantity(int index, int newQty) {
    if (newQty < 1) return;
    setState(
      () => _localItems[index] = Item(
        product: _localItems[index].product,
        quantity: newQty,
        id: _localItems[index].id,
      ),
    );
  }

  void _deleteItem(int index) {
    final productId = _localItems[index].product?.id;
    if (productId != null && productId.isNotEmpty) {
      ref.read(customizeKitCartProvider.notifier).removeProduct(productId);
    }
    setState(() => _localItems.removeAt(index));
  }

  void _addProduct(Product product) {
    final dp = _toDefaultProduct(product);
    final idx = _localItems.indexWhere((i) => i.product?.id == dp.id);
    setState(() {
      if (idx != -1) {
        _localItems[idx] = Item(
          product: _localItems[idx].product,
          quantity: (_localItems[idx].quantity ?? 1) + 1,
          id: _localItems[idx].id,
        );
      } else {
        _localItems.add(Item(product: dp, quantity: 1, id: ''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productProvider);
    final categoryAsync = ref.watch(categoryProvider); // ← dynamic
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
          // ── Handle ───────────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customize ${widget.kit.name ?? "Kit"}',
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Modify items as per your need',
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

          // ── Info Banner ───────────────────────────────────────────
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

          // ── Included items label ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: [
                Text(
                  'Included Items',
                  style: text14(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Text('(You can edit)', style: text12(color: AppColors.grey600)),
                const Spacer(),
                // live item count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.button.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_localItems.length} items',
                    style: text11(
                      color: AppColors.button,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Scrollable Body ───────────────────────────────────────
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: EdgeInsets.zero,
              children: [
                // Editable kit items
                ..._localItems.asMap().entries.map(
                  (e) => _buildEditableRow(e.value, e.key),
                ),

                const Divider(
                  height: 24,
                  thickness: 6,
                  color: Color(0xFFF5F5F5),
                ),

                // Add More header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Text(
                    'Add More Items',
                    style: text14(fontWeight: FontWeight.bold),
                  ),
                ),

                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: text14(color: AppColors.grey800),
                      decoration: InputDecoration(
                        hintText: 'Search items to add...',
                        hintStyle: text13(color: AppColors.grey600),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Dynamic category chips ──────────────────────────
                categoryAsync.when(
                  loading: () => SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 4,
                      itemBuilder: (_, _) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 80,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.grey200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (categories) => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _dynamicChip(
                          ref: ref,
                          label: 'All',
                          categoryId: 'All',
                          imageAsset: 'assets/home/select-all.png',
                          selected: selectedCategory == 'All',
                        ),
                        ...categories.map(
                          (cat) => _dynamicChip(
                            ref: ref,
                            label: cat.name ?? '',
                            categoryId: (cat.name ?? '').toLowerCase(),
                            networkImage: cat.image,
                            selected:
                                selectedCategory ==
                                (cat.name ?? '').toLowerCase(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Product grid ────────────────────────────────────
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
                    if (products.isEmpty) return const SizedBox.shrink();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: products.length,
                      itemBuilder: (_, index) {
                        final p = products[index];
                        final isInLocal = _localItems.any(
                          (i) => i.product?.id == p.id,
                        );
                        final cartQty = cart[p.id] ?? 0;
                        return _buildProductCard(
                          p,
                          isInLocal,
                          cartQty,
                          cartNotifier,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // ── Sticky Checkout Bar ───────────────────────────────────
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total', style: text12(color: AppColors.grey600)),
                      Text(
                        '₹$_localTotal',
                        style: text18(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '(${_localItems.length} items)',
                        style: text11(color: AppColors.grey600),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      title: 'Proceed to Checkout →',
                      onTap: () => widget.onProceed(_localItems, _localTotal),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Editable kit item row ─────────────────────────────────────────────────
  Widget _buildEditableRow(Item item, int index) {
    final product = item.product;
    final qty = item.quantity ?? 1;
    final categoryName = product?.category?.name ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CustomCachedImage(
              imageUrl: product?.media?.image.firstOrNull ?? '',
              height: 50,
              width: 50,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product?.title ?? '',
                  style: text14(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (categoryName.isNotEmpty)
                  Text(categoryName, style: text11(color: AppColors.grey500)),
                const SizedBox(height: 2),
                Text(
                  '₹${product?.pricing?.price ?? ''}',
                  style: text13(
                    fontWeight: FontWeight.w600,
                    color: AppColors.button,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(
                Icons.remove,
                Colors.redAccent,
                () => _updateQuantity(index, qty - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('$qty', style: text15(fontWeight: FontWeight.bold)),
              ),
              _qtyBtn(
                Icons.add,
                AppColors.green,
                () => _updateQuantity(index, qty + 1),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _deleteItem(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Improved product card ─────────────────────────────────────────────────
  Widget _buildProductCard(
    Product product,
    bool isInLocalKit,
    int cartQty,
    CustomizeKitCartNotifier cartNotifier,
  ) {
    final isAdded = isInLocalKit || cartQty > 0;
    final hasDiscount = (product.discountPercent ?? 0) > 0;
    final inStock = product.inStock == true;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: isAdded
            ? Border.all(color: AppColors.button.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image ───────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: CustomCachedImage(
                    imageUrl: product.thumbnail ?? '',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Discount badge
                if (hasDiscount)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${product.discountPercent}% off',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                // "In kit" tick overlay
                if (isAdded)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.button,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(7, 6, 7, 7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeWords(product.title ?? ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text11(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),

                // Price row
                Row(
                  children: [
                    Text(
                      '₹${product.price}',
                      style: text12(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if ((product.oldPrice ?? 0) > (product.price ?? 0)) ...[
                      const SizedBox(width: 3),
                      Text(
                        '₹${product.oldPrice}',
                        style: text8(
                          color: AppColors.grey500,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),

                // Add / Added button
                if (!inStock)
                  Container(
                    height: 28,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      'Out of Stock',
                      style: text11(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isAdded)
                  Container(
                    height: 28,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.button.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.button),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 12, color: AppColors.button),
                        const SizedBox(width: 4),
                        Text(
                          isInLocalKit ? 'In Kit' : '$cartQty Added',
                          style: text11(
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      cartNotifier.addItem(product);
                      _addProduct(product);
                    },
                    child: Container(
                      height: 28,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Add',
                            style: text11(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
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

  // ── Dynamic chip ────────────────────────────────────────────────────────────
  Widget _dynamicChip({
    required WidgetRef ref,
    required String label,
    required String categoryId,
    String? imageAsset,
    String? networkImage,
    required bool selected,
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
        onTap: () => ref
            .read(productProvider.notifier)
            .filterByCustKitCategory(categoryId.toLowerCase()),
        child: Chip(
          avatar: avatar,
          label: Text(
            capitalizeWords(label),
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

  Widget _qtyBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      );

  UserDraftProduct _toDefaultProduct(Product product) => UserDraftProduct(
    id: product.id,
    title: product.title,
    pricing: Pricing(
      price: product.price,
      mrp: product.oldPrice,
      currency: 'INR',
      basePrice: null,
      gstAmount: null,
      gstPercent: null,
      priceIncludesGst: null,
    ),
    media: Media(
      image: product.thumbnail != null
          ? [product.thumbnail.toString()]
          : product.images.map((e) => e.toString()).toList(),
    ),
    slug: '',
    category: null,
  );
}
