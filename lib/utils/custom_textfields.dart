import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samagrah/res/app_colors.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final double radius;
  final int? maxline;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.maxLength,
    this.radius = 30,
    this.maxline = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      inputFormatters: inputFormatters,
      maxLines: maxline,

      // ✅ ADD THIS (IMPORTANT)
      maxLength: maxLength,
      cursorColor: AppColors.button,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        // 👇 DEFAULT BORDER
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),

        // 👇 NORMAL (UNFOCUSED)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: AppColors.grey300, width: 1),
        ),

        // 🔥 FOCUSED (THIS IS WHAT YOU WANT)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(
            color: AppColors.button, // 👉 your button/primary color
            width: 2,
          ),
        ),

        // ❌ ERROR STATE
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.error),
        ),

        // 🔴 FOCUSED ERROR
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}

class NumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLength;
  final double radius;
  final Widget? prefixIcon;

  const NumberTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLength,
    this.radius = 30,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.number,
      radius: radius,
      prefixIcon: prefixIcon,

      // ✅ ONLY NUMBER INPUT
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],

      // ✅ OPTIONAL LENGTH LIMIT
      maxLength: maxLength,

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Enter number";
        }
        return null;
      },
    );
  }
}
