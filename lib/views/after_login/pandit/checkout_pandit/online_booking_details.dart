import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // 🔵 Step Circle (Gradient + Shadow)
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      "3",
                      style: text14(
                        color: AppColors.white,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 📝 Title + Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Online Pooja Details",
                          style: text16(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Enter details for your online pooja session",
                          style: text12(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),

                  // 📊 Step Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Text(
                      "3 / 3",
                      style: text12(
                        color: AppColors.warningDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Select Address Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Online Pooja Details',
                    style: text18(fontWeight: FontWeight.bold),
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
}
