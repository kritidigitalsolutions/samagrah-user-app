import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/booking_confirmed_page.dart';

class PanditDetailsPage extends ConsumerWidget {
  const PanditDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;

    final isExpanded = ref.watch(availabilityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔴 IMAGE
              CustomCachedImage(
                imageUrl: pandit.profileImage ?? "",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),

              const SizedBox(height: 12),

              /// 🔴 NAME + BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${pandit.fullName ?? "Pandit"} ⭐ ${pandit.ratingAverage ?? 0}",
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 8),
                  AppButton(
                    height: 35,
                    radius: 8,
                    title: "Book Now",
                    onTap: () {
                      ref.read(selectedPanditProvider.notifier).state = pandit;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.serviceSelection,
                        arguments: pandit,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 6),

              /// 🔴 EXPERIENCE + LANGUAGE
              Text(
                "${pandit.yearsOfExperience ?? 0}+ Years Experience",
                style: text14(),
              ),
              Text(
                pandit.languagesSpoken.isNotEmpty
                    ? pandit.languagesSpoken.join(", ")
                    : "Language not available",
                style: text14(),
              ),

              const SizedBox(height: 12),

              /// 🔴 TEMPLE ASSOCIATED
              if (pandit.templeAssociated != null &&
                  pandit.templeAssociated!.isNotEmpty)
                _buildInfoCard(
                  title: "Temple Associated",
                  child: Text(pandit.templeAssociated!, style: text12()),
                ),

              /// 🔴 ADDRESS
              if (pandit.address != null)
                _buildInfoCard(
                  title: "Address",
                  child: Text(_buildAddress(pandit.address!), style: text12()),
                ),

              /// 🔴 ABOUT + SERVICES
              _buildInfoCard(
                title: "About",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pandit.bio ?? "No description available",
                      style: text12(),
                    ),
                    const SizedBox(height: 10),

                    Text("Available For", style: text12()),
                    const SizedBox(height: 6),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (pandit.serviceTypes?.homeVisit == true)
                          _buildBullet("Home Puja"),
                        if (pandit.serviceTypes?.onlinePooja == true)
                          _buildBullet("Online Puja"),
                        if (pandit.serviceTypes?.atTemple == true)
                          _buildBullet("Temple Pooja"),
                        if (pandit.serviceTypes?.travelForSpecialPoojas == true)
                          _buildBullet("Special Travel Pooja"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              /// 🔴 POOJA OFFERINGS (IMPROVED UI)
              if (pandit.poojaOfferings.isNotEmpty)
                _buildInfoCard(
                  title: "Pooja Services",
                  child: Column(
                    children: pandit.poojaOfferings.map((pooja) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// 🔴 NAME
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    pooja.name ?? "Pooja",
                                    style: text14(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            /// 🔴 DESCRIPTION
                            if (pooja.description != null &&
                                pooja.description!.isNotEmpty)
                              Text(pooja.description!, style: text12()),

                            const SizedBox(height: 8),

                            /// 🔴 DURATION
                            if (pooja.durationHours != null)
                              _buildKeyValue(
                                "Duration",
                                "${pooja.durationHours} hrs",
                              ),

                            /// 🔴 SAMAGRI TYPE
                            if (pooja.standardSamagri == true)
                              _buildKeyValue("Samagri", "Standard Included"),

                            if (pooja.customSamagri == true)
                              _buildKeyValue("Samagri", "Custom Required"),

                            /// 🔴 TRAVEL
                            if (pooja.travelForSpecialPooja == true)
                              _buildKeyValue("Travel", "Available"),

                            /// 🔴 CUSTOM ITEMS (if any)
                            if (pooja.customSamagriItems.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                "Recommended Pooja Kit",
                                style: text15(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              buildRecommendationCard(
                                'Keep this required',
                                'Pooja Samagri',
                                'ready before the pandit arrives',
                                true,
                                () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.panditRecKit,
                                    arguments: pooja
                                        .customSamagriItems, // ← pass items
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              const SizedBox(height: 15),

              /// 🔴 CHECK AVAILABILITY
              GestureDetector(
                onTap: () {
                  ref.read(availabilityProvider.notifier).state = !isExpanded;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.button),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppColors.button,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Check Availability",
                            style: TextStyle(color: AppColors.button),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: AppColors.button,
                          ),
                        ],
                      ),

                      AnimatedCrossFade(
                        duration: const Duration(milliseconds: 300),
                        crossFadeState: isExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: const SizedBox(),
                        secondChild: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1.2,
                              ),
                          itemBuilder: (context, index) {
                            return const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("10 Nov", style: TextStyle(fontSize: 10)),
                                SizedBox(height: 4),
                                Text(
                                  "10:00 AM",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeyValue(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text("$title: ", style: text12(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: text12())),
        ],
      ),
    );
  }

  /// 🔹 Common Card
  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text14(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  /// 🔹 Address builder
  String _buildAddress(PanditAddress address) {
    return [
      address.line1,
      address.line2,
      address.city,
      address.state,
      address.pinCode,
    ].where((e) => e != null && e.isNotEmpty).join(", ");
  }

  /// 🔹 Bullet
  Widget _buildBullet(String text) {
    return Row(
      children: [
        Icon(Icons.circle, size: 6, color: AppColors.green),
        const SizedBox(width: 6),
        Text(text, style: text12()),
      ],
    );
  }
}
