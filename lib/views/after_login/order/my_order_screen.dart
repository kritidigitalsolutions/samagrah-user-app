import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';

// My Orders Page
class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "My Orders"),
      body: SafeArea(
        child: Stack(
          children: [
            ordersAsync.when(
              data: (data) {
                final orders = data.orders?.data?.orders ?? [];
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: text18(
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start shopping to see your orders here',
                          style: text14(color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(orderProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return OrderCard(
                        order: orders[index],
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderDetails,
                            arguments: orders[index],
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.button),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load orders',
                      style: text16(
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: text12(color: AppColors.grey),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.invalidate(orderProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: CustomElevatedIconButton(
                  text: "Back to Home",
                  icon: Icons.home,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyHomeScreen(index: 0)),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  List<ProductDisplayItem> _getDisplayItems() {
    List<ProductDisplayItem> displayItems = [];

    for (var orderItem in order.items) {
      if (orderItem.product?.items != null &&
          orderItem.product!.items.isNotEmpty) {
        // Booked kit with multiple products
        for (var kitItem in orderItem.product!.items) {
          displayItems.add(
            ProductDisplayItem(
              name: kitItem.product?.title ?? 'Unknown',
              emoji: kitItem.product?.media?.image.first ?? '',
              pack: 'Qty: ${kitItem.quantity ?? 1}',
            ),
          );
        }
      } else {
        // Single product
        displayItems.add(
          ProductDisplayItem(
            name:
                orderItem.product?.title ??
                orderItem.product?.name ??
                'Unknown',
            emoji: orderItem.product?.media?.image.first ?? '',
            pack: 'Qty: ${orderItem.quantity ?? 1}',
          ),
        );
      }
    }

    return displayItems;
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _getDisplayItems();
    final isMultiItem = displayItems.length > 1;
    final statusColor = OrderUtils.getStatusColor(
      order.tracking?.currentStatus ?? order.orderStatus,
    );
    final statusText = OrderUtils.getStatusText(
      order.tracking?.currentStatus ?? order.orderStatus,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusText,
                        style: text14(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    OrderUtils.formatDateShort(order.createdAt),
                    style: text12(color: AppColors.grey600),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!isMultiItem)
                    // Single Item Display
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomCachedImage(
                              imageUrl: displayItems[0].emoji,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayItems[0].name,
                                style: text16(fontWeight: FontWeight.w600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                displayItems[0].pack,
                                style: text14(color: AppColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              OrderUtils.getOrderNumber(order.id),
                              style: text20(
                                fontWeight: FontWeight.bold,
                                color: AppColors.button,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              OrderUtils.formatCurrency(order.totalAmount),
                              style: text16(
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    // Multiple Items Display
                    Column(
                      children: [
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: displayItems.length > 4
                              ? 4
                              : displayItems.length,
                          itemBuilder: (context, index) {
                            final item = displayItems[index];
                            return Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CustomCachedImage(
                                        imageUrl: item.emoji,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.name,
                                  style: text10(),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${displayItems.length} items',
                              style: text14(color: AppColors.grey600),
                            ),
                            Text(
                              OrderUtils.formatCurrency(order.totalAmount),
                              style: text18(
                                fontWeight: FontWeight.bold,
                                color: AppColors.button,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  AppButton(title: "View Details", onTap: onTap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDisplayItem {
  final String name;
  final String emoji;
  final String pack;

  ProductDisplayItem({
    required this.name,
    required this.emoji,
    required this.pack,
  });
}
