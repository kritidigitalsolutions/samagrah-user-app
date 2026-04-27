import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/booking_confirmed_page.dart';
import 'package:intl/intl.dart';

class MyBookingDetails extends ConsumerWidget {
  const MyBookingDetails({super.key});

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(List<DateAndTimeElement>? dateAndTime) {
    if (dateAndTime == null || dateAndTime.isEmpty) return "";

    final times = dateAndTime
        .map((dt) => dt.time ?? "")
        .where((t) => t.isNotEmpty)
        .toList();
    if (times.isEmpty) return "";

    return times.join(" — ");
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(typeSelected);
    final booking = ref.watch(selectedBookingProvider);

    // If no booking is selected, show error
    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              SizedBox(height: 16),
              Text(
                "Booking not found",
                style: text16(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final pandit = booking.pandit;
    final ritual = booking.ritual;
    final dateAndTime = booking.dateAndTime?.dateAndTime;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              /// MAIN CARD
              Container(
                // padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// IMAGE
                    CustomCachedImage(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      imageUrl: pandit?.profileImage ?? '',
                      width: double.infinity,
                      height: 180,
                    ),

                    // const SizedBox(height: 12),

                    /// NAME + CALL BUTTON
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pandit?.fullName ?? "Pandit Ji",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              makePhoneCall(pandit?.phone);
                            },
                            child: Container(
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
                          ),
                        ],
                      ),
                    ),

                    // const SizedBox(height: 8),

                    /// DETAILS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        "${pandit?.yearsOfExperience ?? 0}+ Years Experience",
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        pandit?.languagesSpoken.join(" | ") ??
                            "Hindi | Sanskrit",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // ritual
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          /// LEFT TEXT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ritual?.name ?? "Pooja",
                                  style: text16(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(booking.bookingDate),
                                  style: text12(color: AppColors.grey),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _formatTime(dateAndTime),
                                  style: text12(color: AppColors.grey),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT IMAGE
                          Column(
                            children: [
                              CustomCachedImage(
                                borderRadius: BorderRadius.circular(8),
                                imageUrl: ritual?.image ?? '',
                                width: 50,
                                height: 60,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// BUTTONS ROW
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          /// WHATSAPP
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                openWhatsApp(pandit?.phone);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.whatsapp,
                                      color: AppColors.green,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Chat on Whatsapp",
                                      style: text11(color: AppColors.green),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// TRACK LOCATION
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Implement location tracking
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: AppColors.error,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Track location",
                                      style: text11(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // about
              const SizedBox(height: 15),
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
                      ritual?.description ??
                          "${pandit?.fullName ?? "Pandit Ji"} has over ${pandit?.yearsOfExperience ?? 0} years of experience performing rituals.",
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
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 6),
                            Text("Home Puja", style: text12()),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 6),
                            Text("Online Puja", style: text12()),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.green,
                            ),
                            const SizedBox(width: 6),
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
                const SizedBox(height: 15),
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
                          children: [
                            Text(
                              booking.templeSnapshot?.name ??
                                  booking.mandirSnapshot?.name ??
                                  "Temple Location",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${booking.templeSnapshot?.city ?? booking.mandirSnapshot?.city ?? ""}, ${booking.templeSnapshot?.state ?? booking.mandirSnapshot?.state ?? ""}",
                              style: text12(color: AppColors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.templeSnapshot?.landmark ??
                                  booking.mandirSnapshot?.landmark ??
                                  "",
                              style: text12(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT IMAGE
                      CustomCachedImage(
                        imageUrl:
                            booking.templeSnapshot?.image ??
                            booking.mandirSnapshot?.image ??
                            '',
                        width: 50,
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ],

              if (type == "home" && booking.address != null) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Booking Address",
                        style: text15(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        booking.address?.name ?? "",
                        style: text13(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.address?.phone ?? "",
                        style: text12(color: AppColors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${booking.address?.fullAddress ?? ""}, ${booking.address?.city ?? ""}, ${booking.address?.state ?? ""} - ${booking.address?.pincode ?? ""}",
                        style: text12(color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              if (type == "online")
                AppOutlineButton(
                  title: "Join Video Call",
                  onTap: () {
                    // TODO: Implement video call functionality
                  },
                ),
              const SizedBox(height: 15),

              AppOutlineButton(
                title: "Reschedule",
                onTap: () {
                  // TODO: Implement reschedule functionality
                },
              ),
              const SizedBox(height: 15),

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

  // Widget _buildImage(String imageUrl, double height, double width) {
  //   if (imageUrl.startsWith('http')) {
  //     return Image.network(
  //       imageUrl,
  //       height: height,
  //       width: width is double && width == double.infinity ? width : width,
  //       fit: BoxFit.cover,
  //       errorBuilder: (context, error, stack) {
  //         return Image.asset(
  //           "assets/retual.png",
  //           height: height,
  //           width: width is double && width == double.infinity ? width : width,
  //           fit: BoxFit.cover,
  //         );
  //       },
  //     );
  //   } else {
  //     return Image.asset(
  //       imageUrl,
  //       height: height,
  //       width: width is double && width == double.infinity ? width : width,
  //       fit: BoxFit.cover,
  //     );
  //   }
  // }
}
