import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';

class OrderSummaryScreen extends ConsumerWidget {
  const OrderSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ModalRoute.of(context)?.settings.arguments as List<OrderItem>;
    final itemTotal = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    const deliveryFee = 20;
    final totalAmount = itemTotal + deliveryFee;
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

                  // Align(
                  //   alignment: Alignment.centerLeft,
                  //   child: Text(
                  //     kit.title ??'',
                  //     style: text18(fontWeight: FontWeight.w700),
                  //   ),
                  // ),
                ],
              ),
            ),

            // 📦 Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

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
                  _buildSummaryRow('Item Total', '₹$itemTotal'),
                  _buildSummaryRow('Delivery Fee', '₹$deliveryFee'),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹$totalAmount',
                    isTotal: true,
                  ),
                  const SizedBox(height: 16),

                  AppButton(
                    title: "Continue",
                    onTap: () {
                      final verifyItems = items.map((item) {
                        return VerifyItem(
                          productId: item.productId,
                          quantity: itemTotal,
                        );
                      }).toList();

                      ref.read(bookingItemProvider.notifier).state =
                          verifyItems;

                      ref.read(totalPriceProvider.notifier).state = totalAmount;

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
            color: isActive ? AppColors.button : AppColors.grey300,
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: text14(
                color: isActive ? AppColors.white : AppColors.grey600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: text12(color: isActive ? AppColors.black : AppColors.grey600),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.button : AppColors.grey300,
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
            style: text13(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: text15(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.button : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final String title;
  final int price;
  final int quantity;
  final String image;

  OrderItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });
}
