import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                          border: Border.all(color: AppColors.button),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Status: Out for Delivery',
                          style: text10(
                            color: AppColors.button,

                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'Placed on 12 Nov 2026',
                        style: text12(color: AppColors.grey600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Product name and image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clay Diyas',
                              style: text24(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '(Pack of 10)',
                              style: text14(color: AppColors.grey),
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
                                '₹79',
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
                          child: const Center(
                            child: Text('🪔', style: TextStyle(fontSize: 40)),
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
                  Text('Clay Diyas (Pack of 10)', style: text14()),
                  const SizedBox(height: 4),
                  Text('Quantity: 1', style: text14()),
                  const SizedBox(height: 4),
                  Text('Price: ₹79', style: text14()),
                  const SizedBox(height: 24),

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
                  const Text(
                    'Order ID: PO1025',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Order Date: 12 Nov 2026',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Payment Method: Online Payment',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 24),

                  // Order Summary
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.button,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Subtotal: ₹79',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Delivery Fee: ₹20',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Amount: ₹99',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Divider(color: Colors.grey.shade300, height: 1),
                  const SizedBox(height: 24),

                  // Delivery Address
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.button,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'B-245, Shastri Nagar',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Meerut, Uttar Pradesh - 250004',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                  const SizedBox(height: 32),

                  // Track Order Button
                  Center(
                    child: CustomElevatedIconButton(
                      text: "Track Order",
                      icon: Icons.location_on,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.trackOrder);
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
      ),
    );
  }
}
