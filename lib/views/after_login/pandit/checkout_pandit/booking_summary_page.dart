import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerCard,
      appBar: CustomAppBar(
        title: "Booking Summary",

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/panditLogo.png',
              width: 70,
              height: 70,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.grey500,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Confirm Booking Section
                const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Pandit Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.orange.shade100,
                          child: const Icon(
                            Icons.temple_hindu,
                            color: Colors.orange,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Griha Pravesh',
                              style: text16(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Date: 20 March 2025',
                              style: text12(color: AppColors.grey),
                            ),
                            Text(
                              'Time: 10:00 AM - 12:00 PM',
                              style: text12(color: AppColors.grey),
                            ),
                            Text(
                              '2A/10 Shastri Nagar, Varanasi',
                              style: text12(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Pandit Dakshina Section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.button,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pandit Dakshina',
                        style: text16(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Calculeted rate is as per pandit advice and your satisfaction and happiness.',
                        style: text12(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Booking Process
                Text(
                  'Booking Process',
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildProcessStep(
                  '1',
                  'After your order, receipt copy will be sent to your email.',
                  true,
                ),
                _buildProcessStep(
                  '2',
                  'Pandit Ji will review and accept your booking request.',
                  true,
                ),
                _buildProcessStep(
                  '3',
                  'You will receive confirmation shortly.',
                  true,
                ),
                const SizedBox(height: 24),
                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: text18(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹61',
                      style: text20(
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Payment Methods
                Row(
                  children: [
                    Image.asset(
                      'assets/gPay.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.payment, size: 24);
                      },
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/paytm.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.account_balance_wallet,
                          size: 24,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/phonePe.png',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.payment, size: 24);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Pay Button
                AppButton(
                  title: 'Pay ₹61 & Request Booking',
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.panditPayment);
                  },
                  color: AppColors.success,
                  textStyle: text15(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Pooja fee can be transferred offline after booking\nconfirmation and transaction.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(String number, String text, bool hasCheck) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            hasCheck ? Icons.check_circle : Icons.circle_outlined,
            color: const Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
