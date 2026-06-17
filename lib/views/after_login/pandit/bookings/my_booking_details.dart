import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
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

  /// Returns the single PoojaOffering that matches the booked ritual name.
  /// Falls back to the first offering if no exact match is found.
  PoojaOffering? _getMatchingOffering(
    List<PoojaOffering> offerings,
    String? ritualName,
  ) {
    if (offerings.isEmpty) return null;
    if (ritualName == null || ritualName.isEmpty) return offerings.first;

    return offerings.firstWhere(
      (o) =>
          (o.name ?? '').trim().toLowerCase() ==
          ritualName.trim().toLowerCase(),
      orElse: () => offerings.first,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(typeSelected);
    final booking = ref.watch(selectedBookingProvider); // Datum
    final rescheduleState = ref.watch(rescheduleBookingProvider);

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                "Booking not found",
                style: text16(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );
    }

    final Pandit? pandit = booking.pandit;
    final Ritual? ritual = booking.ritual;
    final List<DateAndTimeElement>? dateAndTime =
        booking.dateAndTime?.dateAndTime;

    // ── Find ONLY the offering that matches the booked ritual ──
    final PoojaOffering? matchingOffering = _getMatchingOffering(
      pandit?.poojaOfferings ?? [],
      ritual?.name,
    );

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
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18),
                          ),
                          imageUrl: pandit?.profileImage ?? '',
                          width: double.infinity,
                          height: 180,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.bookingStatus),
                              borderRadius: const BorderRadius.horizontal(
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
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.bookingStatus),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              _getBookingModeStatusText(booking.bookingMode),
                              style: text12(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
                              if (booking.bookingStatus == "cancelled") return;
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

                    /// RITUAL ROW
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
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
                          CustomCachedImage(
                            borderRadius: BorderRadius.circular(8),
                            imageUrl: ritual?.image ?? '',
                            width: 50,
                            height: 60,
                          ),
                        ],
                      ),
                    ),

                    /// WHATSAPP BUTTON
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: GestureDetector(
                        onTap: () {
                          if (booking.bookingStatus == "cancelled") return;
                          openWhatsApp(pandit?.phone);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                  ],
                ),
              ),

              // ABOUT / DESCRIPTION
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

              // ── RECOMMENDED KIT SECTION ──
              // Only shown when there is a matching offering for the booked ritual.
              if (matchingOffering != null) ...[
                const SizedBox(height: 15),
                Text(
                  "Recommended Pooja Kit",
                  style: text15(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _PoojaKitSection(
                  offering: matchingOffering,
                  booking: booking,
                  panditId: pandit?.id ?? '',
                  ref: ref,
                ),
              ],

              // TEMPLE SECTION
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
                      CustomCachedImage(
                        imageUrl: booking.templeSnapshot?.image ?? '',
                        width: 50,
                        height: 60,
                      ),
                    ],
                  ),
                ),
              ],

              // HOME ADDRESS SECTION
              if (type == "home" && booking.address != null) ...[
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
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

              // ACTION BUTTONS
              if (!(booking.bookingStatus == "cancelled")) ...[
                const SizedBox(height: 20),
                if (type == "online" &&
                    booking.bookingStatus?.toLowerCase() == "confirmed")
                  AppOutlineButton(
                    title: "Join Video Call",
                    onTap: () {
                      final url = booking.zoomMeeting?.joinUrl;
                      if (url != null && url.isNotEmpty) {
                        openZoom(url);
                      }
                    },
                  ),
                const SizedBox(height: 15),
                AppOutlineButton(
                  title: rescheduleState.isLoading
                      ? "Rescheduling..."
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
                      ref.invalidate(panditBookingProvider);
                      Navigator.pop(context);
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

  String formatDate(DateTime date) =>
      "${date.day} ${getMonth(date.month)} ${date.year}";

  String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

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

    return DateTimeSlot(
      date: formatDate(selectedDate),
      time: "${formatTime(startTime)} - ${formatTime(endTime)}",
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PoojaKitSection
//
// Decides WHAT to render based on the offering's kit flags:
//
//   customSamagri == true  →  show pandit's custom samagri items (existing _PoojaCard)
//   customSamagri == false AND booking.recommendedKit != null
//                          →  show "Samagran Kit" special card
//   customSamagri == false AND booking.recommendedKit == null
//                          →  show disabled/blurred "Samagran Kit" radio option
// ─────────────────────────────────────────────────────────────────────────────
class _PoojaKitSection extends StatelessWidget {
  const _PoojaKitSection({
    required this.offering,
    required this.booking,
    required this.panditId,
    required this.ref,
  });

  final PoojaOffering offering;
  final Datum booking;
  final String panditId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final bool hasCustomSamagri = offering.customSamagri == true;
    final bool hasRecommendedKit = booking.recommendedKit != null;

    // 1️⃣  Custom samagri from pandit → render the full card
    if (hasCustomSamagri) {
      return _PoojaCard(pooja: offering, panditId: panditId, ref: ref);
    }

    // 2️⃣  Special / standard Samagran Kit available
    if (hasRecommendedKit) {
      return _SamagranKitCard(kit: booking.recommendedKit!, enabled: true);
    }

    // 3️⃣  No kit available → show disabled Samagran Kit option
    return _SamagranKitCard(kit: null, enabled: false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SamagranKitCard
//
// Renders an active or disabled "Samagran Kit" radio-style tile.
// `kit` mirrors Datum.recommendedKit which is typed as `dynamic` in the model
// (currently always null from the API — wire up your RecommendedKit type here
// once the backend sends it).
// ─────────────────────────────────────────────────────────────────────────────
class _SamagranKitCard extends StatelessWidget {
  const _SamagranKitCard({required this.kit, required this.enabled});

  // ignore: avoid-dynamic — mirrors Datum.recommendedKit until a typed model exists
  final dynamic kit;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled ? const Color(0xFFFFD38A) : Colors.grey.shade300,
              width: 1.2,
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: enabled
                        ? const Color(0xFFB8860B)
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: enabled
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFB8860B),
                          ),
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 12),

              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: enabled
                      ? const Color(0xFFFFF8E1)
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  size: 22,
                  color: enabled
                      ? const Color(0xFFB8860B)
                      : Colors.grey.shade400,
                ),
              ),

              const SizedBox(width: 12),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Samagran Kit',
                      style: text14(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? const Color(0xFFB8860B)
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      enabled
                          ? 'Curated kit for this pooja'
                          : 'Not available for this pooja',
                      style: text12(
                        color: enabled
                            ? AppColors.textSecondary
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              if (!enabled)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PoojaCard  (unchanged logic, just receives ONE matched offering)
// ─────────────────────────────────────────────────────────────────────────────
class _PoojaCard extends StatelessWidget {
  const _PoojaCard({
    required this.pooja,
    required this.panditId,
    required this.ref,
  });

  final PoojaOffering pooja;
  final String panditId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notes = pooja.customSamagriNotes
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 15,
                color: Color(0xFFB8860B),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  pooja.name ?? 'Pooja',
                  style: text14(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          if (pooja.description != null && pooja.description!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              pooja.description!,
              style: text13(
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
            ),
          ],

          const SizedBox(height: 10),

          // Tags
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              if (pooja.durationHours != null)
                _Tag(Icons.schedule_outlined, '${pooja.durationHours} hrs'),
              if (pooja.standardSamagri == true)
                _Tag(Icons.check_circle_outline_rounded, 'Samagri included'),
              if (pooja.customSamagri == true)
                _Tag(Icons.shopping_bag_outlined, 'Custom samagri'),
              if (pooja.travelForSpecialPooja == true)
                _Tag(Icons.luggage_outlined, 'Travel available'),
            ],
          ),

          // Samagri notes
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8CC6A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: Color(0xFF9E7500),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Note',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E7500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ...notes.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        n,
                        style: text12(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Samagri kit link → renamed label to "Samagran Kit"
          if (pooja.customSamagriItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                ref.read(panditIdProvider.notifier).state = panditId;
                Navigator.pushNamed(
                  context,
                  AppRoutes.panditRecKit,
                  arguments: pooja.customSamagriItems,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF8E1), Color(0xFFFFF0C4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFFFD38A),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 26,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Samagran Kit', // ← renamed from "Recommended Samagran kit"
                            style: text15(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFB8860B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${pooja.customSamagriItems.length} items included',
                            style: text13(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: Color(0xFFB8860B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF555555)),
          const SizedBox(width: 5),
          Text(
            label,
            style: text12(
              color: const Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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
      return "Accepted";
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
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.button
                            : AppColors.grey400,
                      ),
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
