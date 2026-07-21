import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;
    final selectedIndex = ref.watch(serviceSelected);
    final selectedRitual = ref.watch(selectedRitualProvider);
    final hasTravel = selectedRitual?.travelForSpecialPooja == true;

    /// 🔥 Dynamic Service List
    final List<ServiceModel> serviceList = [];

    if (pandit.serviceTypes?.homeVisit == true && hasTravel) {
      serviceList.add(
        ServiceModel(
          title: 'Home Visit',
          type: "home",
          description: 'Puja will be performed at your home.',
          icon: Icons.home_outlined,
        ),
      );
    }

    if (pandit.serviceTypes?.onlinePooja == true) {
      serviceList.add(
        ServiceModel(
          title: 'Online Puja',
          type: "online",
          description: 'Puja will be performed online.',
          icon: Icons.video_call_outlined,
        ),
      );
    }

    if (pandit.serviceTypes?.atTemple == true) {
      serviceList.add(
        ServiceModel(
          title: 'Temple Ritual',
          type: "temple",
          description: 'Puja will be performed at temple.',
          icon: Icons.temple_hindu_outlined,
        ),
      );
    }

    // if (pandit.serviceTypes?.travelForSpecialPoojas == true) {
    //   serviceList.add(
    //     ServiceModel(
    //       title: 'Special Travel Pooja',
    //       type: "special",
    //       description: 'Pandit will travel for special pooja.',
    //       image: 'assets/special_pooja.jpg',
    //     ),
    //   );
    // }

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
              errorBuilder: (_, _, _) => Container(
                width: 70,
                height: 70,
                color: AppColors.grey500,
                child: const Icon(Icons.image),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                        "1",
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
                            "Select Puja Mode",
                            style: text16(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "Choose how you want your Puja",
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "1 / 3",
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
            const SizedBox(height: 10),

            /// 🔴 EMPTY STATE
            if (serviceList.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "No services available for this pandit",
                    style: text16(),
                  ),
                ),
              )
            else
              /// 🟢 SERVICE LIST
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
                        ref,
                        service,
                        index,
                        selectedIndex,
                      ),
                    );
                  },
                ),
              ),

            /// 🔵 NEXT BUTTON
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.button,
              child: AppButton(
                title: "Next",
                onTap: (selectedIndex == null || serviceList.isEmpty)
                    ? () {
                        AppSnackbar.show(
                          context,
                          message: "Select a service to continue",
                          type: SnackBarType.error,
                        );
                      }
                    : () {
                        final selected = serviceList[selectedIndex];

                        ref.read(selectedServiceProvider.notifier).state =
                            selected;

                        Navigator.pushNamed(
                          context,
                          AppRoutes.timeSelection,
                          arguments: pandit,
                        );
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Service Card
  Widget _buildServiceCard(
    BuildContext context,
    WidgetRef ref,
    ServiceModel service,
    int index,
    int? selectedIndex,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(serviceSelected.notifier).state = index;
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.button : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: text16(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: text12(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),

              /// ICON
              Container(
                width: 70,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(service.icon, color: Colors.orange),
              ),

              const SizedBox(width: 10),

              /// RADIO ICON
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
  }
}

/// 🔵 Model
class ServiceModel {
  final String title;
  final String type;
  final String description;
  final IconData icon;

  ServiceModel({
    required this.title,
    required this.type,
    required this.description,
    required this.icon,
  });
}
