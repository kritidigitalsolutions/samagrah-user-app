import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/views/after_login/pandit/bookings/vedio_call_page.dart';
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
    final rescheduleState = ref.watch(rescheduleBookingProvider);

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
                    Stack(
                      children: [
                        CustomCachedImage(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          imageUrl: pandit?.profileImage ?? '',
                          width: double.infinity,
                          height: 180,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(booking.bookingStatus),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _getStatusText(booking.bookingStatus),
                                  style: text12(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Positioned(
                          top: 0,
                          left: 0,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(booking.bookingStatus),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _getBookingModeStatusText(
                                    booking.bookingMode,
                                  ),
                                  style: text12(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

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
                              if ((booking.bookingStatus == "cancelled")) {
                                print("cancelled booking");
                                return;
                              }
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
                                if ((booking.bookingStatus == "cancelled")) {
                                  print("cancelled booking");
                                  return;
                                }
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
                          // Expanded(
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // TODO: Implement location tracking
                          //     },
                          //     child: Container(
                          //       padding: const EdgeInsets.symmetric(
                          //         vertical: 8,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         color: Colors.red.shade50,
                          //         borderRadius: BorderRadius.circular(20),
                          //       ),
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.center,
                          //         children: [
                          //           const Icon(
                          //             Icons.location_on,
                          //             color: AppColors.error,
                          //             size: 16,
                          //           ),
                          //           const SizedBox(width: 6),
                          //           Text(
                          //             "Track location",
                          //             style: text11(color: AppColors.error),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                              booking.temple?.name ?? "Temple Location",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${booking.templeSnapshot?.city ?? ""}, ${booking.templeSnapshot?.state ?? ""}",
                              style: text12(color: AppColors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.templeSnapshot?.landmark ?? "",
                              style: text12(color: AppColors.grey),
                            ),
                          ],
                        ),
                      ),

                      /// RIGHT IMAGE
                      CustomCachedImage(
                        imageUrl: booking.templeSnapshot?.image ?? '',
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

              if (!(booking.bookingStatus == "cancelled")) ...[
                const SizedBox(height: 20),
                if (type == "online")
                  AppOutlineButton(
                    title: "Join Video Call",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgoraVideoCallScreen(
                            bookingId: booking.id ?? '',
                            panditId: pandit?.id ?? '',
                            localUid: 1,
                            // ↑ use your logged-in user's int ID, or generate one:
                            // localUid: DateTime.now().millisecondsSinceEpoch % 100000,
                            panditName: pandit?.fullName ?? 'Pandit Ji',
                            panditImage: pandit?.profileImage,
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 15),

                AppOutlineButton(
                  title: rescheduleState.isLoading
                      ? "Reschduleing..."
                      : "Reschedule",
                  onTap: () async {
                    final selectedSlot = await handleDateTimeSelection(context);

                    if (selectedSlot == null) {
                      AppSnackbar.show(
                        context,
                        message: "Please Select date and time",
                        type: SnackBarType.success,
                      );
                      return;
                    }

                    final model = PanditCreateOrderReqModel(
                      ritualId: booking.ritualRef?.id ?? '',
                      bookingMode: booking.bookingMode ?? '',
                      panditId: pandit?.id ?? '',
                      templeId: booking.temple?.id ?? '',
                      dateAndTime: DateAndTimeWrapper(
                        dateAndTime: [selectedSlot],
                      ),
                      address: Address(
                        name: booking.address?.name ?? '',
                        phone: booking.address?.phone ?? '',
                        fullAddress: booking.address?.fullAddress ?? '',
                        city: booking.address?.city ?? '',
                        state: booking.address?.state ?? '',
                        pincode: booking.address?.pincode ?? '',
                      ),
                      onlineDetails: OnlineDetails(
                        name: booking.address?.name ?? '',
                        phone: booking.address?.phone ?? '',
                        secPhone: booking.address?.secondPhone ?? '',
                        email: booking.address?.email ?? '',
                      ),
                      price: booking.dakshinaAmount ?? 0,
                    );

                    final success = await ref
                        .read(rescheduleBookingProvider.notifier)
                        .bookingReschedule(booking.id ?? '', model);

                    if (success && context.mounted) {
                      AppSnackbar.show(
                        context,
                        message: "Booking rescheduled successfully",
                        type: SnackBarType.success,
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),

                AppButton(
                  title: "Cancel Booking",
                  onTap: () {
                    showCancelOrderBottomSheet(context, ref, booking.id ?? '');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.day} ${getMonth(date.month)} ${date.year}";
  }

  /// Format TimeOfDay to "HH:MM AM/PM" format
  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  /// Handle date and time selection from search button
  Future<DateTimeSlot?> handleDateTimeSelection(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) return null;

    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Start Time',
    );

    if (startTime == null) return null;

    TimeOfDay? endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      ),
      helpText: 'Select End Time',
    );

    if (endTime == null) return null;

    String timeSlot = "${formatTime(startTime)} - ${formatTime(endTime)}";

    String formattedDate = formatDate(selectedDate);

    return DateTimeSlot(date: formattedDate, time: timeSlot);
  }
}

String getMonth(int month) {
  const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
  return months[month - 1];
}

Color _getStatusColor(String? status) {
  switch (status?.toLowerCase()) {
    case "confirmed":
      return AppColors.green;
    case "pending":
    case "requested":
      return AppColors.warning;
    case "completed":
      return AppColors.info;
    case "cancelled":
      return AppColors.error;
    default:
      return AppColors.grey;
  }
}

String _getStatusText(String? status) {
  switch (status?.toLowerCase()) {
    case "confirmed":
      return "Confirmed";
    case "pending":
    case "requested":
      return "Pending";
    case "completed":
      return "Completed";
    case "cancelled":
      return "Cancelled";
    default:
      return "Pending";
  }
}

String _getBookingModeStatusText(String? status) {
  switch (status?.toLowerCase()) {
    case "home":
      return "Home Pooja";
    case "temple":
      return "Temple Pooja";
    case "online":
      return "Online Pooja";
    default:
      return "Travel Pooja";
  }
}

void showCancelOrderBottomSheet(
  BuildContext context,
  WidgetRef ref,
  String orderId,
) {
  final reasons = [
    "Change of plans",
    "Booked by mistake",
    "Found another pandit",
    "Selected wrong date or time",
    "Pooja no longer required",
    "Location issue",
    "Pandit unavailable preference",
    "Other",
  ];

  ref.read(selectedCancelReasonProvider.notifier).state = null;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) {
      return Consumer(
        builder: (context, ref, child) {
          final selectedReason = ref.watch(selectedCancelReasonProvider);
          final cancelState = ref.watch(cancelBookingProvider);

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Cancel Order",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                Text(
                  "Please select a reason for cancellation",
                  style: text14(color: AppColors.grey600),
                ),

                const SizedBox(height: 16),

                ...reasons.map(
                  (reason) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedReason == reason
                            ? AppColors.button
                            : AppColors.grey200,
                      ),
                    ),
                    child: RadioListTile<String>(
                      activeColor: AppColors.button,
                      fillColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.button;
                        }
                        return AppColors.grey400;
                      }),
                      value: reason,
                      groupValue: selectedReason,
                      title: Text(
                        reason,
                        style: text14(fontWeight: FontWeight.w500),
                      ),
                      onChanged: (value) {
                        ref.read(selectedCancelReasonProvider.notifier).state =
                            value;
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                AppButton(
                  title: cancelState.isLoading ? "Cancelling..." : "Submit",
                  onTap: cancelState.isLoading
                      ? null
                      : () async {
                          if (selectedReason == null) {
                            AppSnackbar.show(
                              context,
                              message: "Please select reason",
                              type: SnackBarType.warning,
                            );

                            return;
                          }

                          final success = await ref
                              .read(cancelBookingProvider.notifier)
                              .cancelOrder(orderId, selectedReason);

                          if (success) {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.cancelBooking,
                            );
                            ref.invalidate(panditBookingProvider);

                            AppSnackbar.show(
                              context,
                              message: "Booking Cancelled Successfully",
                              type: SnackBarType.success,
                            );
                          }
                        },
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
