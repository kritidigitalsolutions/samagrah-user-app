import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

// Service Selection Screen
class ServiceSelectionScreen extends StatelessWidget {
  ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final isSelected = ref.watch(serviceSelected);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Book your Pandit",

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/panditLogo.png',
              width: 70,
              height: 70,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.grey500,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              decoration: BoxDecoration(color: AppColors.headerCard),
              child: _buildCustomStepper(),
            ),
            const SizedBox(height: 24),
            // Service Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: serviceList.length,
                itemBuilder: (context, index) {
                  final service = serviceList[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildServiceCard(
                      context,
                      service.title,
                      service.description,
                      service.image,
                      index, // 👈 pass index (important for selection)
                    ),
                  );
                },
              ),
            ),
            // Next Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.button),
              child: Consumer(
                builder: (context, ref, _) {
                  final selectedIndex = ref.watch(serviceSelected);

                  return AppButton(
                    title: "Next",
                    onTap: () {
                      if (selectedIndex == null) {
                        CustomSnackbar.showCustomSnackBar(
                          context,
                          message: "Please Select one option",
                          backgroundColor: AppColors.error,
                          icon: Icons.error_outline,
                        );
                        return;
                      }
                      final selected = serviceList[selectedIndex];

                      ref.read(selectedServiceProvider.notifier).state =
                          selected;

                      Navigator.pushNamed(context, AppRoutes.timeSelection);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Column(
      children: [
        const SizedBox(height: 8),

        /// 🔴 DOT + LINE ROW
        Row(
          children: [
            buildCircle("1", true),
            buildDottedLine(),
            buildCircle("2", false),
            buildDottedLine(),
            buildCircle("3", false),
          ],
        ),
        const SizedBox(height: 8),

        bottomLable(),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    int index, // 👈 important
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedIndex = ref.watch(serviceSelected);
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            ref.read(serviceSelected.notifier).state = index;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),

              /// 🔴 Border highlight
              border: Border.all(
                color: isSelected ? AppColors.button : Colors.transparent,
                width: 1.5,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  /// TEXT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// IMAGE / ICON
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 60,
                      color: Colors.orange.shade100,
                      child: const Icon(
                        Icons.temple_hindu,
                        color: Colors.orange,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// 🔴 SELECTION ICON
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppColors.button,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  final serviceList = [
    ServiceModel(
      title: 'Home Visit',
      type: "home",
      description:
          'Pooja will be performed at your home and perform the ritual.',
      image: 'assets/home_visit.jpg',
    ),
    ServiceModel(
      title: 'Online Pooja',
      type: "online",
      description: 'Pooja will be performed remotely via online platform.',
      image: 'assets/online_pooja.jpg',
    ),
    ServiceModel(
      type: "temple",
      title: 'Temple Ritual',
      description: 'Pooja will be performed at the temple.',
      image: 'assets/temple_ritual.jpg',
    ),
  ];
}

class ServiceModel {
  final String title;
  final String type;
  final String description;
  final String image;

  ServiceModel({
    required this.title,
    required this.type,
    required this.description,
    required this.image,
  });
}
