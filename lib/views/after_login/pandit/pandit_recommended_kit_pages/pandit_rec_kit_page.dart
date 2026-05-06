import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';

class PanditRecKitPage extends ConsumerWidget {
  // ← ConsumerWidget now
  const PanditRecKitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ← Receive customSamagriItems passed via Navigator arguments
    final samagriItems =
        ModalRoute.of(context)!.settings.arguments as List<CustomSamagriItem>;

    // ← Get all products from provider to match by title
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
          error: (e, _) => const Center(child: Text("Something went wrong")),
          data: (state) {
            final allProducts = state.customizeKitItems;

            // ← Match each samagriItem to a Product by title (case-insensitive)
            // ← Match each samagriItem to a Product by ID
            final matchedItems = samagriItems.map((item) {
              final matched = allProducts.firstWhere(
                (p) => p.id == item.id, // ← match by id instead of title
                orElse: () => Product(
                  id: null,
                  title: item.itemName, // ← fallback title from samagriItem
                  description: null,
                  details: null,
                  price: null,
                  oldPrice: null,
                  discountPercent: null,
                  thumbnail: null,
                  images: [],
                  category: null,
                  inStock: null,
                  ratings: null,
                  isRecommended: null,
                  isMostPoojaEssentials: null,
                  isMostUsed: null,
                  isEveryDayRitual: null,
                  isRitualItems: null,
                ),
              );
              return (samagriItem: item, product: matched);
            }).toList();

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text('Items Included', style: text18()),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: matchedItems.length,
                    itemBuilder: (context, index) {
                      final entry = matchedItems[index];
                      final item = entry.samagriItem;
                      final product = entry.product;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () {
                            if (product.id != null) {
                              // ← Navigate to product detail if matched
                              Navigator.pushNamed(
                                context,
                                AppRoutes.panditRecKit2,
                                arguments: product.id,
                              );
                            }
                          },
                          child: _buildItemCard(item, product),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AppButton(title: "Add More Items", onTap: () {}),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemCard(CustomSamagriItem item, Product product) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 4, spreadRadius: 6, color: AppColors.grey100),
        ],
      ),
      child: Row(
        children: [
          // ← Show product thumbnail if matched, else placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.thumbnail != null
                ? CustomCachedImage(
                    imageUrl: product.thumbnail!,
                    height: 50,
                    width: 60,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 50,
                    width: 60,
                    color: AppColors.grey100,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppColors.grey,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.itemName ?? 'Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                // ← Show quantity + size from samagriItem
                Text(
                  "Qty: ${item.quantity ?? 1}"
                  "${(item.size != null && item.size!.isNotEmpty) ? '  •  ${item.size}' : ''}",
                  style: const TextStyle(fontSize: 11, color: AppColors.button),
                ),
              ],
            ),
          ),

          // ← Only show arrow if product was matched (has detail page)
          if (product.id != null)
            const Icon(Icons.chevron_right)
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
