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

class OnlineBookingDetails extends ConsumerStatefulWidget {
  const OnlineBookingDetails({super.key});

  @override
  ConsumerState<OnlineBookingDetails> createState() =>
      _OnlineBookingDetailsState();
}

class _OnlineBookingDetailsState extends ConsumerState<OnlineBookingDetails> {
  final TextEditingController nameCtr = TextEditingController();
  final TextEditingController phoneCtr = TextEditingController();
  final TextEditingController otherPhoneCtr = TextEditingController();
  final TextEditingController emailCtr = TextEditingController();

  @override
  void dispose() {
    nameCtr.dispose();
    phoneCtr.dispose();
    otherPhoneCtr.dispose();
    emailCtr.dispose();
    super.dispose();
  }

  void _handleNext() {
    FocusScope.of(context).unfocus();

    final String name = nameCtr.text.trim();
    final String phone = phoneCtr.text.trim();
    final String secondPhone = otherPhoneCtr.text.trim();
    final String email = emailCtr.text.trim();

    if (name.isEmpty) {
      AppSnackbar.show(context, message: "Please enter your full name");
      return;
    }

    if (phone.isEmpty) {
      AppSnackbar.show(context, message: "Please enter your phone number");
      return;
    }

    final OnlineDetails details = OnlineDetails(
      name: name,
      phone: phone,
      secPhone: secondPhone.isEmpty ? null : secondPhone,
      email: email.isEmpty ? null : email,
    );

    ref.read(selectedOnlineProvider.notifier).state = details;

    Navigator.pushNamed(context, AppRoutes.bookingSummary);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final double safeBottom = mediaQuery.padding.bottom;

    final bool isKeyboardOpen = keyboardHeight > 0;

    // Fixed button area height
    const double buttonAreaHeight = 92;

    return Scaffold(
      // Keyboard khulne par Scaffold ko resize nahi karenge.
      resizeToAvoidBottomInset: false,
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
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return Container(
                      width: 70,
                      height: 70,
                      color: AppColors.grey500,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image),
                    );
                  },
            ),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            // Scrollable form
            Positioned.fill(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,

                  // Button aur keyboard ke liye bottom space
                  buttonAreaHeight +
                      keyboardHeight +
                      (isKeyboardOpen ? 24 : safeBottom),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress section
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Online Puja Details",
                                  style: text16(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Enter details for your online Puja session",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: text12(color: AppColors.grey600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
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

                    const SizedBox(height: 20),

                    Text(
                      "Online Puja Details",
                      style: text18(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      radius: 8,
                      controller: nameCtr,
                      hintText: "Enter Full Name",
                    ),

                    const SizedBox(height: 12),

                    AppTextField(
                      radius: 8,
                      controller: phoneCtr,
                      hintText: "Phone Number",
                    ),

                    const SizedBox(height: 12),

                    AppTextField(
                      radius: 8,
                      controller: otherPhoneCtr,
                      hintText: "Second Phone Number (Optional)",
                    ),

                    const SizedBox(height: 12),

                    AppTextField(
                      radius: 8,
                      controller: emailCtr,
                      hintText: "Email (Optional)",
                    ),

                    // Last TextField aur button ke beech space
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Fixed bottom button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: 0,
              right: 0,

              // Keyboard open hone par button keyboard ke upar jayega
              bottom: keyboardHeight,

              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  isKeyboardOpen ? 12 : 12 + safeBottom,
                ),
                decoration: BoxDecoration(
                  color: AppColors.button,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: AppButton(title: "Next", onTap: _handleNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
