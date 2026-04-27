import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

// Screen 1: Address Selection Screen
class OnlineBookingDetails extends ConsumerStatefulWidget {
  const OnlineBookingDetails({super.key});

  @override
  ConsumerState<OnlineBookingDetails> createState() =>
      _OnlineBookingDetailsState();
}

class _OnlineBookingDetailsState extends ConsumerState<OnlineBookingDetails> {
  final nameCtr = TextEditingController();
  final phoneCtr = TextEditingController();
  final otherPhoneCtr = TextEditingController();
  final emailCtr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Book your Pandit",

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
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            decoration: BoxDecoration(color: AppColors.headerCard),
            child: _buildCustomStepper(),
          ),
          const SizedBox(height: 24),
          // Select Address Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Online Pooja Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  AppTextField(
                    radius: 8,
                    controller: nameCtr,
                    hintText: "Enter Full Name",
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    radius: 8,
                    controller: phoneCtr,
                    hintText: "Phone Number",
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    radius: 8,
                    controller: otherPhoneCtr,
                    hintText: "Second Phone Number (Optional)",
                  ),
                  const SizedBox(height: 10),
                  AppTextField(
                    radius: 8,
                    controller: emailCtr,
                    hintText: "Email (Optional)",
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.button),
              child: AppButton(
                title: "Next",
                onTap: () {
                  // ✅ Basic validation
                  if (nameCtr.text.trim().isEmpty ||
                      phoneCtr.text.trim().isEmpty) {
                    AppSnackbar.show(context, message: "Please field details");
                    return;
                  }

                  // ✅ Create model
                  final details = OnlineDetails(
                    name: nameCtr.text.trim(),
                    phone: phoneCtr.text.trim(),
                    secPhone: otherPhoneCtr.text.trim().isEmpty
                        ? null
                        : otherPhoneCtr.text.trim(),
                    email: emailCtr.text.trim().isEmpty
                        ? null
                        : emailCtr.text.trim(),
                  );

                  // ✅ Save to provider
                  ref.read(selectedOnlineProvider.notifier).state = details;

                  // ✅ Navigate
                  Navigator.pushNamed(context, AppRoutes.bookingSummary);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Column(
      children: [
        const SizedBox(height: 8),

        /// 🔴 DOT + LINE ROW
        Row(
          children: [
            buildCircle("1", true),
            buildDottedLine(),
            buildCircle("2", true),
            buildDottedLine(),
            buildCircle("3", true),
          ],
        ),
        const SizedBox(height: 8),

        bottomLable(),
      ],
    );
  }
}
