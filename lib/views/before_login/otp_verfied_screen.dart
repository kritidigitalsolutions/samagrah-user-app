import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/before_login_provider/auth_provider.dart';
import 'package:samagrah/view_model/before_login_provider/auth_state.dart';

class VerifyOtpScreen extends ConsumerStatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  ConsumerState<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends ConsumerState<VerifyOtpScreen> {
  static const int _otpLength = 6;
  static const int _resendSeconds = 60; // ← timer duration

  int _secondsLeft = _resendSeconds; // ← countdown value
  Timer? _timer; // ← timer instance

  // ... existing controllers and focusNodes ...

  @override
  @override
  void initState() {
    super.initState();
    _startTimer();

    // ✅ Clear all controllers and reset OTP provider state
    Future.microtask(() {
      for (final c in _controllers) {
        c.clear();
      }
      ref.read(otpProvider.notifier).state = List.filled(_otpLength, '');
    });

    // ✅ Auto-focus first field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  // ← start/restart countdown
  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ← always cancel timer
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  final List<TextEditingController> _controllers = List.generate(
    _otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    _otpLength,
    (_) => FocusNode(),
  );

  void _onOtpChanged(int index, String value) {
    final otpList = [...ref.read(otpProvider)];
    otpList[index] = value;
    ref.read(otpProvider.notifier).state = otpList;

    if (value.isNotEmpty && index < _otpLength - 1) {
      // ✅ Small delay prevents focus conflict on re-entry
      Future.microtask(() => _focusNodes[index + 1].requestFocus());
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

      _controllers[index - 1].clear();
      // ✅ Use microtask here too
      Future.microtask(() => _focusNodes[index - 1].requestFocus());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (data) {
          final res = data.verifyModel;

          if (res != null && res.success == true) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );

          } else if (res != null && res.success == false) {
            AppSnackbar.show(
              context,
              message: res.message ?? "OTP Failed",
              type: SnackBarType.error,
            );
          }
        },
      );
    });
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
                      'Enter the 6-digit code sent to\nyour mobile number',
                      textAlign: TextAlign.center,
                      style: text13(),
                    ),

                    const SizedBox(height: 40),

                    // Continue button
                    _buildContinueButton(),

                    const SizedBox(height: 30),

                    // Resend
                    // Resend — show timer OR resend button
                    _secondsLeft > 0
                        ? Text.rich(
                            TextSpan(
                              text: "Resend OTP in ",
                              style: text13(),
                              children: [
                                TextSpan(
                                  text:
                                      "00:${_secondsLeft.toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              final phone = ref
                                  .read(phoneProvider.notifier)
                                  .state;
                              ref
                                  .read(authProvider.notifier)
                                  .resend(mobile: phone);
                              _startTimer(); // ← restart timer on resend tap
                            },
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
          ],
        ),
      ),
    );
  }

  Widget _buildOtpRow() {
    final otpList = ref.watch(otpProvider); // 👈 ADD THIS

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_otpLength, (index) {
          final isFilled = otpList[index].isNotEmpty; // 👈 FIX

          return KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(index, event),
            child: SizedBox(
              width: 56,
              height: 56,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                maxLength: 1,
                onChanged: (val) => _onOtpChanged(index, val), // 👈 FIX
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white.withValues(alpha: 0.7),
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
          );
        }),
      ),
    );
  }

  Widget _buildContinueButton() {
    final otpList = ref.watch(otpProvider);
    final otp = otpList.join();

    final authState = ref.watch(authProvider);

    return SizedBox(
      width: 160,
      height: 44,
      child: AppButton(
        title: "Continue",
        isLoading: authState.isLoading,
        onTap: () {
          final phone = ref.read(phoneProvider.notifier).state;
          print(otp);
          print(phone);
          ref.read(authProvider.notifier).verifyOtp(mobile: phone, otp: otp);
        },
      ),
    );
  }
}

// ── Mandala Background ────────────────────────────
