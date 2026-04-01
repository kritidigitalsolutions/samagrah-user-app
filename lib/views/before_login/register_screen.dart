import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/before_login_provider/profile_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Mandala watermark background
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: Center(child: _MandalaPainter()),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // Title
                    Text(
                      'Set up\nyour profile',
                      textAlign: TextAlign.center,
                      style: text26(),
                    ),

                    const SizedBox(height: 28),

                    // Profile image picker
                    ProfileImagePicker(),

                    const SizedBox(height: 32),

                    // Name field
                    AppTextField(controller: _nameCtrl, hintText: 'Name'),
                    const SizedBox(height: 14),

                    // Email field
                    AppTextField(
                      controller: _emailCtrl,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),

                    // Address field
                    AppTextField(controller: _addressCtrl, hintText: 'Address'),
                    const SizedBox(height: 14),

                    // Mobile field
                    NumberTextField(
                      controller: _mobileCtrl,
                      hintText: 'Mobile Number',
                      maxLength: 10,
                    ),

                    const SizedBox(height: 32),

                    // Continue button
                    _buildContinueButton(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: 160,
      height: 44,
      child: AppButton(
        title: 'Continue',
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.otp);
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

// ── Mandala Background Painter ────────────────────
class _MandalaPainter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.06,
      child: SizedBox(
        width: 380,
        height: 380,
        child: CustomPaint(painter: _MandalaCustomPainter()),
      ),
    );
  }
}

class _MandalaCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7B1535)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw concentric circles
    for (int i = 1; i <= 8; i++) {
      canvas.drawCircle(Offset(cx, cy), i * 22.0, paint);
    }

    // Draw radial lines
    for (int i = 0; i < 24; i++) {
      final angle = (i * 15) * (3.14159 / 180);
      final x1 = cx + 22 * _cos(angle);
      final y1 = cy + 22 * _sin(angle);
      final x2 = cx + 176 * _cos(angle);
      final y2 = cy + 176 * _sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw petal shapes
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * (3.14159 / 180);
      final petalPath = Path();
      final px = cx + 55 * _cos(angle);
      final py = cy + 55 * _sin(angle);
      petalPath.addOval(
        Rect.fromCenter(center: Offset(px, py), width: 20, height: 36),
      );
      canvas.drawPath(petalPath, paint);
    }
  }

  double _cos(double angle) => (angle == 0)
      ? 1
      : (angle == 1.5708)
      ? 0
      : (angle == 3.14159)
      ? -1
      : (angle == 4.71239)
      ? 0
      : _cosCalc(angle);

  double _sin(double angle) => _sinCalc(angle);

  double _cosCalc(double a) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -a * a / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _sinCalc(double a) {
    double result = a;
    double term = a;
    for (int i = 1; i <= 10; i++) {
      term *= -a * a / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
