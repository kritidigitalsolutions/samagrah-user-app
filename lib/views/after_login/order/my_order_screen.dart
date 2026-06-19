import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/res/app_image.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/complaint_provider.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';
import 'package:samagrah/views/custom_loader.dart/order_card_loader.dart';
import 'package:samagrah/views/custom_widget/empty_data_widget.dart';

/// Type of complaint the user is raising
enum ComplaintType {
  /// Delivered order – product quality / wrong item / missing
  product,

  /// Cancelled online order – refund not received / wrong amount / delayed
  refund,
}

// ─────────────────────────────────────────────────────────────────────────────
// My Orders Page
// ─────────────────────────────────────────────────────────────────────────────

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
                  return EmptyDataWidget(
                    title: "No Orders Yet",
                    subtitle: "Your placed orders will appear here",
                    animationPath: AppImages.nothing,
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
              loading: () => ListView.builder(
                itemCount: 5,
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, _) => const OrderCardSkeleton(),
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
                      onPressed: () => ref.invalidate(orderProvider),
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

// ─────────────────────────────────────────────────────────────────────────────
// Order Card Widget
// ─────────────────────────────────────────────────────────────────────────────

class OrderCard extends ConsumerWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  String _getFirstImage(List<String>? images) {
    if (images == null || images.isEmpty) return '';
    return images.first;
  }

  List<ProductDisplayItem> _getDisplayItems() {
    final displayItems = <ProductDisplayItem>[];

    for (final orderItem in order.items) {
      final product = orderItem.product;

      if (product != null && product.items.isNotEmpty) {
        for (final kitItem in product.items) {
          displayItems.add(
            ProductDisplayItem(
              name: kitItem.product?.title ?? 'Unknown',
              emoji: _getFirstImage(kitItem.product?.media?.image),
              pack: 'Qty: ${kitItem.quantity ?? 1}',
            ),
          );
        }
      } else {
        displayItems.add(
          ProductDisplayItem(
            name: product?.title ?? product?.name ?? 'Unknown',
            emoji: _getFirstImage(product?.media?.image),
            pack: 'Qty: ${orderItem.quantity ?? 1}',
          ),
        );
      }
    }
    return displayItems;
  }

  // ── Status helpers ─────────────────────────────────────────────────────────
  String? get _status => order.tracking?.currentStatus ?? order.orderStatus;

  bool get _isDelivered => _status?.toLowerCase() == 'delivered';

  bool get _isCancelled =>
      (_status?.toLowerCase() == 'cancelled') ||
      (order.tracking?.isCancelled ?? false);

  bool get _isOnlinePaid =>
      (order.paymentMethod ?? '').toUpperCase() == 'ONLINE';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // ── Status badge row ────────────────────────────────────────────
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

            // ── Content ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (!isMultiItem)
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
                                order.razorpayOrderId ?? '',
                                style: text11(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.button,
                                ),
                              ),
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

                  // ── Refund pending banner (cancelled + online paid) ───────
                  if (_isCancelled && _isOnlinePaid) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: Colors.amber.shade800,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Refund of ${OrderUtils.formatCurrency(order.totalAmount)} will be credited to your wallet',
                              style: text12(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // ── Action buttons ─────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          height: 38,
                          radius: 15,
                          title: "View Details",
                          onTap: onTap,
                        ),
                      ),

                      // 1) Delivered → Complain (product quality)
                      if (_isDelivered) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppOutlineButton(
                            height: 38,
                            radius: 15,
                            title: "Complain",
                            onTap: () => showComplainBottomSheet(
                              context,
                              ref,
                              order,
                              complaintType: ComplaintType.product,
                            ),
                          ),
                        ),
                      ]
                      // 2) Cancelled + Online paid → Refund Issue
                      else if (_isCancelled && _isOnlinePaid) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppOutlineButton(
                            height: 38,
                            radius: 15,
                            title: "Refund Issue",
                            onTap: () => showComplainBottomSheet(
                              context,
                              ref,
                              order,
                              complaintType: ComplaintType.refund,
                            ),
                          ),
                        ),
                      ]
                      // 3) Active order (not delivered, not cancelled) → Cancel
                      else if (!_isCancelled) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppOutlineButton(
                            height: 38,
                            radius: 15,
                            title: "Cancel",
                            onTap: () =>
                                showCancelOrderBottomSheet(context, ref, order),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cancel Order Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

void showCancelOrderBottomSheet(
  BuildContext context,
  WidgetRef ref,
  Order order,
) {
  final orderId = order.id ?? '';
  const reasons = [
    "Changed my mind",
    "Found better price elsewhere",
    "Ordered by mistake",
    "Delivery taking too long",
    "Other",
  ];

  ref.read(selectedCancelReasonProvider.notifier).state = null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Consumer(
        builder: (context, ref, _) {
          final selectedReason = ref.watch(selectedCancelReasonProvider);
          final cancelState = ref.watch(cancelOrderProvider);
          final isOnlinePaid =
              (order.paymentMethod ?? '').toUpperCase() == 'ONLINE';

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Cancel Order",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Please select a reason for cancellation",
                  style: text14(color: AppColors.grey600),
                ),
                const SizedBox(height: 12),

                // ── Refund to wallet banner (online paid only) ─────────────
                if (isOnlinePaid) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Refund to Wallet",
                                style: TextStyle(
                                  color: Colors.green.shade900,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Since you paid online, a refund of ${OrderUtils.formatCurrency(order.totalAmount)} will be credited back to your wallet within 5–7 business days after cancellation.",
                          style: TextStyle(
                            color: Colors.green.shade900,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                ...reasons.map(
                  (reason) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedReason == reason
                            ? AppColors.button
                            : AppColors.grey200,
                      ),
                    ),
                    child: RadioListTile<String>(
                      activeColor: AppColors.button,
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.button;
                        }
                        return AppColors.grey400;
                      }),
                      value: reason,
                      groupValue: selectedReason,
                      title: Text(
                        reason,
                        style: text14(fontWeight: FontWeight.w500),
                      ),
                      onChanged: (value) {
                        ref.read(selectedCancelReasonProvider.notifier).state =
                            value;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                AppButton(
                  title: cancelState.isLoading ? "Cancelling..." : "Submit",
                  onTap: cancelState.isLoading
                      ? null
                      : () async {
                          if (selectedReason == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select reason"),
                              ),
                            );
                            return;
                          }

                          final success = await ref
                              .read(cancelOrderProvider.notifier)
                              .cancelOrder(orderId, selectedReason);

                          if (!context.mounted) return;

                          if (success) {
                            Navigator.pop(context);
                            ref.invalidate(orderProvider);

                            if (isOnlinePaid) {
                              _showRefundSuccessDialog(context, order);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Order cancelled successfully"),
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Dialog shown after successful cancellation of an online paid order
void _showRefundSuccessDialog(BuildContext context, Order order) {
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600),
          const SizedBox(width: 8),
          const Text("Order Cancelled"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Your order has been cancelled successfully.", style: text14()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.green.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Refund of ${OrderUtils.formatCurrency(order.totalAmount)} will be credited to your wallet within 5–7 business days.",
                    style: text12(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "If you don't receive the refund within 7 days, you can raise a complaint from the order card.",
            style: text12(color: AppColors.grey600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx),
          child: Text("OK", style: TextStyle(color: AppColors.button)),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Complaint Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

void showComplainBottomSheet(
  BuildContext context,
  WidgetRef ref,
  Order order, {
  ComplaintType complaintType = ComplaintType.product,
}) {
  final orderId = order.razorpayOrderId ?? order.id ?? '';

  // Different reason list based on complaint type
  final reasons = complaintType == ComplaintType.refund
      ? const [
          "Refund not received",
          "Refund amount is incorrect",
          "Refund credited to wrong wallet",
          "Refund taking too long",
          "Other",
        ]
      : const [
          "Damaged product received",
          "Wrong item delivered",
          "Missing item in order",
          "Quality not as expected",
          "Other",
        ];

  String? selectedReason;
  final detailController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          bool isSubmitting = false;

          Future<void> submitComplaint() async {
            if (selectedReason == null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text("Please select a reason")),
              );
              return;
            }

            setSheetState(() => isSubmitting = true);

            final success = await ref
                .read(complaintSubmitProvider.notifier)
                .submit(
                  orderId: order.id ?? '',
                  issue: selectedReason!,
                  details: detailController.text.trim(),
                );

            if (!ctx.mounted) return;
            setSheetState(() => isSubmitting = false);

            if (!success) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text("Failed to raise complaint. Try again."),
                ),
              );
              return;
            }

            Navigator.pop(sheetCtx);

            showDialog(
              context: ctx,
              builder: (dialogCtx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      complaintType == ComplaintType.refund
                          ? "Refund Issue Reported"
                          : "Complaint Raised",
                    ),
                  ],
                ),
                content: Text(
                  complaintType == ComplaintType.refund
                      ? "Your refund issue for Order ID $orderId has been registered. Our support team will look into it and get back to you shortly."
                      : "Your complaint for Order ID $orderId has been registered successfully. Our support team will get in touch with you shortly.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(
                      "OK",
                      style: TextStyle(color: AppColors.button),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  complaintType == ComplaintType.refund
                      ? "Refund Issue"
                      : "Complaint / Refund Request",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Order ID: $orderId",
                  style: text13(
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complaintType == ComplaintType.refund
                      ? "Note: Your order was cancelled. If you have any issue with the refund, please raise a complaint below."
                      : "Note: Refunds are not applicable for delivered orders. You can raise a complaint or replacement query below.",
                  style: text12(color: AppColors.error),
                ),
                const SizedBox(height: 16),

                Text(
                  "Select Issue",
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedReason,
                      hint: Text(
                        "Choose reason...",
                        style: text14(color: AppColors.grey500),
                      ),
                      items: reasons
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(r, style: text14()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setSheetState(() => selectedReason = val),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  "Explain in Detail",
                  style: text14(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: detailController,
                  maxLines: 3,
                  style: text14(),
                  decoration: InputDecoration(
                    hintText: "Tell us more about the issue...",
                    hintStyle: text13(color: AppColors.grey400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                AppButton(
                  title: isSubmitting ? "Submitting..." : "Submit Complaint",
                  onTap: isSubmitting ? null : submitComplaint,
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Or contact our support team directly:",
                    style: text12(color: AppColors.grey600),
                  ),
                ),
                const SizedBox(height: 12),

                const SizedBox(height: 16),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetCtx); // bottomsheet close karo
                      Navigator.pushNamed(context, AppRoutes.helpAndSupport);
                    },
                    icon: Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.button,
                      size: 18,
                    ),
                    label: Text(
                      "Need More Help?",
                      style: text13(
                        color: AppColors.button,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
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
