import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:samagrah/model/request/payment_req/pandit_create_order_req_model.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
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
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';
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

  /// Returns the single PoojaOffering that EXACTLY matches the booked ritual
  /// name. Returns null if there's no exact match — we must never show kit
  /// data for an unrelated pooja.
  PoojaOffering? _getMatchingOffering(
    List<PoojaOffering> offerings,
    String? ritualName,
  ) {
    if (offerings.isEmpty) return null;
    if (ritualName == null || ritualName.isEmpty) return null;

    final normalizedRitual = ritualName.trim().toLowerCase();

    for (final offering in offerings) {
      if ((offering.name ?? '').trim().toLowerCase() == normalizedRitual) {
        return offering;
      }
    }
    return null; // ✅ no fallback to a random offering anymore
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

    // ── Find ONLY the offering that exactly matches the booked ritual ──
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
              // Only shown when there is an EXACT matching offering for the
              // booked ritual. No fallback — agar match nahi to kuch nahi.
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
                    title: "Join Pooja",
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
                    final selectedSlot = await showRescheduleTimeSlotSheet(
                      context: context,
                      booking: booking,
                      pandit: pandit,
                      matchingOffering: matchingOffering,
                    );
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
                    showCancelOrderBottomSheet(context, ref, booking);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}

String? _dateApi(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  try {
    final date = DateTime.parse(raw);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  } catch (_) {
    return raw;
  }
}

Future<DateTimeSlot?> showRescheduleTimeSlotSheet({
  required BuildContext context,
  required Datum booking,
  required Pandit? pandit,
  required PoojaOffering? matchingOffering,
}) {
  final panditId = pandit?.id ?? '';
  if (panditId.isEmpty) return Future.value(null);

  return showModalBottomSheet<DateTimeSlot>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RescheduleSlotSheet(
      panditId: panditId,
      currentBookingDate: _dateApi(booking.bookingDate),
      durationHours:
          (matchingOffering?.durationHours ?? booking.ritualRef?.durationHours)
              ?.ceil() ??
          1,
    ),
  );
}

class _RescheduleSlotSheet extends ConsumerStatefulWidget {
  const _RescheduleSlotSheet({
    required this.panditId,
    required this.currentBookingDate,
    required this.durationHours,
  });

  final String panditId;
  final String? currentBookingDate;
  final int durationHours;

  @override
  ConsumerState<_RescheduleSlotSheet> createState() =>
      _RescheduleSlotSheetState();
}

class _RescheduleSlotSheetState extends ConsumerState<_RescheduleSlotSheet> {
  int? _selectedDateIndex;
  bool _customMode = false;
  DateTimeSlot? _selectedSlot;
  DateTime? _customDate;
  TimeOfDay? _customStart;
  TimeOfDay? _customEnd;

  String _dateApi(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  String _displayDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  String _tod(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "$hour:$minute $period";
  }

  TimeOfDay? _parseTimeOfDay(String raw) {
    try {
      final parts = raw.trim().split(' ');
      if (parts.length < 2) return null;
      final hm = parts.first.split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      final period = parts[1].toUpperCase();
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  int _toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  String _formatMinutes(int minutes) {
    final safeMinutes = minutes % (24 * 60);
    final hour24 = safeMinutes ~/ 60;
    final minute = safeMinutes % 60;
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  ({int start, int end})? _slotRange(Slot slot) {
    final time = slot.time;
    if (time == null || time.trim().isEmpty) return null;
    final parts = time.split(' - ');
    final start = _parseTimeOfDay(parts.first.trim());
    if (start == null) return null;

    final startMinutes = _toMinutes(start);
    if (parts.length < 2) return (start: startMinutes, end: startMinutes + 60);

    final end = _parseTimeOfDay(parts[1].trim());
    if (end == null) return null;
    var endMinutes = _toMinutes(end);
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    return (start: startMinutes, end: endMinutes);
  }

  bool _isPastDate(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      return DateTime(
        d.year,
        d.month,
        d.day,
      ).isBefore(DateTime(now.year, now.month, now.day));
    } catch (_) {
      return false;
    }
  }

  bool _isPastSlot(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return false;
    try {
      final d = DateTime.parse(dateStr);
      final now = DateTime.now();
      if (d.year != now.year || d.month != now.month || d.day != now.day) {
        return false;
      }
      final start = _parseTimeOfDay(timeStr.split(' - ').first.trim());
      if (start == null) return false;
      return DateTime(
        now.year,
        now.month,
        now.day,
        start.hour,
        start.minute,
      ).isBefore(now);
    } catch (_) {
      return false;
    }
  }

  List<Slot> _durationSlots(String date, List<Slot> sourceSlots) {
    final requiredMinutes = widget.durationHours.clamp(1, 24) * 60;
    final ranges = sourceSlots
        .where(
          (slot) =>
              slot.status?.toLowerCase() == 'available' &&
              !_isPastSlot(date, slot.time),
        )
        .map((slot) => _slotRange(slot))
        .whereType<({int start, int end})>()
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final result = <Slot>[];
    final seen = <String>{};
    for (final startRange in ranges) {
      final targetEnd = startRange.start + requiredMinutes;
      var cursor = startRange.start;

      while (cursor < targetEnd) {
        ({int start, int end})? nextRange;
        for (final range in ranges) {
          if (range.start <= cursor && range.end > cursor) {
            nextRange = range;
            break;
          }
        }
        if (nextRange == null) break;
        cursor = nextRange.end;
      }

      if (cursor >= targetEnd) {
        final time =
            '${_formatMinutes(startRange.start)} - ${_formatMinutes(targetEnd)}';
        if (seen.add(time)) result.add(Slot(time: time, status: 'available'));
      }
    }
    return result;
  }

  Future<void> _pickCustomDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _customDate = picked);
  }

  Future<void> _pickCustomStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Start Time',
    );
    if (picked != null) setState(() => _customStart = picked);
  }

  Future<void> _pickCustomEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _customStart == null
          ? TimeOfDay.now()
          : TimeOfDay(
              hour: (_customStart!.hour + widget.durationHours).clamp(0, 23),
              minute: _customStart!.minute,
            ),
      helpText: 'Select End Time',
    );
    if (picked != null) setState(() => _customEnd = picked);
  }

  DateTimeSlot? _customSlot() {
    if (_customDate == null || _customStart == null || _customEnd == null) {
      return null;
    }
    return DateTimeSlot(
      date: _dateApi(_customDate!),
      time: '${_tod(_customStart!)} - ${_tod(_customEnd!)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final availabilityAsync = ref.watch(
      panditAvailabilityProvider(widget.panditId),
    );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 14,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
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
              const SizedBox(height: 18),
              Text(
                "Reschedule Booking",
                style: text18(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Available slots are shown for ${widget.durationHours} hour ritual duration.",
                style: text12(color: AppColors.grey600),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: availabilityAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.button),
                  ),
                  error: (_, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Could not load available slots",
                          style: text14(color: AppColors.grey600),
                        ),
                        TextButton(
                          onPressed: () => ref.invalidate(
                            panditAvailabilityProvider(widget.panditId),
                          ),
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                  data: (res) {
                    final dates = (res.data?.availability ?? [])
                        .where((item) {
                          final date = item.date ?? '';
                          return !_isPastDate(date) &&
                              item.status?.toLowerCase() == 'available' &&
                              _durationSlots(date, item.slots).isNotEmpty;
                        })
                        .toList();

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 112,
                          child: ListView.builder(
                            itemCount: dates.length + 1,
                            itemBuilder: (context, index) {
                              if (index == dates.length) {
                                return _RescheduleDateTile(
                                  title: "Custom",
                                  subtitle: "Request",
                                  selected: _customMode,
                                  enabled: true,
                                  isCurrentBooking: false,
                                  onTap: () => setState(() {
                                    _customMode = true;
                                    _selectedDateIndex = null;
                                    _selectedSlot = null;
                                  }),
                                );
                              }

                              final item = dates[index];
                              final available =
                                  item.status?.toLowerCase() == 'available';
                              final selected =
                                  !_customMode && _selectedDateIndex == index;
                              final isCurrentBooking =
                                  item.date == widget.currentBookingDate;
                              return _RescheduleDateTile(
                                title: _dayNum(item.date),
                                subtitle: _monthShort(item.date),
                                selected: selected,
                                enabled: available,
                                isCurrentBooking: isCurrentBooking,
                                onTap: available
                                    ? () => setState(() {
                                          _customMode = false;
                                          _selectedDateIndex = index;
                                          _selectedSlot = null;
                                        })
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _customMode
                              ? _CustomReschedulePicker(
                                  customDate: _customDate,
                                  customStart: _customStart,
                                  customEnd: _customEnd,
                                  displayDate: (date) =>
                                      DateFormat('dd MMM yyyy').format(date),
                                  tod: _tod,
                                  onPickDate: _pickCustomDate,
                                  onPickStart: _pickCustomStart,
                                  onPickEnd: _pickCustomEnd,
                                )
                              : _selectedDateIndex == null
                              ? Center(
                                  child: Text(
                                    "Select a date to view slots",
                                    style: text13(color: AppColors.grey600),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : _AvailableRescheduleSlots(
                                  date: dates[_selectedDateIndex!].date ?? '',
                                  displayDate: _displayDate,
                                  slots: _durationSlots(
                                    dates[_selectedDateIndex!].date ?? '',
                                    dates[_selectedDateIndex!].slots,
                                  ),
                                  selectedSlot: _selectedSlot,
                                  onSelect: (slot) =>
                                      setState(() => _selectedSlot = slot),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                title: "Confirm Reschedule",
                onTap: () {
                  final slot = _customMode ? _customSlot() : _selectedSlot;
                  if (slot == null) {
                    AppSnackbar.show(
                      context,
                      message: "Please select date and time",
                      type: SnackBarType.warning,
                    );
                    return;
                  }
                  Navigator.pop(context, slot);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayNum(String? date) {
    try {
      return date!.split('-')[2].replaceAll(RegExp(r'^0'), '');
    } catch (_) {
      return date ?? '';
    }
  }

  String _monthShort(String? date) {
    try {
      return getMonth(int.parse(date!.split('-')[1]));
    } catch (_) {
      return '';
    }
  }
}

class _RescheduleDateTile extends StatelessWidget {
  const _RescheduleDateTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.isCurrentBooking,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final bool isCurrentBooking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.button
              : isCurrentBooking
              ? AppColors.button.withOpacity(0.08)
              : enabled
              ? Colors.white
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected || isCurrentBooking
                ? AppColors.button
                : Colors.grey.shade200,
            width: selected || isCurrentBooking ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: selected
                    ? Colors.white
                    : enabled
                    ? AppColors.textPrimary
                    : Colors.grey.shade400,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: selected
                    ? Colors.white70
                    : enabled
                    ? AppColors.grey600
                    : Colors.grey.shade400,
              ),
            ),
            if (isCurrentBooking) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.18)
                      : AppColors.button.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Current",
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.button,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AvailableRescheduleSlots extends StatelessWidget {
  const _AvailableRescheduleSlots({
    required this.date,
    required this.displayDate,
    required this.slots,
    required this.selectedSlot,
    required this.onSelect,
  });

  final String date;
  final String Function(String) displayDate;
  final List<Slot> slots;
  final DateTimeSlot? selectedSlot;
  final ValueChanged<DateTimeSlot> onSelect;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return Center(
        child: Text(
          "No slots available for this date",
          style: text13(color: AppColors.grey600),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(displayDate(date), style: text14(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: slots.length,
            itemBuilder: (context, index) {
              final slot = slots[index];
              final current = DateTimeSlot(date: date, time: slot.time ?? '');
              final selected =
                  selectedSlot?.date == current.date &&
                  selectedSlot?.time == current.time;
              return GestureDetector(
                onTap: () => onSelect(current),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.button.withOpacity(0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.button : Colors.grey.shade200,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: selected ? AppColors.button : AppColors.grey400,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          current.time,
                          style: text13(
                            color: selected
                                ? AppColors.button
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.button,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CustomReschedulePicker extends StatelessWidget {
  const _CustomReschedulePicker({
    required this.customDate,
    required this.customStart,
    required this.customEnd,
    required this.displayDate,
    required this.tod,
    required this.onPickDate,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final DateTime? customDate;
  final TimeOfDay? customStart;
  final TimeOfDay? customEnd;
  final String Function(DateTime) displayDate;
  final String Function(TimeOfDay) tod;
  final VoidCallback onPickDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text("Custom Date & Time", style: text14(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        _CustomPickerRow(
          icon: Icons.calendar_today_outlined,
          label: customDate == null ? "Select date" : displayDate(customDate!),
          onTap: onPickDate,
        ),
        _CustomPickerRow(
          icon: Icons.access_time_rounded,
          label: customStart == null ? "Start time" : tod(customStart!),
          onTap: onPickStart,
        ),
        _CustomPickerRow(
          icon: Icons.timelapse_rounded,
          label: customEnd == null ? "End time" : tod(customEnd!),
          onTap: onPickEnd,
        ),
      ],
    );
  }
}

class _CustomPickerRow extends StatelessWidget {
  const _CustomPickerRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.button),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: text13())),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PoojaKitSection
//
// Client-required flow (3 cases ONLY):
//   1) customSamagri == true        → show pandit's custom kit items
//   2) booking.recommendedKit != null → show the special/recommended kit
//   3) neither                      → show Standard Kit radio, blurred + disabled
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
    final bool hasStandardSamagri = offering.standardSamagri == true;
    final bool canBuyRecommendedKit = _canBuyRecommendedKit(booking);

    // 1️⃣  Customize kit selected by pandit → show items added by him
    if (hasCustomSamagri) {
      return _PoojaCard(
        pooja: offering,
        panditId: panditId,
        ref: ref,
        enabled: canBuyRecommendedKit,
      );
    }

    // 2️⃣  Special / recommended Samagran Kit available → show it
    if (hasStandardSamagri) {
      final kitId = offering.kitId;

      if (kitId == null || kitId.isEmpty) {
        return _SamagranKitCard(enabled: false, panditId: panditId);
      }

      return ref
          .watch(userDraftKits)
          .when(
            loading: () => const _StandardKitLoadingCard(),
            error: (_, _) =>
                _SamagranKitCard(enabled: false, panditId: panditId),
            data: (kitState) {
              final kits = kitState.defaultKit?.data ?? [];
              DefaultKitData? matchedKit;

              for (final kit in kits) {
                if (kit.id == kitId) {
                  matchedKit = kit;
                  break;
                }
              }

              if (matchedKit == null) {
                return _SamagranKitCard(enabled: false, panditId: panditId);
              }

              return _SamagranKitCard(
                kit: matchedKit,
                enabled: canBuyRecommendedKit,
                ref: ref,
                panditId: panditId,
              );
            },
          );
    }

    // 3️⃣  Nothing available → Standard Kit radio, blurred + disabled
    return _SamagranKitCard(enabled: false, panditId: panditId);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SamagranKitCard

// ─────────────────────────────────────────────────────────────────────────────
bool _canBuyRecommendedKit(Datum booking) {
  final status = (booking.bookingStatus ?? '').toLowerCase();
  return status == 'confirmed' || status == 'completed';
}

class _SamagranKitCard extends StatelessWidget {
  const _SamagranKitCard({
    this.kit,
    required this.enabled,
    this.ref,
    required this.panditId,
  });

  // ignore: avoid-dynamic — mirrors Datum.recommendedKit until a typed model exists
  final DefaultKitData? kit;
  final bool enabled;
  final WidgetRef? ref;
  final String panditId;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: GestureDetector(
          onTap: enabled && kit != null
              ? () {
                  ref?.read(panditIdProvider.notifier).state = panditId;
                  ref
                      ?.read(customizeKitProvider.notifier)
                      .initializeFromDefault(kit!);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.festivalKitDetails,
                    arguments: kit,
                  );
                }
              : null,
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
                        enabled
                            ? (kit?.name ?? 'Standard Kit')
                            : 'Standard Kit',
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
                            ? '${kit?.items.length ?? 0} items included'
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

                if (enabled)
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFFB8860B),
                  )
                else
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PoojaCard  (unchanged logic, just receives ONE matched offering)
// ─────────────────────────────────────────────────────────────────────────────
class _StandardKitLoadingCard extends StatelessWidget {
  const _StandardKitLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD38A), width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading standard kit...',
            style: text13(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _PoojaCard extends StatelessWidget {
  const _PoojaCard({
    required this.pooja,
    required this.panditId,
    required this.ref,
    required this.enabled,
  });

  final PoojaOffering pooja;
  final String panditId;
  final WidgetRef ref;
  final bool enabled;

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

          // Samagri kit link → "Samagran Kit" (pandit's custom items)
          if (pooja.customSamagriItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: enabled
                  ? () {
                      ref.read(panditIdProvider.notifier).state = panditId;
                      Navigator.pushNamed(
                        context,
                        AppRoutes.panditRecKit,
                        arguments: pooja.customSamagriItems,
                      );
                    }
                  : () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Recommended kit can be purchased after pandit accepts the booking.',
                        ),
                      ),
                    ),
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
                            'Samagran Kit',
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
  Datum booking,
) {
  final orderId = booking.id ?? '';
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
                              arguments: {
                                'poojaName':
                                    booking.ritual?.name ??
                                    booking.ritualRef?.title ??
                                    'Pooja',
                                'panditName':
                                    booking.pandit?.fullName ?? 'Pandit Ji',
                                'panditImage':
                                    booking.pandit?.profileImage ?? '',
                                'bookingDate': booking.bookingDate ?? '',
                              },
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
                SizedBox(height: 20),
              ],
            ),
          );
        },
      );
    },
  );
}
