import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProductListingSkeleton extends StatelessWidget {
  const ProductListingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          _bannerSkeleton(),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, __) => const ProductCardSkeleton(),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(width: 120, child: const ProductCardSkeleton()),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 6,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(width: 120, child: const ProductCardSkeleton()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _bannerSkeleton() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    height: 130,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Stack(
      children: [
        /// top decoration
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(height: 28, color: AppColors.grey300),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 120, color: AppColors.grey300),
                    const SizedBox(height: 10),
                    Container(height: 10, width: 150, color: AppColors.grey300),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 90, color: AppColors.grey300),
                  ],
                ),
              ),

              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 40,
                      width: 40,
                      color: AppColors.grey300,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 70, color: AppColors.grey300),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// IMAGE
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: AppColors.grey300,
                  ),
                ),

                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: AppColors.grey300,
                ),

                const SizedBox(height: 8),

                Container(height: 10, width: 80, color: AppColors.grey300),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    height: 28,
                    width: double.infinity,
                    color: AppColors.grey300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
