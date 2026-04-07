import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/booking_confirmed_page.dart';

class MyBookingDetails extends ConsumerWidget {
  const MyBookingDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(typeSelected);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TOP CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    /// LEFT TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Satyanarayan Pooja",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Nov 2026",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "10:00 AM - 12:00 PM",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    /// RIGHT IMAGE
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            "assets/retual.png", // your image
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Pandit Vishal Sharma",
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// MAIN CARD
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/pandit.png", // your image
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// NAME + CALL BUTTON
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Pandit Vishal\nSharma",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green.withAlpha(40),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.call,
                                color: AppColors.green,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Call Pandit Ji",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// DETAILS
                    const Text(
                      "15+ Years Experience",
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Hindi | Sanskrit",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 12),

                    /// BUTTONS ROW
                    Row(
                      children: [
                        /// WHATSAPP
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: AppColors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Chat on Whatsapp",
                                  style: text11(color: AppColors.green),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        /// TRACK LOCATION
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Track location",
                                  style: text11(color: AppColors.error),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // about
              SizedBox(height: 15),
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
                  Navigator.pushNamed(context, AppRoutes.panditRecKit);
                },
              ),

              if (type == "temple") ...[
                SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      /// LEFT TEXT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Temple Location",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Nov 2026",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "10:00 AM - 12:00 PM",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT IMAGE
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          "assets/retual.png", // your image
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 20),
              if (type == "online")
                AppOutlineButton(title: "Join Video Call", onTap: () {}),
              SizedBox(height: 15),

              AppOutlineButton(title: "Reschedule", onTap: () {}),
              SizedBox(height: 15),

              AppButton(
                title: "Cancel Booking",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.cancelBooking);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
