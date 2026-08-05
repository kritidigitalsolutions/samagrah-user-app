import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
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

  @override
  void dispose() {
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      print(
        "🔴 LISTENER FIRED => next: ${next.value?.registerModel?.isNewUser}",
      );
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
                          Text("Don't have an account?"),
                          SizedBox(width: 2),
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
            onTap: () => ProfileImageController.pickImage(ref),
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
