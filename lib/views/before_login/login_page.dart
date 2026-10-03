import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/utils/auth_guard.dart';
import 'package:samagrah/view_model/before_login_provider/auth_provider.dart';
import 'package:samagrah/view_model/before_login_provider/profile_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _mobileCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  static const String _privacyPolicyUrl =
      'https://www.samagran.com/privacy-policy.html';
  static const String _termsUrl =
      'https://www.samagran.com/terms-and-conditions.html';

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl(_termsUrl);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openLegalUrl(_privacyPolicyUrl);
  }

  Future<void> _openLegalUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppBrowserView)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (previous == next) return;

      next.whenOrNull(
        data: (data) {
          final register = data.registerModel;

          if (register == null) return;

          // ← Only react to login response, not OTP verify response
          if (data.verifyModel != null) return; // ← ADD THIS

          final isNewUser = register.isNewUser;

          if (isNewUser == true) {
            AppSnackbar.show(
              context,
              message: "This number is not registered. Please sign up first.",
              type: SnackBarType.warning,
            );
          } else {
            AppSnackbar.show(
              context,
              message: "OTP Sent Successfully",
              type: SnackBarType.success,
            );
            Navigator.pushNamed(context, AppRoutes.otp);
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(color: AppColors.white),
        child: Stack(
          children: [
            // 🔥 Background Images (behind everything)
            Positioned(
              top: -180,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset(
                  "assets/auth/rangoli.png",
                  color: AppColors.grey200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Positioned(
              bottom: -180,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Image.asset(
                  "assets/auth/rangoli.png",
                  color: AppColors.grey200,
                  fit: BoxFit.cover,
                ),
              ),
            ),



            // ✅ Main Content
            SafeArea(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        'Log In',
                        textAlign: TextAlign.center,
                        style: text26(),
                      ),
                      const SizedBox(height: 28),

                      NumberTextField(
                        controller: _mobileCtrl,
                        hintText: 'Mobile Number',
                        maxLength: 10,
                      ),
                      const SizedBox(height: 20),
                      _buildContinueButton(),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: text14(color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 4),
                          CustomTextButton(
                            title: "Sign up",
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => AuthGuard.continueAsGuest(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.button,
                            width: 1.5,
                          ),
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Continue as Guest",
                              style: text14(
                                color: AppColors.button,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.button,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text.rich(
                          TextSpan(
                            text: "By continuing, you agree to our\n",
                            style: text12(color: AppColors.grey700),
                            children: [
                              TextSpan(
                                text: "Terms & Conditions",
                                style: text12(
                                  color: AppColors.button,
                                  fontWeight: FontWeight.w600,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _termsRecognizer,
                              ),
                              TextSpan(
                                text: " and ",
                                style: text12(color: AppColors.grey700),
                              ),
                              TextSpan(
                                text: "Privacy Policy",
                                style: text12(
                                  color: AppColors.button,
                                  fontWeight: FontWeight.w600,
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: _privacyRecognizer,
                              ),
                              TextSpan(
                                text: ".",
                                style: text12(color: AppColors.grey700),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Apple 5.1.1(v): Top Header Controls (Rendered on top of form) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        )
                      else
                        const SizedBox.shrink(),

                      // Skip / Guest button
                      TextButton(
                        onPressed: () => AuthGuard.continueAsGuest(context),
                        child: Text(
                          "Skip",
                          style: text14(
                            color: AppColors.button,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);

        return SizedBox(
          width: 160,
          height: 44,
          child: AppButton(
            title: 'Continue',
            isLoading: authState.isLoading,
            onTap: authState.isLoading
                ? null // 👈 loading ke dauraan tap hi disable
                : () {
                    if (!_formKey.currentState!.validate()) return;
                    ref.read(phoneProvider.notifier).state = _mobileCtrl.text;
                    ref
                        .read(authProvider.notifier)
                        .login(mobile: _mobileCtrl.text.trim());
                  },
          ),
        );
      },
    );
  }
}

// ── Profile Image Picker ──────────────────────────

class ProfileImagePicker extends ConsumerWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final File? imageFile = ref.watch(profileImageProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 👤 Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.grey300,
            border: Border.all(color: AppColors.button, width: 1),
          ),
          child: imageFile != null
              ? ClipOval(child: Image.file(imageFile, fit: BoxFit.cover))
              : const Icon(
                  Icons.person_rounded,
                  size: 44,
                  color: Color(0xFF9A8A8A),
                ),
        ),

        // ✏️ Edit Button
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: () =>
                ProfileImageController.showImagePickerOptions(context, ref),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.button,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 13,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
