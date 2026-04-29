import 'package:flutter/material.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:samagrah/res/app_colors.dart';

class FestivalCardSkeleton extends StatelessWidget {
  const FestivalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        duration: const Duration(milliseconds: 1000),
        baseColor: AppColors.white.withOpacity(0.25),
        highlightColor: AppColors.white.withOpacity(0.7),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Festival Title Loading",
                    style: text16(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Subtitle loading line one",
                    style: TextStyle(fontSize: 12, color: AppColors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Subtitle loading line two",
                    style: TextStyle(fontSize: 12, color: AppColors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "View Kit",
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Bone(
              width: 90,
              height: 110,
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
      ),
    );
  }
}
