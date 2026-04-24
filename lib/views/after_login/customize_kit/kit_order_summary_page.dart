import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class KitOrderSummaryPage extends ConsumerWidget {
  const KitOrderSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null) {
      return const Scaffold(body: Center(child: Text("No data found")));
    }

    final kit = mapToOrderSummary(args);

    final itemTotal = kit.totalPrice;
    final totalAmount = itemTotal;
    final notifier = ref.read(customizeKitProvider.notifier);
    final totalPrice = notifier.totalPrice;

    final isCustomized = notifier.isCustomized;

    print("$itemTotal");
    print("$totalPrice");
    print("$isCustomized");
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStep(1, 'Item\nSummary', true),
                      _buildStepConnector(isActive: true),
                      _buildStep(2, 'Delivery\nAddress', false),
                      _buildStepConnector(isActive: false),
                      _buildStep(3, 'Payment\nMethod', false),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      kit.name,
                      style: text18(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),

            // 📦 Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kit.items.length,
                itemBuilder: (context, index) {
                  final item = kit.items[index];

                  final image = item.image.isNotEmpty
                      ? item.image.replaceAll("\\", "/")
                      : "";

                  final itemTotal = item.quantity * item.price;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: image.isNotEmpty
                              ? CustomCachedImage(
                                  imageUrl: "http://192.168.1.40:8000/$image",
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                ),
                        ),

                        const SizedBox(width: 12),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: text16(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Qty: ${item.quantity}",
                                style: text13(color: AppColors.grey400),
                              ),
                              Text(
                                "₹${item.price}",
                                style: text13(color: AppColors.grey400),
                              ),
                            ],
                          ),
                        ),

                        // Total
                        Text(
                          "₹$itemTotal",
                          style: text15(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🧾 Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // _buildSummaryRow(
                  //   'Item Total',
                  //   isCustomizeKit ? "₹$totalPrice" : '₹$itemTotal',
                  // ),
                  // // _buildSummaryRow('Delivery Fee', '₹$deliveryFee'),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Total Amount',
                    isCustomized ? "₹$totalPrice" : '₹$totalAmount',
                    isTotal: true,
                  ),
                  const SizedBox(height: 16),

                  AppButton(
                    title: "Continue",
                    onTap: () {
                      final verifyItems = VerifyItem(productId: kit.id);
                      ref.read(bookingItemProvider.notifier).state = [
                        verifyItems,
                      ];
                      if (isCustomized) {
                        ref.read(totalPriceProvider.notifier).state =
                            totalPrice;
                      } else {
                        ref.read(totalPriceProvider.notifier).state =
                            totalAmount;
                      }

                      Navigator.pushNamed(context, AppRoutes.addressPage);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.button : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.button : Colors.grey[300],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.button : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderSummaryModel {
  final String id;
  final String name;
  final List<OrderItemModel> items;
  final int totalPrice;

  OrderSummaryModel({
    required this.id,
    required this.name,
    required this.items,
    required this.totalPrice,
  });
}

class OrderItemModel {
  final String id;
  final String title;
  final String image;
  final int quantity;
  final int price;

  OrderItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.quantity,
    required this.price,
  });
}

OrderSummaryModel mapToOrderSummary(dynamic args) {
  if (args is UserKitData) {
    return OrderSummaryModel(
      id: args.id ?? '',
      name: args.name ?? "",
      totalPrice: args.totalPrice ?? 0,
      items: args.items.map((e) {
        return OrderItemModel(
          id: e.product?.id ?? '',
          title: e.product?.title ?? "",
          image: (e.product?.media?.image.isNotEmpty == true)
              ? e.product!.media!.image.first
              : "",
          quantity: e.quantity ?? 0,
          price: e.priceAtTime ?? 0,
        );
      }).toList(),
    );
  } else if (args is DefaultKitData) {
    return OrderSummaryModel(
      id: args.id ?? '',
      name: args.name ?? "",
      totalPrice: args.kitPrice ?? 0,
      items: args.items.map((e) {
        return OrderItemModel(
          id: e.product?.id ?? '',
          title: e.product?.title ?? "",
          image: (e.product?.media?.image.isNotEmpty == true)
              ? e.product!.media!.image.first
              : "",
          quantity: e.quantity ?? 0,
          price: e.product?.pricing?.price ?? 0,
        );
      }).toList(),
    );
  } else if (args is Product) {}

  throw Exception("Invalid data passed");
}
