import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;
    final selectedIndex = ref.watch(serviceSelected);

    /// 🔥 Dynamic Service List
    final List<ServiceModel> serviceList = [];

    if (pandit.serviceTypes?.homeVisit == true) {
      serviceList.add(
        ServiceModel(
          title: 'Home Visit',
          type: "home",
          description: 'Pooja will be performed at your home.',
          image: 'assets/home_visit.jpg',
        ),
      );
    }

    if (pandit.serviceTypes?.onlinePooja == true) {
      serviceList.add(
        ServiceModel(
          title: 'Online Pooja',
          type: "online",
          description: 'Pooja will be performed online.',
          image: 'assets/online_pooja.jpg',
        ),
      );
    }

    if (pandit.serviceTypes?.atTemple == true) {
      serviceList.add(
        ServiceModel(
          title: 'Temple Ritual',
          type: "temple",
          description: 'Pooja will be performed at temple.',
          image: 'assets/temple_ritual.jpg',
        ),
      );
    }

    if (pandit.serviceTypes?.travelForSpecialPoojas == true) {
      serviceList.add(
        ServiceModel(
          title: 'Special Travel Pooja',
          type: "special",
          description: 'Pandit will travel for special pooja.',
          image: 'assets/special_pooja.jpg',
        ),
      );
    }

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
              errorBuilder: (_, __, ___) => Container(
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
            /// 🔵 Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppColors.headerCard,
              child: _buildCustomStepper(),
            ),

            const SizedBox(height: 20),

            /// 🔴 EMPTY STATE
            if (serviceList.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    "No services available for this pandit",
                    style: TextStyle(fontSize: 16),
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

                        Navigator.pushNamed(context, AppRoutes.timeSelection);
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 Stepper UI
  Widget _buildCustomStepper() {
    return Column(
      children: [
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
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
                child: const Icon(Icons.temple_hindu, color: Colors.orange),
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
  final String image;

  ServiceModel({
    required this.title,
    required this.type,
    required this.description,
    required this.image,
  });
}
