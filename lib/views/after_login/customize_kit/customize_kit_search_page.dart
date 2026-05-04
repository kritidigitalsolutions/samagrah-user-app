import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class CustomizePoojaKitScreen extends ConsumerStatefulWidget {
  const CustomizePoojaKitScreen({super.key});

  @override
  ConsumerState<CustomizePoojaKitScreen> createState() =>
      _CustomizePoojaKitScreenState();
}

class _CustomizePoojaKitScreenState
    extends ConsumerState<CustomizePoojaKitScreen>
    with SingleTickerProviderStateMixin {
  final nameKitCtr = TextEditingController();

  @override
  void dispose() {
    // _tabController.dispose();
    nameKitCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDraftKit = ref.watch(userDraftKits);
    final defaultKits = ref.watch(userDraftKits);

    return SafeArea(
      child: GestureDetector(
        onTap: () =>
            FocusScope.of(context).unfocus(), // ← unfocus on tap outside
        behavior: HitTestBehavior.opaque,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background,
                AppColors.background.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Column(
            children: [
              // ✅ Top bar - keeping it the same
              Container(
                color: AppColors.headerCard,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 1),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customize\nYour Pooja Kit',
                            style: text18(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/icon/plate.png',
                      width: 70,
                      height: 70,
                      errorBuilder: (context, exception, stackTrace) {
                        return Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(color: AppColors.grey500),
                          child: Center(child: Icon(Icons.image)),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ✅ Premium body design
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ✅ Floating premium card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            // ✅ Main content
                            Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                children: [
                                  // ✅ Premium icon with animation-ready design
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.orange.shade300,
                                          Colors.deepOrange.shade400,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          "assets/nav/cart.png",
                                          width: 42,
                                          height: 42,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // ✅ Modern heading
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      colors: [
                                        Colors.orange.shade700,
                                        Colors.deepOrange.shade600,
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      'Create Your Custom Kit',
                                      textAlign: TextAlign.center,
                                      style: text24(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.white,
                                      ).copyWith(letterSpacing: -0.5),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    'Handpick sacred items for your\npersonalized pooja ceremony',
                                    textAlign: TextAlign.center,
                                    style: text15(
                                      color: AppColors.grey600,
                                    ).copyWith(height: 1.6, letterSpacing: 0.2),
                                  ),

                                  const SizedBox(height: 36),

                                  // ✅ Premium search field
                                  _buildPremiumSearchField(
                                    context,
                                    ref,
                                    defaultKits.value?.defaultKit?.data ?? [],
                                  ),

                                  const SizedBox(height: 20),

                                  // ✅ Premium name field
                                  _buildPremiumTextField(),

                                  const SizedBox(height: 28),

                                  // ✅ Premium button
                                  _buildPremiumButton(context, ref),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ================== YOUR DRAFT KITS SECTION (UPDATED WITH TABS) ==================
                      // Filtered Draft Kits Section with Customized TabBar
                      userDraftKit.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) =>
                            const Center(child: Text("Failed to load kits")),
                        data: (kitState) {
                          final allKits = kitState.userKit?.data ?? [];

                          if (allKits.isEmpty) {
                            return SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Draft Kit",
                                  style: text15(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),

                                AnimationLimiter(
                                  // 🔥 Removed ValueKey with tabController
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),

                                    itemCount: allKits.length,
                                    itemBuilder: (context, index) {
                                      final kit = allKits[index];

                                      return AnimationConfiguration.staggeredList(
                                        position: index,
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        child: SlideAnimation(
                                          horizontalOffset: 50,
                                          child: FadeInAnimation(
                                            child: ScaleAnimation(
                                              scale: 0.95,
                                              child: _buildDraftKitCard(
                                                context,
                                                kit,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // ✅ Feature cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.check_circle_outline,
                                title: 'Customizable',
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.auto_awesome,
                                title: 'Premium Items',
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildFeatureCard(
                                icon: Icons.verified,
                                title: 'Authentic',
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDraftKitCard(BuildContext context, UserKitData kit) {
    final status = kit.status?.toLowerCase() ?? 'unknown';
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images Horizontal Scroll - Height Reduced
              SizedBox(
                height: 90, // ← Kam kiya (110 se 90)
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(8),
                  itemCount: kit.items.length,
                  itemBuilder: (context, index) {
                    final item = kit.items[index];
                    final imageUrl =
                        item.product?.media?.image.isNotEmpty == true
                        ? item.product!.media!.image.first
                        : "";

                    return Container(
                      width: 90, // ← Width bhi thoda kam
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomCachedImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Content Section - Padding Reduced
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  10,
                  12,
                  12,
                ), // ← Tight padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kit Name + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            kit.name ?? "My Custom Kit",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text15(
                              fontWeight: FontWeight.bold,
                            ), // ← Size kam kiya
                          ),
                        ),
                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: text11(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Items Count + Price
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${kit.items.length} items",
                                style: text12(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (kit.totalPrice != null)
                          Text(
                            "₹${kit.totalPrice}",
                            style: text18(
                              // Price thoda chhota
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Product Names (First 2 only - to save space)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: kit.items.take(2).map((item) {
                        return Text(
                          "• ${item.product?.title ?? "Product"}",
                          style: text12(color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      }).toList(),
                    ),

                    if (kit.items.length > 2)
                      Text(
                        "+${kit.items.length - 2} more",
                        style: text11(color: Colors.blue),
                      ),

                    const SizedBox(height: 12),

                    // Action Buttons - Compact
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _showKitProductsBottomSheet(context, kit),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "View All",
                                  style: text12(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              final notifier = ref.read(
                                customizeKitProvider.notifier,
                              );

                              // ✅ initialize kit before navigation
                              notifier.initializeFromUser(kit);

                              Navigator.pushNamed(
                                context,
                                AppRoutes.kitOrderSummary,
                                arguments: kit,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Buy Now",
                                  style: text14(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              ref.read(userDraftKits.notifier).deleteMyKit(kit.id ?? "");
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 18, color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Draft';
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'confirmed':
      case 'shipped':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'draft':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showKitProductsBottomSheet(BuildContext context, UserKitData kit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  /// 🔹 Drag Handle
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  /// 🔹 Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Kit Name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kit.name ?? "Custom Kit",
                                style: text18(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${kit.items.length} items",
                                style: text13(color: AppColors.grey600),
                              ),
                            ],
                          ),
                        ),

                        /// Total Price (Highlighted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "₹${kit.totalPrice ?? 0}",
                            style: text16(
                              fontWeight: FontWeight.w700,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),

                  /// 🔹 Product List
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(14),
                      itemCount: kit.items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = kit.items[index];
                        final product = item.product;

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              /// 🔹 Product Image + Qty Badge
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CustomCachedImage(
                                      imageUrl:
                                          product?.media?.image.isNotEmpty ==
                                              true
                                          ? product!.media!.image.first
                                          : "",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  /// Qty Badge
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.black87,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "x${item.quantity}",
                                        style: text11(
                                          color: AppColors.white,

                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 12),

                              /// 🔹 Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product?.title ?? "Unknown Product",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: text14(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "₹${item.priceAtTime} per item",
                                      style: text12(color: AppColors.grey600),
                                    ),
                                  ],
                                ),
                              ),

                              /// 🔹 Total Price
                              Text(
                                "₹${(item.quantity ?? 0) * (item.priceAtTime ?? 0)}",
                                style: text15(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ✅ Premium search field builder
  Widget _buildPremiumSearchField(
    BuildContext context,
    WidgetRef ref,
    List<DefaultKitData> poojas,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Select Pooja Type',
                style: text14(
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ).copyWith(letterSpacing: 0.3),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.button,
                AppColors.button.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.button.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Autocomplete<DefaultKitData>(
            // 🔥 IMPORTANT
            displayStringForOption: (kit) => kit.name ?? "",

            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return poojas;
              }
              return poojas.where(
                (kit) => (kit.name ?? '').toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },

            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    cursorColor: AppColors.white,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search for pooja kit...",
                      hintStyle: text15(
                        color: AppColors.white.withValues(alpha: 0.65),
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.white.withValues(alpha: 0.9),
                        size: 24,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  );
                },

            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 12,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withValues(alpha: 0.15),
                                    Colors.deepOrange.withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: CustomCachedImage(
                                  width: 32,
                                  height: 32,
                                  imageUrl: option.image ?? '',
                                ),
                              ),
                            ),
                            title: Text(
                              option.name ?? "", // ✅ FIXED
                              style: text15(
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey800,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },

            onSelected: (value) {
              ref.read(isFestivalProvider.notifier).state = false;

              Navigator.pushNamed(
                context,
                AppRoutes.festivalKitDetails,
                arguments: value, // 🔥 full object pass
              );
            },
          ),
        ),
      ],
    );
  }

  // ✅ Premium text field builder
  Widget _buildPremiumTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kit Name',
                style: text14(
                  fontWeight: FontWeight.w700,
                  color: AppColors.grey800,
                ).copyWith(letterSpacing: 0.3),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppTextField(
            radius: 16,
            controller: nameKitCtr,
            hintText: "e.g., My Diwali Special Kit",
          ),
        ),
      ],
    );
  }

  // ✅ Premium button builder
  Widget _buildPremiumButton(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (nameKitCtr.text.trim().isEmpty) {
              AppSnackbar.show(
                context,
                message: "Please Enter Your Kit Name",
                type: SnackBarType.error,
              );
              return;
            }
            ref.read(kitNameProvider.notifier).state = nameKitCtr.text.trim();
            Navigator.pushNamed(context, AppRoutes.kitItems);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  color: AppColors.white,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  'Start Adding Items',
                  style: text16(
                    color: AppColors.white,

                    fontWeight: FontWeight.w700,
                  ).copyWith(letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Feature card builder
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: text12(
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
        ],
      ),
    );
  }
}
