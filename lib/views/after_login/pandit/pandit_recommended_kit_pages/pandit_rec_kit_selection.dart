import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart' show CustomAppBar;
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_kit_provider.dart';

class PanditRecKitSelection extends StatelessWidget {
  const PanditRecKitSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerCard,
      appBar: CustomAppBar(
        title: 'Samagri Kit',
        subtitle: 'Pandit Recommended',

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/god.png',
              width: 70,
              height: 70,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.grey500,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grid of Products
            Expanded(
              child: Container(
                color: AppColors.background,
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                ),
              ),
            ),

            // Back to Kit Button
            Container(
              padding: const EdgeInsets.all(16.0),
              color: AppColors.white,
              child: AppOutlineButton(
                title: "< Back to Kit",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.festivalKitDetails);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Data Model
class Product {
  final String name;
  final String price;
  final String imagePath; // Use AssetImage or NetworkImage in real app
  final bool hasGreenTick;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    this.hasGreenTick = false,
  });
}

// Sample Products (Replace with your actual images)
final List<Product> products = [
  Product(
    name: "Cycle Agarbatti",
    price: "₹78",
    imagePath: "assets/icon/sticks.png",
    hasGreenTick: true,
  ),
  Product(
    name: "Mongoldeep\nAgarbatti",
    price: "₹100",
    imagePath: "assets/icon/sticks.png",
    hasGreenTick: true,
  ),
  Product(
    name: "Zed Black\nAgarbatti",
    price: "₹112",
    imagePath: "assets/icon/sticks.png",
    hasGreenTick: true,
  ),
  Product(
    name: "Patanjali\nAgarbatti",
    price: "₹50",
    imagePath: "assets/icon/sticks.png",
  ),
  Product(
    name: "Local Premium\nAgarbatti",
    price: "₹30",
    imagePath: "assets/icon/sticks.png",
  ),
];

// Product Card Widget
class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(productProvider.notifier);
    final isSelected = ref.watch(
      productProvider.select((state) => state.containsKey(product.name)),
    );
    final quantity = ref.watch(
      productProvider.select((state) => state[product.name]?.quantity ?? 0),
    );
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  product.imagePath,
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              if (product.hasGreenTick)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: text12(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.price,
                      style: text14(
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Quantity Selector
              Container(
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => notifier.removeProduct(product),
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () => notifier.addProduct(product),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // View Product Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AppOutlineButton(
                  height: 30,
                  title: "View Product",
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
