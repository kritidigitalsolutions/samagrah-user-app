import 'package:flutter/material.dart' hide Step;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/product_booked_res/track_order_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';

class TrackOrderPage extends ConsumerWidget {
  const TrackOrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = ModalRoute.of(context)!.settings.arguments as String;
    final orderAsync = ref.watch(trackOrderProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Track Your Order",
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text('🛵', style: TextStyle(fontSize: 28))),
          ),
        ],
      ),
      body: orderAsync.when(
        data: (response) => _buildOrderContent(response),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint('Track Order Error: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load order:\n$error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(trackOrderProvider(orderId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderContent(TrackOrderResModel response) {
    final data = response.data;
    final order = data?.order;
    final tracking = data?.tracking;
    final address = order?.address;
    final items = order?.items ?? [];

    // Debug - Remove after it works
    debugPrint('=== TRACKING DEBUG ===');
    debugPrint('Tracking object exists: ${tracking != null}');
    if (tracking != null) {
      debugPrint('Steps list length: ${tracking.orderSteps.length}');
      debugPrint('Current Status: ${tracking.currentStatus}');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delivery Address
          Text('Delivering To', style: text16(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            address != null
                ? '${address.fullAddress}, ${address.city}, ${address.state} - ${address.pincode}'
                : 'Address not available',
            style: text14(color: AppColors.grey700),
          ),
          const SizedBox(height: 24),

          // Timeline Header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Order Status Timeline',
                style: text15(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dynamic Timeline - Use .steps (NOT .orderSteps)
          if (tracking != null && tracking.orderSteps.isNotEmpty)
            ...tracking.orderSteps.map(
              (step) => TimelineStep(
                title: step.label ?? 'Step',
                subtitle: _getStepSubtitle(step),
                isCompleted: step.completed ?? false,
                isLast: tracking.orderSteps.last == step,
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No tracking information available',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 24),

          //_buildDeliveryPartnerSection(tracking),
          //const SizedBox(height: 24),

          // Order Items
          const Text(
            'Order Items',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 12),

          if (items.isNotEmpty)
            ...items.map((item) => _buildOrderItem(item))
          else
            const Text('No items found', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),

          AppOutlineButton(title: "Order Again", onTap: () {}),
        ],
      ),
    );
  }

  String _getStepSubtitle(OrderStep step) {
    if (step.completed == true) return 'Completed';
    if (step.active == true) return 'In Progress';
    return 'Pending';
  }

  Widget _buildDeliveryPartnerSection(Tracking? tracking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Partner',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Road Runner',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildIconButton('📞'),
                  const SizedBox(width: 8),
                  _buildIconButton('💬'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: AppColors.dividerDark),
          const SizedBox(height: 10),
          const Text(
            'Estimated Delivery Time',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            tracking?.lastUpdatedAt != null
                ? 'Updated: ${tracking!.lastUpdatedAt!.toString().substring(0, 16)}'
                : 'Today, by 6:05 PM',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(String emoji) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    );
  }

  Widget _buildOrderItem(dynamic item) {
    final kit = item.product;
    final name = kit?.name ?? 'Product';

    String imageUrl = '';
    if (kit?.items != null && kit!.items.isNotEmpty) {
      final subItem = kit.items.first;
      imageUrl = subItem.product?.media?.image.isNotEmpty == true
          ? subItem.product!.media!.image.first
          : '';
    }

    final totalPrice = (item.price ?? 0) * (item.quantity ?? 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(
                              "http://192.168.1.40:8000/${imageUrl}",
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? const Center(
                          child: Text('🪔', style: TextStyle(fontSize: 24)),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Qty: ${item.quantity ?? 1} • ₹${item.price ?? 0}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹$totalPrice',
            style: const TextStyle(
              color: Color(0xFFE91E63),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep your TimelineStep widget as it is
class TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isLast;

  const TimelineStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
