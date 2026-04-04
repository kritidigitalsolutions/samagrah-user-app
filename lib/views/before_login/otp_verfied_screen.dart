import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/before_login_provider/otp_provider.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const int _otpLength = 4;

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    final otpList = [...ref.read(otpProvider)];

    otpList[index] = value;
    ref.read(otpProvider.notifier).state = otpList;

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final otp = otpList.join();

    if (otp.length == _otpLength) {
      FocusScope.of(context).unfocus();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      final otpList = [...ref.read(otpProvider)];

      otpList[index - 1] = '';
      ref.read(otpProvider.notifier).state = otpList;

      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        decoration: BoxDecoration(color: AppColors.white),
        child: Stack(
          children: [
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
            // Back button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Title
                      Text('Verify OTP', style: text26()),

                      const SizedBox(height: 40),

                      // OTP boxes
                      _buildOtpRow(),

                      const SizedBox(height: 20),

                      // Helper text
                      Text(
                        'Enter the 4-digit code sent to\nyour mobile number',
                        textAlign: TextAlign.center,
                        style: text13(),
                      ),

                      const SizedBox(height: 40),

                      // Continue button
                      _buildContinueButton(),

                      const SizedBox(height: 30),

                      // Resend
                      GestureDetector(
                        onTap: () {},
                        child: RichText(
                          text: TextSpan(
                            text: "Didn't receive code? ",
                            style: text13(),
                            children: [
                              TextSpan(
                                text: 'Resend',
                                style: TextStyle(
                                  color: AppColors.button,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.button,
                                ),
                              ),
                            ],
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

  Widget _buildOtpRow() {
    final otpList = ref.watch(otpProvider); // 👈 ADD THIS

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_otpLength, (index) {
        final isFilled = otpList[index].isNotEmpty; // 👈 FIX

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(index, event),
            child: SizedBox(
              width: 56,
              height: 56,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                maxLength: 1,
                onChanged: (val) => _onOtpChanged(index, val), // 👈 FIX
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.7),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.grey300,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isFilled ? AppColors.button : AppColors.grey200,
                      width: isFilled ? 1.5 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.button,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildContinueButton() {
    final otpList = ref.watch(otpProvider);
    final otp = otpList.join();

    return SizedBox(
      width: 160,
      height: 44,
      child: AppButton(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.home);
          print("OTP: $otp");
        },

        title: "Continue",
      ),
    );
  }
}

// ── Mandala Background ────────────────────────────
