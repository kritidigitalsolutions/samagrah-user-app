import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  List<CartItem> cartItems = [
    CartItem('Clay Diyas', 'Pack of 100', 2, 100, 79),
    CartItem('Clay Diyas', 'Pack of 100', 2, 100, 79),
    CartItem('Clay Diyas', 'Pack of 100', 2, 100, 79),
    CartItem('Clay Diyas', 'Pack of 100', 2, 100, 79),
    CartItem('Clay Diyas', 'Pack of 100', 2, 100, 79),
  ];

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    return _buildCartItem(cartItems[index], index);
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
                                const Text(
                                  'Get 5% Off on your first',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'pooja package order',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
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
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                    ),

                    // Second Offer
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
                              Icons.delivery_dining,
                              color: Color(0xFFE91E63),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Free Delivery on Puja Essentials',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'On orders above ₹499',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
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
                          Navigator.pushNamed(context, AppRoutes.orderSummary);
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

  Widget _buildCartItem(CartItem item, int index) {
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
                    image: AssetImage("assets/icon/kalash.png"),
                    fit: BoxFit.contain,
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
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.packSize,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.productDetails);
                      },
                      child: const Text(
                        'View Product',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFE91E63),
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
                      color: const Color(0xFFE91E63),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => decrementQuantity(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE91E63),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => incrementQuantity(index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
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
                        '₹ ${item.originalPrice}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: const Text(
                          '|',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹${item.discountedPrice}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE91E63),
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
      ],
    );
  }
}

class CartItem {
  String name;
  String packSize;
  int quantity;
  int originalPrice;
  int discountedPrice;

  CartItem(
    this.name,
    this.packSize,
    this.quantity,
    this.originalPrice,
    this.discountedPrice,
  );
}
