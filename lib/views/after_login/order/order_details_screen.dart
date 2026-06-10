// lib/view/after_login/orders/order_details_page.dart

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
    );
  }
}

// ---------------------------------------------------------------------------

class OrderDetailsContent extends ConsumerWidget {
  final Order order;

  const OrderDetailsContent({super.key, required this.order});

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _isKit() {
    if (order.items.isEmpty) return false;
    return (order.items.first.productType ?? '').toLowerCase() != 'item';
  }

  List<ProductDisplayItem> _getDisplayItems() {
    List<ProductDisplayItem> displayItems = [];

    for (var orderItem in order.items) {
      if (orderItem.product?.items != null &&
          orderItem.product!.items.isNotEmpty) {
        // Kit → expand kit items
        for (var kitItem in orderItem.product!.items) {
          displayItems.add(
            ProductDisplayItem(
              name: kitItem.product?.title ?? 'Unknown',
              emoji: kitItem.product?.media?.image.firstOrNull ?? '',
              quantity: kitItem.quantity ?? 1,
              price: kitItem.product?.pricing?.price ?? 0,
              productId: kitItem.product?.id ?? '',
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
            emoji: orderItem.product?.media?.image.firstOrNull ?? '',
            quantity: orderItem.quantity ?? 1,
            price: orderItem.price ?? 0,
            productId: orderItem.product?.id ?? '',
          ),
        );
      }
    }

    return displayItems;
  }

  void _showRatingSheet(
    BuildContext context,
    WidgetRef ref,
    ProductDisplayItem item,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        child: RatingBottomSheet(orderId: order.id ?? '', item: item),
      ),
    );
  }

  // ── Header Builders ───────────────────────────────────────────────────────

  Widget _buildKitHeader() {
    final kitProduct = order.items.first.product;
    final kitName = kitProduct?.name ?? kitProduct?.title ?? 'Kit';
    final kitImage =
        kitProduct?.media?.image.firstOrNull ?? kitProduct?.image ?? '';
    final totalItems = kitProduct?.items.length ?? 0;
    final kitQty = order.items.first.quantity ?? 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "KIT" badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.button.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'KIT',
                  style: text10(
                    color: AppColors.button,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                kitName,
                style: text24(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text('Quantity: $kitQty', style: text14(color: AppColors.grey)),
              Text(
                '$totalItems items in this kit',
                style: text12(color: AppColors.grey600),
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
        kitImage.isEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.orange.shade50,
                  child: Image.asset("assets/icon/plate.png"),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.orange.shade50,
                  child: CustomCachedImage(imageUrl: kitImage),
                ),
              ),
      ],
    );
  }

  Widget _buildItemHeader(List<ProductDisplayItem> displayItems) {
    if (displayItems.isEmpty) return const SizedBox.shrink();
    final mainItem = displayItems.first;

    return Row(
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
            child: CustomCachedImage(imageUrl: mainItem.emoji),
          ),
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceState = ref.watch(invoiceProvider);
    final displayItems = _getDisplayItems();
    final isKit = _isKit();
    final statusColor = OrderUtils.getStatusColor(
      order.tracking?.currentStatus ?? order.orderStatus,
    );
    final statusText = OrderUtils.getStatusText(
      order.tracking?.currentStatus ?? order.orderStatus,
    );
    final isDelivered = (order.orderStatus ?? '').toLowerCase() == 'delivered';

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
                // ── Header ──────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(color: statusColor, text: statusText),
                    Text(
                      'Placed on ${OrderUtils.formatDateShort(order.createdAt)}',
                      style: text12(color: AppColors.grey600),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Main product / Kit header ─────────────────────────────
                isKit ? _buildKitHeader() : _buildItemHeader(displayItems),
                const SizedBox(height: 8),
                _InvoiceButton(
                  orderId: order.id ?? '',
                  invoiceState: invoiceState,
                ),
                const SizedBox(height: 12),

                _divider(),

                // ── Items Ordered ────────────────────────────────────────────
                Text(
                  isKit ? 'Kit Contains' : 'Items Ordered',
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomCachedImage(imageUrl: item.emoji),
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
                                'Qty: ${item.quantity}',
                                style: text12(color: AppColors.grey600),
                              ),
                            ],
                          ),
                        ),
                        // Rate button (delivered) OR price
                        if (isDelivered)
                          GestureDetector(
                            onTap: () => _showRatingSheet(context, ref, item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.button),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.button,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Rate',
                                    style: text12(color: AppColors.button),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Text(
                            OrderUtils.formatCurrency(item.price),
                            style: text14(fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _divider(),

                // ── Order Information ────────────────────────────────────────
                Text(
                  'Order Information',
                  style: text16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Order ID:', (order.razorpayOrderId)),
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

                _divider(),

                // ── Order Summary ────────────────────────────────────────────
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

                _divider(),

                // ── Delivery Address ─────────────────────────────────────────
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
                    '${order.address!.city ?? ''}, '
                    '${order.address!.state ?? ''} - '
                    '${order.address!.pincode ?? ''}',
                    style: text14(),
                  ),
                ] else
                  Text(
                    'Address not available',
                    style: text14(color: AppColors.grey600),
                  ),
                const SizedBox(height: 32),

                // ── Track Order button ───────────────────────────────────────
                if (order.tracking != null &&
                    order.tracking!.currentStatus != 'delivered' &&
                    !(order.tracking!.isCancelled ?? false))
                  Center(
                    child: CustomElevatedIconButton(
                      text: 'Track Order',
                      icon: Icons.location_on,
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.trackOrder,
                        arguments: order.id,
                      ),
                    ),
                  ),

                // ── Rate Your Order button (delivered only) ──────────────────
                if (isDelivered) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.button),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(
                        Icons.star_rounded,
                        color: AppColors.button,
                        size: 20,
                      ),
                      label: Text(
                        'Rate Your Order',
                        style: text14(color: AppColors.button),
                      ),
                      onPressed: () => displayItems.isNotEmpty
                          ? _showRatingSheet(context, ref, displayItems[0])
                          : null,
                    ),
                  ),
                ],

                const SizedBox(height: 24),
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

  Widget _divider() => Column(
    children: [
      Divider(color: Colors.grey.shade300, height: 1),
      const SizedBox(height: 24),
    ],
  );

  Widget _buildInfoRow(String label, String? value) => Padding(
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

// ---------------------------------------------------------------------------
// Rating Bottom Sheet
// ---------------------------------------------------------------------------

class RatingBottomSheet extends ConsumerStatefulWidget {
  final String orderId;
  final ProductDisplayItem item;

  const RatingBottomSheet({
    super.key,
    required this.orderId,
    required this.item,
  });

  @override
  ConsumerState<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends ConsumerState<RatingBottomSheet> {
  final TextEditingController _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }

  Future<void> _submit() async {
    final selectedRating = ref.read(selectedRatingProvider);

    debugPrint('⭐ SUBMIT CLICKED -> selected rating: $selectedRating');

    if (selectedRating == 0) {
      debugPrint('❌ No rating selected');
      return;
    }

    final notifier = ref.read(ratingOrderProvider.notifier);

    debugPrint(
      '🚀 Sending API request -> productId: ${widget.item.productId}, rating: $selectedRating, review: ${_reviewController.text.trim()}',
    );

    final success = await notifier.postRating(
      widget.item.productId,
      selectedRating,
      _reviewController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      debugPrint('✅ Rating submitted successfully');

      ref.read(selectedRatingProvider.notifier).state = 0;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your rating! 🙏'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      debugPrint('❌ Rating submission failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratingAsync = ref.watch(ratingOrderProvider);
    final selectedRating = ref.watch(selectedRatingProvider);

    final isLoading = ratingAsync is AsyncLoading;
    final hasError = ratingAsync is AsyncError;
    final errorMessage = hasError
        ? (ratingAsync as AsyncError).error.toString()
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Rate this Product',
              style: text18(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              widget.item.name,
              style: text14(color: AppColors.grey600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomCachedImage(imageUrl: widget.item.emoji),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final filled = starValue <= selectedRating;

                return GestureDetector(
                  onTap: () {
                    debugPrint('⭐ User selected star: $starValue');

                    ref.read(selectedRatingProvider.notifier).state = starValue;
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      key: ValueKey('$starValue-$filled'),
                      size: 44,
                      color: filled
                          ? const Color(0xFFFFA000)
                          : Colors.grey.shade300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            Text(
              _starLabel(selectedRating),
              style: text14(
                color: selectedRating > 0
                    ? AppColors.button
                    : AppColors.grey600,
                fontWeight: selectedRating > 0
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _reviewController,
              maxLines: 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)...',
                hintStyle: text14(color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.button),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 8),

            if (hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  errorMessage ?? 'Something went wrong',
                  style: text12(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedRating > 0
                      ? AppColors.button
                      : Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: selectedRating == 0 || isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Rating',
                        style: text16(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String text;

  const _StatusBadge({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            'Status: $text',
            style: text10(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _InvoiceButton extends ConsumerWidget {
  final String orderId;
  final InvoiceState invoiceState;

  const _InvoiceButton({required this.orderId, required this.invoiceState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDownloading = invoiceState.status == InvoiceStatus.downloading;
    final isError = invoiceState.status == InvoiceStatus.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: isDownloading
              ? null
              : () =>
                    ref.read(invoiceProvider.notifier).downloadAndOpen(orderId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 48,
            decoration: BoxDecoration(
              color: isError
                  ? Colors.red.shade50
                  : AppColors.button.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isError
                    ? Colors.red.shade300
                    : AppColors.button.withOpacity(0.4),
              ),
            ),
            child: isDownloading
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Progress fill
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 150),
                          widthFactor: invoiceState.progress,
                          child: Container(
                            color: AppColors.button.withOpacity(0.15),
                          ),
                        ),
                        // Text + spinner
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  value: invoiceState.progress > 0
                                      ? invoiceState.progress
                                      : null,
                                  strokeWidth: 2,
                                  color: AppColors.button,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                invoiceState.progress > 0
                                    ? 'Downloading ${(invoiceState.progress * 100).toInt()}%'
                                    : 'Preparing...',
                                style: text13(
                                  color: AppColors.button,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isError
                            ? Icons.error_outline
                            : Icons.picture_as_pdf_rounded,
                        size: 18,
                        color: isError ? Colors.red : AppColors.button,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isError
                            ? 'Failed — Tap to Retry'
                            : 'View & Download Invoice',
                        style: text14(
                          color: isError ? Colors.red : AppColors.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (isError && invoiceState.errorMsg != null) ...[
          const SizedBox(height: 6),
          Text(
            invoiceState.errorMsg!,
            style: text11(color: Colors.red.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class ProductDisplayItem {
  final String name;
  final String emoji;
  final num quantity;
  final num price;
  final String productId; // needed for rating submission

  ProductDisplayItem({
    required this.name,
    required this.emoji,
    required this.quantity,
    required this.price,
    required this.productId,
  });
}
