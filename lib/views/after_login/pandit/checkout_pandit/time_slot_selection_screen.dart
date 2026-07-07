import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class TimeSlotSelectionScreen extends ConsumerStatefulWidget {
  const TimeSlotSelectionScreen({super.key});

  @override
  ConsumerState<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState
    extends ConsumerState<TimeSlotSelectionScreen> {
  int? _selectedDateIndex;

  bool _showCustomPicker = false;

  final Map<String, List<Slot>> _selectedSlots = {};

  DateTime? _customDate;
  TimeOfDay? _customTimeStart;
  TimeOfDay? _customTimeEnd;

  static String getMonth(int month) {
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

  String _formatDate(String raw) {
    try {
      final parts = raw.split('-');
      if (parts.length < 3) return raw;
      return "${int.parse(parts[2])} ${getMonth(int.parse(parts[1]))} ${parts[0]}";
    } catch (_) {
      return raw;
    }
  }

  int get _totalSelected =>
      _selectedSlots.values.fold(0, (sum, list) => sum + list.length) +
      (_customDate != null && _customTimeStart != null ? 1 : 0);

  void _toggleSlot(String date, Slot slot) {
    setState(() {
      final list = _selectedSlots[date] ?? [];
      final exists = list.any((s) => s.time == slot.time);
      if (exists) {
        list.removeWhere((s) => s.time == slot.time);
        if (list.isEmpty) {
          _selectedSlots.remove(date);
        } else {
          _selectedSlots[date] = list;
        }
      } else {
        _selectedSlots[date] = [...list, slot];
      }
    });
  }

  bool _isSlotSelected(String date, Slot slot) {
    return (_selectedSlots[date] ?? []).any((s) => s.time == slot.time);
  }

  String _tod(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return "$h:$m $p";
  }

  Future<void> _pickCustomDate(DateTime minDate) async {
    final firstSelectableDate = DateTime(
      minDate.year,
      minDate.month,
      minDate.day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: firstSelectableDate,
      firstDate: firstSelectableDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.button,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _customDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.button)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customTimeStart = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _customTimeStart != null
          ? TimeOfDay(
              hour: (_customTimeStart!.hour + 1).clamp(0, 23),
              minute: _customTimeStart!.minute,
            )
          : const TimeOfDay(hour: 11, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(
          ctx,
        ).copyWith(colorScheme: ColorScheme.light(primary: AppColors.button)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _customTimeEnd = picked);
  }

  // ── FIX: Strip the time component so today's date compares correctly ──
  bool _isPastDate(String? dateStr) {
    if (dateStr == null) return false;
    try {
      final d = DateTime.parse(dateStr);
      final today = DateTime.now();
      final todayMidnight = DateTime(today.year, today.month, today.day);
      final dateMidnight = DateTime(d.year, d.month, d.day);
      return dateMidnight.isBefore(todayMidnight);
    } catch (_) {
      return false;
    }
  }

  // ── FIX: Check whether a slot's start time has already passed today ──
  bool _isPastSlot(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return false;
    try {
      final d = DateTime.parse(dateStr);
      final today = DateTime.now();
      // Only relevant for today's date
      final isToday =
          d.year == today.year && d.month == today.month && d.day == today.day;
      if (!isToday) return false;

      // Parse the start time from strings like "9:00 AM - 11:00 AM" or "9:00 AM"
      final startPart = timeStr.split(' - ').first.trim();
      final parsed = _parseTimeOfDay(startPart);
      if (parsed == null) return false;

      final slotDateTime = DateTime(
        today.year,
        today.month,
        today.day,
        parsed.hour,
        parsed.minute,
      );
      return slotDateTime.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  /// Parses "9:00 AM" or "11:30 PM" into a TimeOfDay
  TimeOfDay? _parseTimeOfDay(String raw) {
    try {
      final parts = raw.trim().split(' ');
      if (parts.length < 2) return null;
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
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

  List<Slot> _durationSlotsForDate(
    String date,
    List<Slot> sourceSlots,
    int poojaDurationHours,
  ) {
    final requiredMinutes = poojaDurationHours.clamp(1, 24) * 60;
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

  String _normalizePoojaName(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
  }

  int _poojaDurationHours(PanditData pandit) {
    final ritual = ref.read(selectedRitualProvider);
    final ritualNames = {
      _normalizePoojaName(ritual?.name),
      _normalizePoojaName(ritual?.title),
    }..remove('');

    PoojaOffering? matchedOffering;
    for (final offering in pandit.poojaOfferings) {
      if (ritualNames.contains(_normalizePoojaName(offering.name))) {
        matchedOffering = offering;
        break;
      }
    }

    for (final offering in pandit.poojaOfferings) {
      if (matchedOffering == null && offering.isSelected == true) {
        matchedOffering = offering;
        break;
      }
    }

    final duration = matchedOffering?.durationHours ?? ritual?.durationHours;
    if (duration == null || duration <= 0) return 1;
    return duration.ceil();
  }

  @override
  Widget build(BuildContext context) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;
    final availAsync = ref.watch(panditAvailabilityProvider(pandit.id ?? ''));
    final poojaDurationHours = _poojaDurationHours(pandit);

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
            _StepIndicator(),
            Expanded(
              child: availAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.button),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: AppColors.grey400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Could not load availability",
                        style: text14(color: AppColors.grey600),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(
                          panditAvailabilityProvider(pandit.id ?? ''),
                        ),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
                data: (res) {
                  final availability = res.data?.availability ?? [];
                  final customMinDate = DateTime.now();

                  // ── FIX 1: Exclude dates that are strictly in the past ──
                  final allDates = availability
                      .where((a) {
                        final date = a.date ?? '';
                        return !_isPastDate(date) &&
                            a.status?.toLowerCase() == 'available' &&
                            _durationSlotsForDate(
                              date,
                              a.slots,
                              poojaDurationHours,
                            ).isNotEmpty;
                      })
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusLegend(),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                        child: Row(
                          children: [
                            Text(
                              "Select Date & Time",
                              style: text20(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (_totalSelected > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.button.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  "$_totalSelected selected",
                                  style: text12(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Left: Date list ──
                            SizedBox(
                              width: 120,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 8,
                                  bottom: 16,
                                ),
                                itemCount: allDates.length + 1,
                                itemBuilder: (context, i) {
                                  if (i == allDates.length) {
                                    return _CustomDateTile(
                                      isActive: _showCustomPicker,
                                      onTap: () => setState(() {
                                        _showCustomPicker = true;
                                        _selectedDateIndex = null;
                                      }),
                                    );
                                  }

                                  final item = allDates[i];
                                  final date = item.date ?? '';
                                  final status =
                                      item.status?.toLowerCase() ?? '';
                                  final isSelected =
                                      _selectedDateIndex == i &&
                                      !_showCustomPicker;
                                  final hasSlots =
                                      (_selectedSlots[date] ?? []).isNotEmpty;
                                  final isAvailable = status == 'available';

                                  return GestureDetector(
                                    onTap: isAvailable
                                        ? () => setState(() {
                                            _selectedDateIndex = i;
                                            _showCustomPicker = false;
                                          })
                                        : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.button
                                            : !isAvailable
                                            ? Colors.grey.shade100
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.button
                                              : hasSlots
                                              ? AppColors.button.withOpacity(
                                                  0.4,
                                                )
                                              : Colors.grey.shade200,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            _dayNum(date),
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : !isAvailable
                                                  ? Colors.grey.shade400
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                          Text(
                                            _monthShort(date),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? Colors.white70
                                                  : !isAvailable
                                                  ? Colors.grey.shade400
                                                  : AppColors.grey600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          _DateStatusBadge(
                                            status: status,
                                            isSelected: isSelected,
                                          ),
                                          if (hasSlots && isAvailable) ...[
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Colors.white.withOpacity(
                                                        0.25,
                                                      )
                                                    : AppColors.button
                                                          .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                "${(_selectedSlots[date] ?? []).length}✓",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : AppColors.button,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // ── Right: Slot panel or Custom picker ──
                            Expanded(
                              child: _showCustomPicker
                                  ? _CustomDateTimePicker(
                                      customMinDate: customMinDate,
                                      customDate: _customDate,
                                      customTimeStart: _customTimeStart,
                                      customTimeEnd: _customTimeEnd,
                                      onPickDate: () =>
                                          _pickCustomDate(customMinDate),
                                      onPickStart: _pickStartTime,
                                      onPickEnd: _pickEndTime,
                                      tod: _tod,
                                    )
                                  : _selectedDateIndex == null
                                  ? _EmptySlotHint()
                                  : _SlotPanel(
                                      availability:
                                          allDates[_selectedDateIndex!],
                                      formatDate: _formatDate,
                                      isSelected: _isSlotSelected,
                                      onToggle: _toggleSlot,
                                      // ── FIX 2: pass slot-past checker ──
                                      isPastSlot: _isPastSlot,
                                      poojaDurationHours: poojaDurationHours,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // ── Bottom bar ──
            _BottomBar(
              totalSelected: _totalSelected,
              selectedSlots: _selectedSlots,
              customDate: _customDate,
              customTimeStart: _customTimeStart,
              customTimeEnd: _customTimeEnd,
              tod: _tod,
              onNext: () {
                if (_totalSelected == 0) {
                  AppSnackbar.show(
                    context,
                    message: 'Please select at least one time slot',
                    type: SnackBarType.info,
                  );
                  return;
                }

                final formatted = <Map<String, String>>[];
                _selectedSlots.forEach((date, slots) {
                  for (final s in slots) {
                    formatted.add({
                      'date': date,
                      'time_slot': s.time ?? '',
                      'status': s.status ?? 'available',
                    });
                  }
                });

                if (_customDate != null && _customTimeStart != null) {
                  final dateStr =
                      "${_customDate!.year}-${_customDate!.month.toString().padLeft(2, '0')}-${_customDate!.day.toString().padLeft(2, '0')}";
                  final timeStr = _customTimeEnd != null
                      ? "${_tod(_customTimeStart!)} - ${_tod(_customTimeEnd!)}"
                      : _tod(_customTimeStart!);
                  formatted.add({
                    'date': dateStr,
                    'time_slot': timeStr,
                    'status': 'custom_request',
                  });
                }

                ref.read(selectedDateProvider.notifier).state = formatted;

                final service = ref.read(selectedServiceProvider);
                if (service?.type == "home") {
                  Navigator.pushNamed(context, AppRoutes.addressSelection);
                } else if (service?.type == "online") {
                  Navigator.pushNamed(context, AppRoutes.onlineDetails);
                } else {
                  Navigator.pushNamed(context, AppRoutes.templeSelection);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _dayNum(String date) {
    try {
      return date.split('-')[2].replaceAll(RegExp(r'^0'), '');
    } catch (_) {
      return date;
    }
  }

  String _monthShort(String date) {
    try {
      return getMonth(int.parse(date.split('-')[1]));
    } catch (_) {
      return '';
    }
  }
}

// ── Date Status Badge ───────────────────────────────────────────────────────
class _DateStatusBadge extends StatelessWidget {
  const _DateStatusBadge({required this.status, required this.isSelected});
  final String status;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    String label;
    IconData icon;

    switch (status) {
      case 'available':
        bg = const Color(0xFF22C55E).withOpacity(0.15);
        textColor = const Color(0xFF16A34A);
        label = 'Open';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'booked':
        bg = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade700;
        label = 'Booked';
        icon = Icons.event_busy_rounded;
        break;
      default:
        bg = Colors.red.withOpacity(0.10);
        textColor = Colors.red.shade400;
        label = 'N/A';
        icon = Icons.block_rounded;
    }

    if (isSelected) {
      bg = Colors.white.withOpacity(0.2);
      textColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: textColor),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status Legend ───────────────────────────────────────────────────────────
class _StatusLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _LegendDot(color: const Color(0xFF22C55E), label: 'Available'),
          const SizedBox(width: 14),
          _LegendDot(color: Colors.orange, label: 'Booked'),
          const SizedBox(width: 14),
          _LegendDot(color: Colors.red.shade300, label: 'Not Available'),
          const Spacer(),
          _LegendDot(
            color: const Color(0xFF6366F1),
            label: 'Custom',
            icon: Icons.edit_calendar_rounded,
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, this.icon});
  final Color color;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon != null
            ? Icon(icon, size: 11, color: color)
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

// ── Custom Date Tile ────────────────────────────────────────────────────────
class _CustomDateTile extends StatelessWidget {
  const _CustomDateTile({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF6366F1)
                : const Color(0xFF6366F1).withOpacity(0.35),
            width: isActive ? 2 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              Icons.edit_calendar_rounded,
              size: 22,
              color: isActive ? Colors.white : const Color(0xFF6366F1),
            ),
            const SizedBox(height: 5),
            Text(
              "Custom\nDate",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : const Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom Date Time Picker Panel ───────────────────────────────────────────
class _CustomDateTimePicker extends StatelessWidget {
  const _CustomDateTimePicker({
    required this.customMinDate,
    required this.customDate,
    required this.customTimeStart,
    required this.customTimeEnd,
    required this.onPickDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.tod,
  });

  final DateTime customMinDate;
  final DateTime? customDate;
  final TimeOfDay? customTimeStart;
  final TimeOfDay? customTimeEnd;
  final VoidCallback onPickDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final String Function(TimeOfDay) tod;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16, top: 4),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_calendar_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Request Custom Date",
                    style: text13(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Colors.amber.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Please note",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "Agar Pandit Ji is date ko unavailable hain, to booking reject ho sakti hai. Aise case mein full amount aapke wallet mein refund kar diya jayega.",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _PickerRow(
              icon: Icons.calendar_today_outlined,
              label: "Select Date",
              value: customDate != null
                  ? "${customDate!.day} ${_monthN(customDate!.month)} ${customDate!.year}"
                  : null,
              hint:
                  "From ${_monthN(customMinDate.month)} ${customMinDate.day}",
              onTap: onPickDate,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 10),

            _PickerRow(
              icon: Icons.schedule_rounded,
              label: "Start Time",
              value: customTimeStart != null ? tod(customTimeStart!) : null,
              hint: "Tap to select",
              onTap: customDate != null ? onPickStart : null,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 10),

            _PickerRow(
              icon: Icons.schedule_outlined,
              label: "End Time",
              value: customTimeEnd != null ? tod(customTimeEnd!) : null,
              hint: "Optional",
              onTap: customDate != null && customTimeStart != null
                  ? onPickEnd
                  : null,
              color: const Color(0xFF6366F1),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_clock_outlined,
                    size: 14,
                    color: const Color(0xFF6366F1).withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Aaj se future dates select kar sakte hain",
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF6366F1).withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _monthN(int m) {
    const mm = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return mm[m];
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hint,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String? value;
  final String hint;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: value != null
              ? color.withOpacity(0.07)
              : enabled
              ? Colors.white
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value != null
                ? color.withOpacity(0.6)
                : Colors.grey.shade200,
            width: value != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: value != null
                    ? color.withOpacity(0.12)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 17,
                color: value != null ? color : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                  Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: value != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: value != null
                          ? color
                          : enabled
                          ? Colors.grey.shade500
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade200,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
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
                "2",
                style: text14(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Date & Time",
                    style: text16(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tap a date, then select your preferred slot",
                    style: text12(color: AppColors.grey600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                "2 / 3",
                style: text12(
                  color: AppColors.warningDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slot Panel ──────────────────────────────────────────────────────────────
class _SlotPanel extends StatelessWidget {
  const _SlotPanel({
    required this.availability,
    required this.formatDate,
    required this.isSelected,
    required this.onToggle,
    required this.isPastSlot, // ── FIX 2
    required this.poojaDurationHours,
  });

  final Availability availability;
  final String Function(String) formatDate;
  final bool Function(String, Slot) isSelected;
  final void Function(String, Slot) onToggle;
  final bool Function(String?, String?) isPastSlot; // ── FIX 2
  final int poojaDurationHours;

  TimeOfDay? _parseTimeOfDay(String raw) {
    try {
      final parts = raw.trim().split(' ');
      if (parts.length < 2) return null;
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
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
    if (parts.length < 2) {
      return (start: startMinutes, end: startMinutes + 60);
    }

    final end = _parseTimeOfDay(parts[1].trim());
    if (end == null) return null;

    var endMinutes = _toMinutes(end);
    if (endMinutes <= startMinutes) endMinutes += 24 * 60;
    return (start: startMinutes, end: endMinutes);
  }

  List<Slot> _buildDurationSlots(String date, List<Slot> sourceSlots) {
    final requiredMinutes = poojaDurationHours.clamp(1, 24) * 60;
    final ranges = sourceSlots
        .where(
          (s) =>
              s.status?.toLowerCase() == 'available' &&
              !isPastSlot(date, s.time),
        )
        .map((slot) {
          final range = _slotRange(slot);
          if (range == null) return null;
          return (slot: slot, start: range.start, end: range.end);
        })
        .whereType<({Slot slot, int start, int end})>()
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final result = <Slot>[];
    final seen = <String>{};

    for (final startRange in ranges) {
      final targetEnd = startRange.start + requiredMinutes;
      var cursor = startRange.start;

      while (cursor < targetEnd) {
        ({Slot slot, int start, int end})? nextRange;
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
        if (seen.add(time)) {
          result.add(Slot(time: time, status: 'available'));
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final date = availability.date ?? '';
    final status = availability.status?.toLowerCase() ?? '';
    final isAvailable = status == 'available';

    // ── FIX 2: also exclude slots whose start time has already passed today ──
    final slots = isAvailable
        ? _buildDurationSlots(date, availability.slots)
        : <Slot>[];

    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.button.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: AppColors.button,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDate(date),
                  style: text13(
                    color: AppColors.button,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (!isAvailable)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: status == 'booked'
                            ? Colors.orange.withOpacity(0.08)
                            : Colors.red.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == 'booked'
                            ? Icons.event_busy_rounded
                            : Icons.block_rounded,
                        size: 34,
                        color: status == 'booked'
                            ? Colors.orange.shade400
                            : Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      status == 'booked'
                          ? "Yeh date pehle se\nbooked hai"
                          : "Pandit Ji is date\nko available nahi hain",
                      textAlign: TextAlign.center,
                      style: text13(
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Koi aur date choose karein\nya Custom Date use karein",
                      textAlign: TextAlign.center,
                      style: text12(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            )
          else if (slots.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_busy_outlined,
                      size: 40,
                      color: AppColors.grey400.withOpacity(0.5),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "No slots available\nfor this date",
                      textAlign: TextAlign.center,
                      style: text13(color: AppColors.grey600),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: slots.length,
                itemBuilder: (context, i) {
                  final slot = slots[i];
                  final selected = isSelected(date, slot);

                  return GestureDetector(
                    onTap: () => onToggle(date, slot),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.button.withOpacity(0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.button
                              : Colors.grey.shade200,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.button.withOpacity(0.12)
                                  : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 18,
                              color: selected
                                  ? AppColors.button
                                  : AppColors.grey400,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              slot.time ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.button
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? AppColors.button
                                  : Colors.transparent,
                              border: Border.all(
                                color: selected
                                    ? AppColors.button
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? const Icon(
                                    Icons.check,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty hint ──────────────────────────────────────────────────────────────
class _EmptySlotHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.touch_app_rounded,
            size: 48,
            color: AppColors.grey400.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            "Tap a date to\nsee available slots",
            textAlign: TextAlign.center,
            style: text13(color: AppColors.grey600),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Bar ──────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.totalSelected,
    required this.selectedSlots,
    required this.customDate,
    required this.customTimeStart,
    required this.customTimeEnd,
    required this.tod,
    required this.onNext,
  });

  final int totalSelected;
  final Map<String, List<Slot>> selectedSlots;
  final DateTime? customDate;
  final TimeOfDay? customTimeStart;
  final TimeOfDay? customTimeEnd;
  final String Function(TimeOfDay) tod;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final hasCustom = customDate != null && customTimeStart != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (totalSelected > 0) ...[
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final entry in selectedSlots.entries)
                    for (final slot in entry.value)
                      _Chip(
                        label: "${_fmtDate(entry.key)}  ${slot.time ?? ''}",
                      ),
                  if (hasCustom)
                    _Chip(
                      label:
                          "Custom: ${customDate!.day} ${_monthN(customDate!.month)}  ${tod(customTimeStart!)}",
                      color: const Color(0xFF6366F1),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppButton(title: "Next", onTap: onNext),
        ],
      ),
    );
  }

  static String _fmtDate(String raw) {
    try {
      final p = raw.split('-');
      return "${int.parse(p[2])} ${_monthN(int.parse(p[1]))}";
    } catch (_) {
      return raw;
    }
  }

  static String _monthN(int m) {
    const mm = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return mm[m];
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color});
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.button;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: text12(color: c, fontWeight: FontWeight.w500),
      ),
    );
  }
}
