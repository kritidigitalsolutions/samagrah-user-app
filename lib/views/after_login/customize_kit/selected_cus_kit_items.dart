import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/global_widgets/product_details_bottom_sheet.dart';

class SelectedCusKitItems extends ConsumerStatefulWidget {
  const SelectedCusKitItems({super.key});

  @override
  ConsumerState<SelectedCusKitItems> createState() =>
      _SelectedCusKitItemsState();
}

class _SelectedCusKitItemsState extends ConsumerState<SelectedCusKitItems> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    final kitName = ref.watch(kitNameProvider);
    final cartNotifier = ref.read(customizeKitCartProvider.notifier);
    final cart = ref.watch(
      customizeKitCartProvider,
    ); // Map<String, int> = {productId: quantity}
    final productState = ref.watch(
      productProvider,
    ); // To get full product details

    // Get full product list from previous page state
    final allProducts = productState.value?.customizeKitItems ?? [];

    // Convert cart map into list of products with quantity
    final selectedCartItems = allProducts
        .where((product) => cart.containsKey(product.id))
        .map((product) => {'product': product, 'quantity': cart[product.id]!})
        .toList();

    final totalItems = cart.values.fold(0, (sum, qty) => sum + qty);
    final totalAmount = selectedCartItems.fold(0, (sum, item) {
      final product = item['product'] as Product;
      final qty = item['quantity'] as int;
      return sum + (product.price! * qty);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: kitName,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset("assets/icon/plate.png", width: 70, height: 70),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: selectedCartItems.isEmpty
                  ? const Center(
                      child: Text(
                        "No items added yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(15),
                      itemCount: selectedCartItems.length,
                      itemBuilder: (context, index) {
                        final item = selectedCartItems[index];
                        final product = item['product'] as Product;
                        final quantity = item['quantity'] as int;

                        return _buildCartItem(
                          product: product,
                          quantity: quantity,
                          index: index,
                          cartNotifier: cartNotifier,
                        );
                      },
                    ),
            ),

            // Bottom Summary Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withAlpha(50),
                    offset: const Offset(0, -3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "Your Kit",
                        style: text15(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "$totalItems items added",
                        style: text13(),
                      ),
                      trailing: Text(
                        "₹ $totalAmount",
                        style: text18(color: AppColors.button),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  CustomElevatedIconButton(
                    text: "add more item",
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.pop(context); // Go back to CustomizeItemsPage
                    },
                  ),
                ],
              ),
            ),

            // Place Order Button
            Container(
              color: AppColors.button,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: AppButton(
                title: _isLoading ? "Creating Kit..." : "Place your order",
                isLoading: _isLoading, // Add loading support in your AppButton
                onTap: _isLoading
                    ? null
                    : () => _placeOrder(context, selectedCartItems, kitName),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(
    BuildContext context,
    List<Map<String, dynamic>> selectedCartItems,
    String kitName,
  ) async {
    if (selectedCartItems.isEmpty) {
      AppSnackbar.show(
        context,
        message: "Please add items to your kit",
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create KitItem list from cart
      final List<KitItem> kitItems = selectedCartItems.map((item) {
        final product = item['product'] as Product;
        final quantity = item['quantity'] as int;
        return KitItem(productId: product.id ?? '', quantity: quantity);
      }).toList();

      // Create request model
      final request = CreateKitRequest(
        name: kitName,
        baseKit: null, // Change if you have base kit
        items: kitItems,
      );

      // Call the API method
      final createdKit = await ref
          .read(userDraftKits.notifier)
          .createDraftKit(request);
      // Success
      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Kit created successfully!",
          type: SnackBarType.success,
        );

        final notifier = ref.read(customizeKitProvider.notifier);

        // ✅ initialize kit before navigation
        notifier.initializeFromUser(createdKit!);

        // Navigate to order summary or success page
        Navigator.pushNamed(
          context,
          AppRoutes.kitOrderSummary,
          arguments: createdKit,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: "Failed to create kit: ${e.toString()}",
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Updated Cart Item UI - Same style as you had
  Widget _buildCartItem({
    required Product product,
    required int quantity,
    required int index,
    required CustomizeKitCartNotifier cartNotifier,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Product Image
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(product.thumbnail ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title ?? 'Unknown Product',
                      style: text15(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.category ??
                          '', // Add subtitle in model if available
                      style: text12(color: AppColors.grey500),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        openProductBottomSheet(context, product.id ?? '');
                      },
                      child: Text(
                        'View Product',
                        style: text12(
                          color: AppColors.button,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Quantity & Price Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Quantity Controls
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              cartNotifier.removeItem(product.id ?? ''),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                          ),
                          child: Text(
                            quantity.toString(),
                            style: text14(
                              fontWeight: FontWeight.w600,
                              color: AppColors.button,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => cartNotifier.addItem(product),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹ ${product.oldPrice}',
                        style: text11(
                          color: AppColors.grey500,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 4),
                      Text('|', style: text11(color: AppColors.grey)),
                      const SizedBox(width: 4),
                      Text(
                        '₹${product.price}',
                        style: text14(
                          fontWeight: FontWeight.bold,
                          color: AppColors.button,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Remove Item Button (Top Right)
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              cartNotifier.removeItem(
                product.id ?? '',
              ); // This will remove completely if qty becomes 0
            },
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.button.withAlpha(20),
              child: Icon(Icons.remove, size: 18, color: AppColors.button),
            ),
          ),
        ),
      ],
    );
  }
}

void openProductBottomSheet(BuildContext context, String productId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ProductDetailsBottomSheet(productId: productId),
  );
}
