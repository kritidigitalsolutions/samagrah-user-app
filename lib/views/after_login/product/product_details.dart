import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 Back + Image Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffe9e4dc),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Icon(Icons.keyboard_arrow_left),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/icon/diya2.png',
                          fit: BoxFit.cover,
                          height: 150,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🛒 Product Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Title + Add button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "Handmade Clay Diya for Pooja & Festivals",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            AppButton(title: "Add", height: 30, onTap: () {}),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Price
                        const Text(
                          "₹249/-",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Row(
                          children: const [
                            Text(
                              "MRP ₹399",
                              style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "38% OFF",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        /// Buy Now
                        AppButton(
                          title: "Buy Now",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.orderSummary,
                            );
                          },
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// 🎁 Offer Banner
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff5c1f2e),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Get ₹50 OFF",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Add items worth ₹399 more",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(
                          "assets/icon/plate.png",
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 👍 Suggested
                  const Text(
                    "You might also like",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  /// Horizontal List
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(
                                    'assets/icon/kalash.png',
                                    fit: BoxFit.cover,
                                    height: 70,
                                  ),
                                  const SizedBox(height: 5),
                                  const Text("Kalash"),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "₹80/-",
                                            style: text13(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),

                                        AppButton(
                                          height: 25,
                                          title: "Add",
                                          onTap: () {},
                                          textStyle: text12(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 10,
                              child: Icon(
                                Icons.favorite_border_outlined,
                                size: 20,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            /// 🛍 Floating Cart Button
            // Positioned(
            //   bottom: 20,
            //   left: 60,
            //   right: 60,
            //   child: Container(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 12,
            //     ),
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       borderRadius: BorderRadius.circular(40),
            //       boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: const [
            //         Icon(Icons.shopping_cart, color: Colors.red),
            //         SizedBox(width: 8),
            //         Text("View Cart"),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
