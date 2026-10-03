import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';

class EmptyDataWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String animationPath;
  final double height;

  const EmptyDataWidget({
    super.key,
    required this.title,
    required this.animationPath,
    this.subtitle,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(animationPath, height: height, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: text18(fontWeight: FontWeight.w600),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: text14(color: AppColors.grey600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
