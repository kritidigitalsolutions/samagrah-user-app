import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/product_details_provider.dart';
import 'package:samagrah/views/custom_widget/product_image_slider.dart';

class ProductDetailsBottomSheet extends ConsumerWidget {
  final String productId;

  const ProductDetailsBottomSheet({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProduct = ref.watch(productDetailsProvider(productId));

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: asyncProduct.when(
            /// 🔄 LOADING
            loading: () => const Center(child: CircularProgressIndicator()),

            /// ❌ ERROR
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 40, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Something went wrong"),
                  Text("$e", style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),

            /// ✅ DATA
            data: (res) {
              final product = res.data;
              if (product == null) {
                return const Center(child: Text("No product found"));
              }

              final pricing = product.pricing;

              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔘 Drag Handle
                    Center(
                      child: Container(
                        height: 4,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    /// 🖼 IMAGE SLIDER
                    SizedBox(child: ProductImageSlider(images: product.image)),

                    const SizedBox(height: 16),

                    /// 🏷 TITLE
                    Text(
                      product.title ?? "Product",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// 📦 CATEGORY
                    Text(
                      product.category ?? "",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 12),

                    /// 💰 PRICE
                    Row(
                      children: [
                        Text(
                          "₹${pricing?.price ?? 0}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),

                        if (pricing?.mrp != null)
                          Text(
                            "₹${pricing!.mrp}",
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),

                        const SizedBox(width: 8),

                        if (pricing?.discountPercent != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "${pricing!.discountPercent}% OFF",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (pricing?.savings != null)
                      Text(
                        "You save ₹${pricing!.savings}",
                        style: const TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 12),

                    /// 📊 STOCK
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 10,
                          color: product.stock?.status == "in_stock"
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(product.stock?.status ?? "Unknown"),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// TAGS
                    if (product.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(tag),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
