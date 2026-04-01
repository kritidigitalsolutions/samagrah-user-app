import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({super.key});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  int quantity = 2;

  @override
  Widget build(BuildContext context) {
    const double itemPrice = 220.0;
    final double itemTotal = itemPrice * quantity;
    const double deliveryFee = 20.0;
    final double totalAmount = itemTotal + deliveryFee;

    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: AppBar(
      //   title: const Text('Checkout'),
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Item\nSummary', true),
                  _buildStepConnector(isActive: true),
                  _buildStep(2, 'Delivery\nAddress', false),
                  _buildStepConnector(isActive: false),
                  _buildStep(3, 'Payment\nMethod', false),
                ],
              ),

              const SizedBox(height: 32),

              // Item Summary Card
              Text('Item Summary', style: text18(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Product Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text('🪔', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Clay Diyas',
                              style: text16(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Quantity: 2',
                              style: text13(color: AppColors.grey400),
                            ),
                            Text(
                              'Price: ₹220 each',
                              style: text13(color: AppColors.grey400),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Stepper
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: quantity > 1
                                  ? () => setState(() => quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                            Text(
                              quantity.toString(),
                              style: text15(fontWeight: FontWeight.w600),
                            ),
                            IconButton(
                              onPressed: () => setState(() => quantity++),
                              icon: const Icon(Icons.add),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 36),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Order Summary
              Text('Order Summary', style: text18(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow(
                        'Item Total',
                        '₹${itemTotal.toStringAsFixed(0)}',
                      ),
                      _buildSummaryRow(
                        'Delivery Fee',
                        '₹${deliveryFee.toStringAsFixed(0)}',
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Total Amount',
                        '₹${totalAmount.toStringAsFixed(0)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              //
              //Next Button
              Center(
                child: SizedBox(
                  width: 100,

                  child: AppButton(
                    height: 40,
                    title: "Next",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.addressPage);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.button : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              stepNumber.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.button : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal ? AppColors.button : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
