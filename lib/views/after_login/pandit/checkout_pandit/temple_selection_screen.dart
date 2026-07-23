import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

// Screen 1: Address Selection Screen
class TempleSelectionScreen extends ConsumerStatefulWidget {
  const TempleSelectionScreen({super.key});

  @override
  ConsumerState<TempleSelectionScreen> createState() =>
      _AddressSelectionScreenState();
}

class _AddressSelectionScreenState
    extends ConsumerState<TempleSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final templeAsync = ref.watch(templeProvider);
    final associatedTempleName = ref.watch(
      selectedPanditProvider.select((pandit) => pandit?.templeAssociated),
    );
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // 🔵 Step Circle (Gradient + Shadow)
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "3",
                        style: text14(
                          color: AppColors.white,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // 📝 Title + Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Select Temple",
                            style: text16(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Choose a temple for your Puja",
                            style: text12(color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),

                    // 📊 Step Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "3 / 3",
                        style: text12(
                          color: AppColors.warningDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Address Section
            templeAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) =>
                  Center(child: Text("Something went wrong")),
              data: (data) {
                final normalizedAssociatedTemple = associatedTempleName
                    ?.trim()
                    .toLowerCase();
                final temples = data.data.where((temple) {
                  if (normalizedAssociatedTemple == null ||
                      normalizedAssociatedTemple.isEmpty) {
                    return false;
                  }

                  return temple.name?.trim().toLowerCase() ==
                      normalizedAssociatedTemple;
                }).toList();

                if (temples.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          "Associated temple is not available.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: temples.length,
                    itemBuilder: (context, index) {
                      final temple = temples[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildServiceCard(
                          context,
                          temple.name ?? '',
                          temple.description ?? '',
                          temple.image ?? '',
                          temple.id ?? '',
                          index, // 👈 pass index (important for selection)
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Next Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.button),
              child: Consumer(
                builder: (context, ref, _) {
                  // final selectedIndex = ref.watch(serviceSelected) ?? 0;

                  return AppButton(
                    title: "Next",
                    onTap: () {
                      // final selected = templeList[selectedIndex];

                      // ref.read(selectedTempleProvider.notifier).state =
                      //     selected;

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

  Widget _buildServiceCard(
    BuildContext context,
    String title,
    String description,
    String imagePath,
    String id,
    int index, // 👈 important
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTemple = ref.watch(selectedTempleIdProvider);
        final isSelected = id == selectedTemple;

        return GestureDetector(
          onTap: () {
            ref.read(selectedTempleIdProvider.notifier).state = id;
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text12(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  /// IMAGE / ICON
                  CustomCachedImage(
                    imageUrl: imagePath,
                    width: 80,
                    height: 60,
                    borderRadius: BorderRadius.circular(8),
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
}
