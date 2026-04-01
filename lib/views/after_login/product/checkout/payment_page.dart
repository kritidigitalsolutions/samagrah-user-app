import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

// ====================== PAYMENT METHOD SCREEN ======================

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isCashOnDelivery = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStep(1, 'Item\nSummary', true),
                  _buildStepConnector(true),
                  _buildStep(2, 'Delivery\nAddress', true),
                  _buildStepConnector(true),
                  _buildStep(3, 'Payment\nMethod', true),
                ],
              ),

              const SizedBox(height: 32),

              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Total Amount Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.button),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Amount: ₹261',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Image.asset(
                          'assets/gPay.png',
                          height: 24,
                        ), // Replace with your assets
                        const SizedBox(width: 12),
                        Image.asset('assets/paytm.png', height: 24),
                        const SizedBox(width: 12),
                        Image.asset('assets/phonePe.png', height: 24),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      height: 45,
                      title: 'Pay ₹261 & place order',
                      color: AppColors.success,
                      textStyle: text15(color: AppColors.white),
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.paymentPage);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cash on Delivery Option
              GestureDetector(
                onTap: () {
                  setState(() {
                    isCashOnDelivery = !isCashOnDelivery;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCashOnDelivery ? Colors.pink[50] : Colors.white,
                    border: Border.all(
                      color: isCashOnDelivery
                          ? const Color(0xFFE91E63)
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text('💵', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Cash on Delivery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isCashOnDelivery)
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFE91E63),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Place Order Button
              Center(
                child: SizedBox(
                  width: 120,

                  child: AppButton(
                    height: 40,
                    title: "Place Order",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.successPage);
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

  Widget _buildStep(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[700],
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

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFE91E63) : Colors.grey[300],
        margin: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
