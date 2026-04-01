import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

// Screen 1: Address Selection Screen
class TempleSelectionScreen extends StatefulWidget {
  const TempleSelectionScreen({super.key});

  @override
  State<TempleSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<TempleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
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
            // Select Address Section
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: templeList.length,
                itemBuilder: (context, index) {
                  final service = templeList[index];

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
                  final selectedIndex = ref.watch(serviceSelected) ?? 0;

                  return AppButton(
                    title: "Next",
                    onTap: () {
                      final selected = templeList[selectedIndex];

                      ref.read(selectedTempleProvider.notifier).state =
                          selected;

                      Navigator.pushNamed(context, AppRoutes.bookingSummary);
                    },
                  );
                },
              ),
            ),

            // Next Button
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
            buildCircle("2", true),
            buildDottedLine(),
            buildCircle("3", true),
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
        final selectedIndex = ref.watch(templeSelected);
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            ref.read(templeSelected.notifier).state = index;
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
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
                        Text(title, style: text16(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: text12(color: Colors.grey.shade600),
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

  final templeList = [
    TempleModel(
      title: 'Shri Hanuman Mandir',
      type: "home",
      description: 'Shastri Nagar, Meerut',
      image: 'assets/home_visit.jpg',
    ),
    TempleModel(
      title: 'Shri Hanuman Mandir',
      type: "online",
      description: 'Shastri Nagar, Meerut',
      image: 'assets/online_pooja.jpg',
    ),
    TempleModel(
      type: "temple",
      title: 'Shri Durga Mandir',
      description: 'Garh Road, Meerut',
      image: 'assets/temple_ritual.jpg',
    ),
  ];
}

class TempleModel {
  final String title;
  final String type;
  final String description;
  final String image;

  TempleModel({
    required this.title,
    required this.type,
    required this.description,
    required this.image,
  });
}
