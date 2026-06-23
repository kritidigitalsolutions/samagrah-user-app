import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/request/auth_models/user_request_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/before_login_provider/auth_provider.dart';
import 'package:samagrah/view_model/before_login_provider/profile_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
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
          if (data.verifyModel != null) return;

          final isNewUser = register.isNewUser;

          if (isNewUser == true) {
            AppSnackbar.show(
              context,
              message: "OTP Sent Successfully",
              type: SnackBarType.success,
            );
            Navigator.pushNamed(context, AppRoutes.otp);
          } else {
            // ✅ Server ka exact message use karo
            final msg = register.message?.isNotEmpty == true
                ? register.message!
                : "This number is already registered. Please login.";
            AppSnackbar.show(context, message: msg, type: SnackBarType.error);
          }
        },
        error: (e, _) {
          String message = "Something went wrong";

          if (e.toString().contains("message")) {
            final match = RegExp(
              r'message:\s*([^,}]+)',
            ).firstMatch(e.toString());
            if (match != null) {
              message = match.group(1)?.trim() ?? message;
            }
          }

          AppSnackbar.show(context, message: message, type: SnackBarType.error);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 48),
                      Text(
                        'Set up\nyour profile',
                        textAlign: TextAlign.center,
                        style: text26(),
                      ),
                      const SizedBox(height: 28),
                      ProfileImagePicker(),
                      const SizedBox(height: 32),
                      AppTextField(controller: _nameCtrl, hintText: 'Name'),
                      const SizedBox(height: 14),
                      AppTextField(controller: _emailCtrl, hintText: 'Email'),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _addressCtrl,
                        hintText: 'Address',
                      ),
                      const SizedBox(height: 14),
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
                          Text("Already have an account?"),
                          SizedBox(width: 2),
                          CustomTextButton(
                            title: "Log in",
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.loginPage);
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
    final authState = ref.watch(authProvider);
    return SizedBox(
      width: 160,
      height: 44,
      child: AppButton(
        title: 'Continue',
        isLoading: authState.isLoading,
        onTap: () {
          if (!_formKey.currentState!.validate()) return;

          final imageFile = ref.read(profileImageProvider);

          final model = UserRequestModel(
            name: _nameCtrl.text.trim(),
            phone: _mobileCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            address: _addressCtrl.text.trim(),
            profileImage: imageFile?.path,
          );

          ref.read(phoneProvider.notifier).state = _mobileCtrl.text;

          // 👉 ONLY API CALL
          ref.read(authProvider.notifier).register(model: model);
        },
      ),
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
