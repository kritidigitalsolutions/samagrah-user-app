import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';

class PanditDetailsPage extends ConsumerWidget {
  const PanditDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(availabilityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔴 IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/pandit.png', // replace with your image
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 10),

              /// 🔴 NAME + BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pandit Vishal Sharma 4.8",
                    style: text16(fontWeight: FontWeight.bold),
                  ),

                  AppButton(
                    height: 35,
                    radius: 8,
                    title: "Book Now",
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.serviceSelection);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Text("15+ Years Experience", style: text14()),
              Text("Hindi", style: text14()),

              const SizedBox(height: 10),

              /// 🔴 ABOUT
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pandit Vishal Sharma has over 15 years of experience performing rituals like Griha Pravesh, Satyanarayan Puja, and more.",
                      style: text12(),
                    ),
                    const SizedBox(height: 10),

                    /// 🔴 AVAILABLE FOR
                    Text("Available For", style: text12()),
                    const SizedBox(height: 5),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.green),
                            SizedBox(width: 6),
                            Text("Home Puja", style: text12()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.green),
                            SizedBox(width: 6),
                            Text("Online Puja", style: text12()),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.circle, size: 6, color: Colors.green),
                            SizedBox(width: 6),
                            Text("Video Call Ritual", style: text12()),
                          ],
                        ),
                      ],
                    ),
                  ],
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
}
