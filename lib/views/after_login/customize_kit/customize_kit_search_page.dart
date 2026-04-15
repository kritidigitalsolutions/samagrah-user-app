import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class CustomizePoojaKitScreen extends ConsumerWidget {
  CustomizePoojaKitScreen({super.key});

  final nameKitCtr = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDraftKit = ref.watch(userDraftKits);
    final poojas = [
      'Satyanarayan Pooja',
      'Griha Provesh Pooja',
      'Lakshmi Pooja',
      'Ganesh Pooja',
    ];

    return SafeArea(
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
                                  child: const Text(
                                    'Create Your Custom Kit',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'Handpick sacred items for your\npersonalized pooja ceremony',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                ),

                                const SizedBox(height: 36),

                                // ✅ Premium search field
                                _buildPremiumSearchField(context, ref, poojas),

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

                    const SizedBox(height: 28),

                    userDraftKit.when(
                      loading: () => const SizedBox(),
                      error: (e, _) => const SizedBox(),
                      data: (kitState) {
                        final kits = kitState.userKit?.data ?? [];

                        /// ❌ Empty → kuch nahi dikhana
                        if (kits.isEmpty) return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Text(
                                "Your Draft Kits",
                                style: text15(fontWeight: FontWeight.bold),
                              ),
                            ),

                            const SizedBox(height: 10),

                            AnimationLimiter(
                              key: ValueKey(
                                "draft_${kits.length}",
                              ), // 🔥 re-animation
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                itemCount: kits.length,
                                itemBuilder: (context, index) {
                                  final kit = kits[index];

                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: Duration(milliseconds: 400),
                                    child: SlideAnimation(
                                      horizontalOffset:
                                          50, // 👉 right se aayega
                                      child: FadeInAnimation(
                                        child: ScaleAnimation(
                                          scale: 0.9, // 🔥 premium zoom
                                          child: GestureDetector(
                                            onTap: () {
                                              // 👉 open edit kit screen
                                            },
                                            child: _buildDraftKitCard(
                                              context,
                                              kit,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 20),
                          ],
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
    );
  }

  Widget _buildDraftKitCard(BuildContext context, Datum kit) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 All Product Images (Horizontal List)
          SizedBox(
            height: 110,

            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kit.items.length,
              itemBuilder: (context, index) {
                final item = kit.items[index];
                final image = item.product?.media?.image.isNotEmpty == true
                    ? item.product!.media!.image.first
                    : null;

                return Container(
                  width: 110,

                  margin: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomCachedImage(
                      imageUrl: image != null
                          ? "http://192.168.1.40:8000/$image"
                          : "https://via.placeholder.com/150",
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🔹 Content Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔸 Kit Name + Actions
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        kit.name ?? "My Custom Kit",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text16(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    /// ✏️ Edit
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        // TODO: Edit Kit
                      },
                    ),

                    /// 🗑 Delete
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // TODO: Delete Kit
                      },
                    ),
                  ],
                ),

                /// 🔸 Total Items
                Text(
                  "${kit.items.length} items",
                  style: text12(color: AppColors.grey),
                ),

                /// 🔸 Price
                if (kit.totalPrice != null)
                  Text(
                    "₹${kit.totalPrice}",
                    style: text18(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),

                const SizedBox(height: 12),

                /// 🔸 Product List (Names)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: kit.items.take(3).map((item) {
                    return Text(
                      "• ${item.product?.title ?? "Product"}",
                      style: text12(color: Colors.black87),
                    );
                  }).toList(),
                ),

                if (kit.items.length > 3)
                  Text(
                    "+${kit.items.length - 3} more items",
                    style: text12(color: Colors.blue),
                  ),

                const SizedBox(height: 12),

                /// 🔸 Buttons Row
                Row(
                  children: [
                    /// View All
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showKitProductsBottomSheet(context, kit);
                        },
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

                    /// Buy Now
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Buy Now API / Checkout
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Buy Now",
                              style: TextStyle(
                                color: Colors.white,
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
    );
  }

  void _showKitProductsBottomSheet(BuildContext context, Datum kit) {
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
                                          ? "http://192.168.1.40:8000/${product!.media!.image.first}"
                                          : "https://via.placeholder.com/100",
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
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "x${item.quantity}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
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
    List<String> poojas,
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
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
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return poojas.where(
                (pooja) => pooja.toLowerCase().contains(
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
                      hintStyle: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.65),
                        fontSize: 15,
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
                                child: Image.asset(
                                  "assets/god.png",
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                            title: Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
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
              ref.read(selectedPoojaProvider.notifier).state = value;
              ref.read(isFestivalProvider.notifier).state = false;
              Navigator.pushNamed(context, AppRoutes.festivalKitDetails);
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
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
                Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Start Adding Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
