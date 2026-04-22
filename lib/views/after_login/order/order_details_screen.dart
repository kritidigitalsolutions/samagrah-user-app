import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String? orderId;

  const OrderDetailsPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get orderId from arguments if not passed directly
    final orderAsync = ModalRoute.of(context)?.settings.arguments as Order?;

    if (orderAsync == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Order ID not found',
            style: text16(color: AppColors.grey600),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.grey700),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Details',
          style: text18(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: OrderDetailsContent(order: orderAsync),

      // loading: () => const Center(
      //   child: CircularProgressIndicator(
      //     color: AppColors.button,
      //   ),
      // ),
      // error: (error, stack) => Center(
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Icon(
      //         Icons.error_outline,
      //         size: 60,
      //         color: Colors.red.shade300,
      //       ),
      //       const SizedBox(height: 16),
      //       Text(
      //         'Failed to load order details',
      //         style: text16(
      //           color: AppColors.grey600,
      //           fontWeight: FontWeight.w500,
      //         ),
      //       ),
      //       const SizedBox(height: 8),
      //       Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 32),
      //         child: Text(
      //           error.toString(),
      //           textAlign: TextAlign.center,
      //           style: text12(color: AppColors.grey),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}

class OrderDetailsContent extends StatelessWidget {
  final Order order;

  const OrderDetailsContent({super.key, required this.order});

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
              emoji:
                  "http://192.168.1.40:8000/${kitItem.product?.media?.image.first}",
              quantity: kitItem.quantity ?? 1,
              price: kitItem.priceAtTime ?? 0,
            ),
          );
        }
      } else {
        // Single product or kit itself
        displayItems.add(
          ProductDisplayItem(
            name:
                orderItem.product?.title ??
                orderItem.product?.name ??
                'Unknown',
            emoji:
                "http://192.168.1.40:8000/${orderItem.product?.media?.image.first}",
            quantity: orderItem.quantity ?? 1,
            price: orderItem.price ?? 0,
          ),
        );
      }
    }

    return displayItems;
  }

  @override
  Widget build(BuildContext context) {
    final displayItems = _getDisplayItems();
    final mainItem = displayItems.isNotEmpty ? displayItems[0] : null;
    final statusColor = OrderUtils.getStatusColor(
      order.tracking?.currentStatus ?? order.orderStatus,
    );
    final statusText = OrderUtils.getStatusText(
      order.tracking?.currentStatus ?? order.orderStatus,
    );

    return SafeArea(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        elevation: 2,
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status badge and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: statusColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Status: $statusText',
                            style: text10(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Placed on ${OrderUtils.formatDateShort(order.createdAt)}',
                      style: text12(color: AppColors.grey600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Main product display (first item)
                if (mainItem != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mainItem.name,
                              style: text24(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Quantity: ${mainItem.quantity}',
                              style: text14(color: AppColors.grey),
                            ),
                            if (displayItems.length > 1)
                              Text(
                                '+${displayItems.length - 1} more items',
                                style: text12(color: AppColors.button),
                              ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.button,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                OrderUtils.formatCurrency(order.totalAmount),
                                style: text16(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.orange.shade50,
                          child: CustomCachedImage(
                            imageUrl: displayItems[0].emoji,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 24),

                // Items Ordered
                Text(
                  'Items Ordered',
                  style: text16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 12),
                ...displayItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomCachedImage(imageUrl: item.emoji),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: text14(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Quantity: ${item.quantity}',
                                style: text12(color: AppColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          OrderUtils.formatCurrency(item.price),
                          style: text14(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 24),

                // Order Information
                Text(
                  'Order Information',
                  style: text16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Order ID:', OrderUtils.getOrderNumber(order.id)),
                _buildInfoRow(
                  'Order Date:',
                  OrderUtils.formatDateShort(order.createdAt),
                ),
                _buildInfoRow(
                  'Payment Method:',
                  OrderUtils.getStatusText(order.paymentMethod),
                ),
                _buildInfoRow(
                  'Payment Status:',
                  OrderUtils.getStatusText(order.paymentStatus),
                ),
                const SizedBox(height: 24),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 24),

                // Order Summary
                Text(
                  'Order Summary',
                  style: text16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Subtotal:',
                  OrderUtils.formatCurrency(order.amountBreakup?.itemTotal),
                ),
                _buildInfoRow(
                  'Delivery Fee:',
                  OrderUtils.formatCurrency(order.amountBreakup?.deliveryFee),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: text14(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      OrderUtils.formatCurrency(order.totalAmount),
                      style: text16(
                        color: AppColors.button,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Divider
                Divider(color: Colors.grey.shade300, height: 1),
                const SizedBox(height: 24),

                // Delivery Address
                Text(
                  'Delivery Address',
                  style: text16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 12),
                if (order.address != null) ...[
                  if (order.address!.name != null)
                    Text(
                      order.address!.name!,
                      style: text14(fontWeight: FontWeight.w600),
                    ),
                  if (order.address!.phone != null)
                    Text('Phone: ${order.address!.phone}', style: text14()),
                  const SizedBox(height: 4),
                  if (order.address!.fullAddress != null)
                    Text(order.address!.fullAddress!, style: text14()),
                  const SizedBox(height: 4),
                  Text(
                    '${order.address!.city ?? ''}, ${order.address!.state ?? ''} - ${order.address!.pincode ?? ''}',
                    style: text14(),
                  ),
                ] else
                  Text(
                    'Address not available',
                    style: text14(color: AppColors.grey600),
                  ),
                const SizedBox(height: 32),

                // Track Order Button
                if (order.tracking != null &&
                    order.tracking!.currentStatus != 'delivered' &&
                    !(order.tracking!.isCancelled ?? false))
                  Center(
                    child: CustomElevatedIconButton(
                      text: "Track Order",
                      icon: Icons.location_on,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.trackOrder,
                          arguments: order.id,
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Thank you message
                Center(
                  child: Text(
                    'Thank you for ordering your pooja\nessentials with us ^_^',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: text14(color: AppColors.grey600)),
          Flexible(
            child: Text(
              value ?? 'N/A',
              style: text14(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDisplayItem {
  final String name;
  final String emoji;
  final int quantity;
  final int price;

  ProductDisplayItem({
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.price,
  });
}
