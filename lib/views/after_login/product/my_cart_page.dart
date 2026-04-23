import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';

class MyCartPage extends ConsumerStatefulWidget {
  const MyCartPage({super.key});

  @override
  ConsumerState<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends ConsumerState<MyCartPage> {
  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final itemTotal = ref.watch(totalPriceProvider);
    const deliveryFee = 20;
    final totalAmount = itemTotal + deliveryFee;
    return Scaffold(
      backgroundColor: AppColors.headerCard,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(color: AppColors.background),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
                decoration: BoxDecoration(color: AppColors.headerCard),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/nav/cart.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                      errorBuilder: (context, exception, stackTrace) {
                        return Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(color: AppColors.grey500),
                          child: Center(child: Icon(Icons.image)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: cartItems.items.isEmpty
                    ? const Center(child: Text("Your cart is empty"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: cartItems.items.length,
                        itemBuilder: (context, index) {
                          return _buildCartItem(cartItems.items[index], ref);
                        },
                      ),
              ),

              // Promotional Offers
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withAlpha(50),
                      offset: Offset(0, -3), // 🔥 negative = top shadow
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // First Offer
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_offer,
                              color: Color(0xFFE91E63),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Get 5% Off on your first',
                                  style: text11(
                                    color: AppColors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'pooja package order',
                                  style: text10(color: AppColors.grey600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.grey200,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // Second Offer
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.button.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delivery_dining,
                              color: AppColors.button,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Free Delivery on Puja Essentials',
                                  style: text11(
                                    color: AppColors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'On orders above ₹499',
                                  style: text10(color: AppColors.grey600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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
                  ],
                ),
              ),

              // Add More Items Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomElevatedIconButton(
                        text: "Add more items",
                        icon: Icons.add_shopping_cart_outlined,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.comparisionPage,
                          );
                        },
                        iconSize: 18,
                        textStyle: text13(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AppButton(
                        title: "Place Order",
                        onTap: () {
                          final orderItems = cartItems.items.map((item) {
                            return OrderItem(
                              productId: item.productId,
                              title: item.title,
                              price: item.price.toInt(), // 👈 double → int
                              quantity: item.quantity,
                              image: item.thumbnail,
                            );
                          }).toList();

                          Navigator.pushNamed(
                            context,
                            AppRoutes.orderSummary,
                            arguments: orderItems,
                          );
                        },

                        textStyle: text13(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildCartItem(CartItem item, WidgetRef ref) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomCachedImage(
                  width: 75,
                  height: 75,
                  imageUrl: "http://192.168.1.40:8000/${item.thumbnail}",
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 12),

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: text15(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black87,
                      ),
                    ),
                    // const SizedBox(height: 3),
                    // Text(
                    //   item.packSize,
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     color: Colors.grey.shade500,
                    //   ),
                    // ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.productDetails);
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

              // Right Side - Quantity & Price
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
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .decreaseQuantity(item.productId),
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
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.button,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref
                              .read(cartProvider.notifier)
                              .increaseQuantity(item.productId),
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
                      // Text(
                      //   '₹ ${item.}',
                      //   style: text11(
                      //     color: AppColors.grey500,
                      //   ).copyWith(decoration: TextDecoration.lineThrough),
                      // ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Text('|', style: text11(color: AppColors.grey)),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${item.price}',
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
        Positioned(
          top: 5,
          right: 5,
          child: GestureDetector(
            onTap: () {
              ref.read(cartProvider.notifier).deleteCart(item.productId);
            },
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.button.withAlpha(20),
              child: Icon(
                Icons.delete_outline,
                size: 20,
                color: AppColors.button,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
