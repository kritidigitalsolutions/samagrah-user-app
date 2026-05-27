// ═══════════════════════════════════════════════
//  PANDIT SKELETON LOADER
// ═══════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PanditCardLoader extends StatelessWidget {
  const PanditCardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          // Fake results count
          Container(
            height: 20,
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 16),

          // Grid of skeleton cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.72,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // ← Important
                    children: [
                      // Image skeleton
                      Container(
                        height: 152, // ← Reduced from 160
                        color: AppColors.grey300,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min, // ← Added
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.grey300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Rating + Experience
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 12,
                                  color: AppColors.grey300,
                                ),
                                const Spacer(),
                                Container(
                                  width: 58,
                                  height: 12,
                                  color: AppColors.grey300,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Button skeleton
                            Container(
                              height: 28,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.grey300,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
