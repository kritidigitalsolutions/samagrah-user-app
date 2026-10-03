import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BookingCardSkeleton extends StatelessWidget {
  const BookingCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                /// LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 70,
                          height: 24,
                          color: AppColors.grey300,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Container(
                        width: 140,
                        height: 16,
                        color: AppColors.grey300,
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: 100,
                        height: 12,
                        color: AppColors.grey300,
                      ),

                      const SizedBox(height: 6),

                      Container(
                        width: 80,
                        height: 12,
                        color: AppColors.grey300,
                      ),

                      const SizedBox(height: 12),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 100,
                          height: 30,
                          color: AppColors.grey300,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                /// RIGHT IMAGE
                Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(width: 60, height: 10, color: AppColors.grey300),
                  ],
                ),
              ],
            ),
          ),

          /// STATUS BADGE
          Positioned(
            top: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
              child: Container(
                width: 80,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
