import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/service_selection_screen.dart';

// ─────────────────────────────────────────────
// Filter State — ONLY client-side filters
// Location ab alag handle hogi
// ─────────────────────────────────────────────
class PanditFilterState {
  final String? serviceType;
  final String? language;
  final int? minExperience;
  final double? minRating;
  final DateTime? date;
  final TimeOfDay? time;
  final TimeOfDay? endTime;

  const PanditFilterState({
    this.serviceType,
    this.language,
    this.minExperience,
    this.minRating,
    this.date,
    this.time,
    this.endTime,
  });

  bool get hasAnyFilter =>
      serviceType != null ||
      language != null ||
      minExperience != null ||
      minRating != null ||
      date != null ||
      time != null ||
      endTime != null;

  PanditFilterState copyWith({
    Object? serviceType = _sentinel,
    Object? language = _sentinel,
    Object? minExperience = _sentinel,
    Object? minRating = _sentinel,
    Object? date = _sentinel,
    Object? time = _sentinel,
    Object? endTime = _sentinel,
  }) {
    return PanditFilterState(
      serviceType: serviceType == _sentinel
          ? this.serviceType
          : serviceType as String?,
      language: language == _sentinel ? this.language : language as String?,
      minExperience: minExperience == _sentinel
          ? this.minExperience
          : minExperience as int?,
      minRating: minRating == _sentinel ? this.minRating : minRating as double?,
      date: date == _sentinel ? this.date : date as DateTime?,
      time: time == _sentinel ? this.time : time as TimeOfDay?,
      endTime: endTime == _sentinel ? this.endTime : endTime as TimeOfDay?,
    );
  }
}

const _sentinel = Object();

class _QuickFilter {
  final String label;
  final IconData icon;
  final String type;
  final String dec;
  const _QuickFilter(this.label, this.icon, this.type, this.dec);
}

const _quickFilters = [
  _QuickFilter(
    'Home Visit',
    Icons.home_outlined,
    'home',
    'Pooja will be performed at your home.',
  ),
  _QuickFilter(
    'Online',
    Icons.video_call_outlined,
    'online',
    'Pooja will be performed online.',
  ),
  _QuickFilter(
    'Temple',
    Icons.temple_hindu_outlined,
    'temple',
    'Pooja will be performed at temple.',
  ),
];

// ─────────────────────────────────────────────
// BookPanditPage
// ─────────────────────────────────────────────
class BookPanditPage extends ConsumerStatefulWidget {
  const BookPanditPage({super.key});

  @override
  ConsumerState<BookPanditPage> createState() => _BookPanditPageState();
}

class _BookPanditPageState extends ConsumerState<BookPanditPage> {
  PanditFilterState _filters = const PanditFilterState();
  final TextEditingController _searchController = TextEditingController();

  // ── Location state is managed by Riverpod (panditLocationProvider) ──

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$min $period';
  }

  Future<void> _refreshPandits() => ref.refresh(panditProvider.future);

  String _dateApi(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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

  int _selectedFilterDurationHours(int fallbackDurationHours) {
    if (_filters.time == null || _filters.endTime == null) {
      return fallbackDurationHours;
    }

    final start = _toMinutes(_filters.time!);
    var end = _toMinutes(_filters.endTime!);
    if (end <= start) end += 24 * 60;
    final minutes = end - start;
    if (minutes <= 0) return fallbackDurationHours;
    return (minutes / 60).ceil().clamp(1, 24);
  }

  TimeOfDay _addHours(TimeOfDay time, int hours) {
    return TimeOfDay(
      hour: (time.hour + hours).clamp(0, 23),
      minute: time.minute,
    );
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

  bool _isPastSlot(String date, Slot slot) {
    final time = slot.time;
    if (time == null) return false;
    try {
      final d = DateTime.parse(date);
      final now = DateTime.now();
      if (d.year != now.year || d.month != now.month || d.day != now.day) {
        return false;
      }

      final start = _parseTimeOfDay(time.split(' - ').first.trim());
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

  bool _hasContinuousAvailability({
    required String date,
    required List<Slot> sourceSlots,
    required int startMinutes,
    required int durationHours,
  }) {
    final targetEnd = startMinutes + durationHours.clamp(1, 24) * 60;
    var cursor = startMinutes;
    final ranges = sourceSlots
        .where(
          (slot) =>
              slot.status?.toLowerCase() == 'available' &&
              !_isPastSlot(date, slot),
        )
        .map((slot) => _slotRange(slot))
        .whereType<({int start, int end})>()
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    while (cursor < targetEnd) {
      ({int start, int end})? nextRange;
      for (final range in ranges) {
        if (range.start <= cursor && range.end > cursor) {
          nextRange = range;
          break;
        }
      }

      if (nextRange == null) return false;
      cursor = nextRange.end;
    }

    return true;
  }

  int _ritualDurationHours(PanditData pandit, Set<String> ritualNames) {
    PoojaOffering? matchedOffering;
    for (final offering in pandit.poojaOfferings) {
      if (ritualNames.contains(_normalizeText(offering.name))) {
        matchedOffering = offering;
        break;
      }
    }

    final selectedRitual = ref.read(selectedRitualProvider);
    final duration = matchedOffering?.durationHours ?? selectedRitual?.durationHours;
    if (duration == null || duration <= 0) return 1;
    return duration.ceil();
  }

  bool _matchesDateTimeFilter(PanditData pandit) {
    // Start/end-time filtering is intentionally disabled. Pandits are filtered
    // only by the selected availability date.
    if (_filters.date == null) return true;
    if (pandit.availability.isEmpty) return false;

    final filterDate = _dateApi(_filters.date!);
    return pandit.availability.any(
      (item) =>
          item.status?.toLowerCase() == 'available' &&
          item.date == filterDate,
    );
  }

  @override
  void initState() {
    super.initState();
    final selectedRitual = ref.read(selectedRitualProvider);
    if (selectedRitual != null) {
      _searchController.text = selectedRitual.title ?? selectedRitual.name ?? '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Client-side filters only (no location) ──
  List<PanditData> _applyFilters(List<PanditData> source) {
    final selectedRitual = ref.read(selectedRitualProvider);
    final ritualNames = {
      _normalizeText(selectedRitual?.name),
      _normalizeText(selectedRitual?.title),
    }..remove('');
    final searchTerm = _normalizeText(_searchController.text);

    return source.where((p) {
      if (ritualNames.isNotEmpty) {
        final hasRitual = p.poojaOfferings.any(
          (offering) => ritualNames.contains(_normalizeText(offering.name)),
        );
        if (!hasRitual) return false;
      }

      if (!_matchesDateTimeFilter(p)) return false;

      if (searchTerm.isNotEmpty) {
        final name = _normalizeText(p.fullName);
        final city = _normalizeText(p.address?.city);
        final stateName = _normalizeText(p.address?.state);
        final line1 = _normalizeText(p.address?.line1);
        final line2 = _normalizeText(p.address?.line2);
        final languages = _normalizeText(p.languagesSpoken.join(' '));
        final poojaNames = _normalizeText(
          p.poojaOfferings.map((e) => e.name ?? '').join(' '),
        );
        final yearOfExp = (p.yearsOfExperience ?? '').toString();

        final matchesSearch =
            name.contains(searchTerm) ||
            city.contains(searchTerm) ||
            stateName.contains(searchTerm) ||
            languages.contains(searchTerm) ||
            poojaNames.contains(searchTerm) ||
            line1.contains(searchTerm) ||
            line2.contains(searchTerm) ||
            yearOfExp.contains(searchTerm);

        if (!matchesSearch) return false;
      }

      if (_filters.serviceType != null) {
        final st = p.serviceTypes;
        bool matches = false;
        if (_filters.serviceType == 'home') matches = st?.homeVisit == true;
        if (_filters.serviceType == 'online') matches = st?.onlinePooja == true;
        if (_filters.serviceType == 'temple') matches = st?.atTemple == true;
        if (!matches) return false;
      }
      if (_filters.language != null) {
        final hasLang = p.languagesSpoken.any(
          (l) => l.toLowerCase().contains(_filters.language!.toLowerCase()),
        );
        if (!hasLang) return false;
      }
      if (_filters.minExperience != null &&
          (p.yearsOfExperience ?? 0) < _filters.minExperience!) {
        return false;
      }
      if (_filters.minRating != null &&
          (p.ratingAverage ?? 0) < _filters.minRating!) {
        return false;
      }
      return true;
    }).toList();
  }

  String _normalizeText(String? value) {
    return (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ── Location Search Bottom Sheet ──────────────────────────────────────────
  void _openLocationSheet() {
    final locationState = ref.read(panditLocationProvider);
    final cityController = TextEditingController(text: locationState.city);
    final pincodeController = TextEditingController(text: locationState.pincode);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.grey300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Row(
                  children: [
                    Text(
                      'Search by Location',
                      style: text18(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),

                const SizedBox(height: 4),
                Text(
                  'Find pandits in any city across India',
                  style: text13(color: AppColors.grey500),
                ),
                const SizedBox(height: 20),

                // City input
                Text(
                  'City',
                  style: text13(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                _locationTextField(
                  controller: cityController,
                  hint: 'e.g. Delhi, Varanasi, Mumbai...',
                  icon: Icons.location_city_outlined,
                ),

                const SizedBox(height: 14),

                // Pincode input
                Text(
                  'Pincode (optional)',
                  style: text13(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 8),
                _locationTextField(
                  controller: pincodeController,
                  hint: 'e.g. 110001',
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    // Reset to GPS location
                    if (locationState.isActive)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.grey300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(
                            Icons.my_location_rounded,
                            size: 16,
                            color: AppColors.grey600,
                          ),
                          label: Text(
                            'Reset to GPS',
                            style: text13(color: AppColors.grey600),
                          ),
                          onPressed: () {
                            Navigator.pop(sheetCtx);
                            ref
                                .read(panditProvider.notifier)
                                .resetToUserLocation();
                          },
                        ),
                      ),
                    if (locationState.isActive) const SizedBox(width: 10),

                    Expanded(
                      flex: 2,
                      child: AppButton(
                        title: 'Search Pandits',
                        onTap: () {
                          final city = cityController.text.trim();
                          final pincode = pincodeController.text.trim();

                          if (city.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a city name'),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(sheetCtx);
                          ref
                              .read(panditProvider.notifier)
                              .fetchByLocation(city: city, pincode: pincode);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _locationTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: text14(),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: text13(color: AppColors.grey400),
          prefixIcon: Icon(icon, size: 20, color: AppColors.grey500),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  // ── Advanced Filter Sheet (no location) ──────────────────────────────────
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        PanditFilterState draft = _filters;

        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.88,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: text18(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (draft.hasAnyFilter)
                        TextButton(
                          onPressed: () =>
                              setSheet(() => draft = const PanditFilterState()),
                          child: Text(
                            'Clear All',
                            style: text13(color: AppColors.error),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Service Type ──
                          _sheetSectionLabel('Service Type'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final qf in _quickFilters) ...[
                                Expanded(
                                  child: _serviceTypeCard(
                                    label: qf.label,
                                    icon: qf.icon,
                                    selected: draft.serviceType == qf.type,
                                    onTap: () => setSheet(() {
                                      draft = draft.copyWith(
                                        serviceType:
                                            draft.serviceType == qf.type
                                            ? null
                                            : qf.type,
                                      );
                                    }),
                                  ),
                                ),
                                if (qf != _quickFilters.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Date & Time ──
                          _sheetSectionLabel('Preferred Date & Time'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: ctx,
                                      initialDate: draft.date ?? DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                      builder: (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.button,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setSheet(
                                        () => draft = draft.copyWith(
                                          date: picked,
                                        ),
                                      );
                                    }
                                  },
                                  child: _dateTimePickerBox(
                                    icon: Icons.calendar_today_outlined,
                                    label: draft.date != null
                                        ? _formatDate(draft.date!)
                                        : 'Select Date',
                                    isSelected: draft.date != null,
                                    onClear: draft.date != null
                                        ? () => setSheet(
                                            () => draft = draft.copyWith(
                                              date: null,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              // Start-time filter disabled: filtering is date-only.
                              if (false) ...[
                                const SizedBox(width: 10),
                                Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    final picked = await showTimePicker(
                                      context: ctx,
                                      initialTime:
                                          draft.time ?? TimeOfDay.now(),
                                      builder: (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.button,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                    );
                                    if (picked != null) {
                                      setSheet(
                                        () => draft = draft.copyWith(
                                          time: picked,
                                        ),
                                      );
                                    }
                                  },
                                  child: _dateTimePickerBox(
                                    icon: Icons.access_time_rounded,
                                    label: draft.time != null
                                        ? _formatTime(draft.time!)
                                        : 'Start Time',
                                    isSelected: draft.time != null,
                                    onClear: draft.time != null
                                        ? () => setSheet(
                                            () => draft = draft.copyWith(
                                              time: null,
                                              endTime: null,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                                ),
                              ],
                            ],
                          ),
                          // End-time filter disabled: filtering is date-only.
                          if (false) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                            onTap: () async {
                              if (draft.time == null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select start time first',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final picked = await showTimePicker(
                                context: ctx,
                                initialTime:
                                    draft.endTime ??
                                    _addHours(draft.time!, 1),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: AppColors.button,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setSheet(
                                  () => draft = draft.copyWith(
                                    endTime: picked,
                                  ),
                                );
                              }
                            },
                            child: _dateTimePickerBox(
                              icon: Icons.timelapse_rounded,
                              label: draft.endTime != null
                                  ? _formatTime(draft.endTime!)
                                  : 'End Time',
                              isSelected: draft.endTime != null,
                              onClear: draft.endTime != null
                                  ? () => setSheet(
                                      () => draft = draft.copyWith(
                                        endTime: null,
                                      ),
                                    )
                                  : null,
                            ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // ── Language ──
                          _sheetSectionLabel('Language'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                      'Hindi',
                                      'English',
                                      'Sanskrit',
                                      'Bengali',
                                      'Tamil',
                                    ]
                                    .map(
                                      (lang) => _sheetChip(
                                        label: lang,
                                        selected: draft.language == lang,
                                        onTap: () => setSheet(() {
                                          draft = draft.copyWith(
                                            language: draft.language == lang
                                                ? null
                                                : lang,
                                          );
                                        }),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 20),

                          // ── Minimum Rating ──
                          _sheetSectionLabel('Minimum Rating'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final r in [3.0, 3.5, 4.0, 4.5]) ...[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setSheet(() {
                                      draft = draft.copyWith(
                                        minRating: draft.minRating == r
                                            ? null
                                            : r,
                                      );
                                    }),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: draft.minRating == r
                                            ? AppColors.button
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: draft.minRating == r
                                              ? AppColors.button
                                              : AppColors.grey300,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: draft.minRating == r
                                                ? AppColors.white
                                                : AppColors.warning,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '$r+',
                                            style: text12(
                                              color: draft.minRating == r
                                                  ? AppColors.white
                                                  : AppColors.grey700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (r != 4.5) const SizedBox(width: 8),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),

                          // ── Experience ──
                          Row(
                            children: [
                              _sheetSectionLabel('Min. Experience'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  draft.minExperience == null ||
                                          draft.minExperience == 0
                                      ? 'Any'
                                      : '${draft.minExperience}+ yrs',
                                  style: text12(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(ctx).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 18,
                              ),
                              activeTrackColor: AppColors.button,
                              inactiveTrackColor: AppColors.button.withOpacity(
                                0.15,
                              ),
                              thumbColor: AppColors.button,
                              overlayColor: AppColors.button.withOpacity(0.12),
                            ),
                            child: Slider(
                              value: (draft.minExperience ?? 0).toDouble(),
                              min: 0,
                              max: 30,
                              divisions: 6,
                              onChanged: (val) => setSheet(() {
                                draft = draft.copyWith(
                                  minExperience: val == 0 ? null : val.toInt(),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SafeArea(
                    child: AppButton(
                      title: 'Apply Filters',
                      onTap: () {
                        setState(() {
                          _filters = draft.copyWith(time: null, endTime: null);
                        });
                        Navigator.pop(sheetCtx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dateTimePickerBox({
    required IconData icon,
    required String label,
    required bool isSelected,
    VoidCallback? onClear,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.button.withOpacity(0.06)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.button : AppColors.grey300,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? AppColors.button : AppColors.grey500,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              style: text12(
                color: isSelected ? AppColors.button : AppColors.grey500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.grey500,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(panditLocationProvider);

    final panditAsync = ref.watch(panditProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Book my Pandit',
        subtitle: 'Schedule a pandit for your ritual needs',
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
            // ── Search + Filter + Location bar ──────────────────────
            Container(
              color: AppColors.headerCard,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (_) => setState(() {}),
                        style: text14(),
                        decoration: InputDecoration(
                          hintText: 'Search by name, language...',
                          hintStyle: text13(color: AppColors.grey500),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.grey600,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.grey500,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Location button ──────────────────────────────
                  GestureDetector(
                    onTap: _openLocationSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: locationState.isActive
                            ? Colors.green.shade600
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        locationState.isActive
                            ? Icons.location_on_rounded
                            : Icons.location_searching_rounded,
                        size: 20,
                        color: locationState.isActive
                            ? Colors.white
                            : AppColors.grey700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Filters button ───────────────────────────────
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _filters.hasAnyFilter
                            ? AppColors.button
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: _filters.hasAnyFilter
                                ? AppColors.white
                                : AppColors.grey700,
                          ),
                          if (_filters.hasAnyFilter)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active location tag ──────────────────────────────────
            if (locationState.isActive)
              Container(
                color: Colors.green.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Showing pandits in ${locationState.city}'
                        '${locationState.pincode.isNotEmpty ? ' - ${locationState.pincode}' : ''}',
                        style: text12(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(panditProvider.notifier).resetToUserLocation();
                      },
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Quick filter chips ───────────────────────────────────
            Container(
              color: AppColors.headerCard,
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _quickChip(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      selected: !_filters.hasAnyFilter,
                      onTap: () {
                        setState(() => _filters = const PanditFilterState());
                        ref.invalidate(selectedServiceProvider);
                      },
                    ),
                    const SizedBox(width: 8),
                    for (final qf in _quickFilters) ...[
                      _quickChip(
                        label: qf.label,
                        icon: qf.icon,
                        selected: _filters.serviceType == qf.type,
                        onTap: () {
                          final isDeselecting = _filters.serviceType == qf.type;
                          setState(() {
                            _filters = _filters.copyWith(
                              serviceType: isDeselecting ? null : qf.type,
                            );
                          });
                          if (isDeselecting) {
                            ref.invalidate(selectedServiceProvider);
                          } else {
                            ref
                                .read(selectedServiceProvider.notifier)
                                .state = ServiceModel(
                              title: qf.label,
                              type: qf.type,
                              description: qf.dec,
                              icon: qf.icon,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    _quickChip(
                      label: '4★ & above',
                      icon: Icons.star_rounded,
                      selected: _filters.minRating == 4.0,
                      onTap: () => setState(() {
                        _filters = _filters.copyWith(
                          minRating: _filters.minRating == 4.0 ? null : 4.0,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    _quickChip(
                      label: '5+ yrs exp',
                      icon: Icons.workspace_premium_outlined,
                      selected: _filters.minExperience == 5,
                      onTap: () => setState(() {
                        _filters = _filters.copyWith(
                          minExperience: _filters.minExperience == 5 ? null : 5,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ── Active filter tags (client-side only) ────────────────
            if (_filters.hasAnyFilter)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_filters.date != null)
                              _activeTag(
                                '📅 ${_formatDate(_filters.date!)}',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(date: null);
                                }),
                              ),
                            if (false && _filters.time != null)
                              _activeTag(
                                '🕐 ${_formatTime(_filters.time!)}',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(
                                    time: null,
                                    endTime: null,
                                  );
                                }),
                              ),
                            if (false && _filters.endTime != null)
                              _activeTag(
                                'End ${_formatTime(_filters.endTime!)}',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(endTime: null);
                                }),
                              ),
                            if (_filters.language != null)
                              _activeTag(
                                _filters.language!,
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(language: null);
                                }),
                              ),
                            if (_filters.minExperience != null &&
                                _filters.minExperience != 5)
                              _activeTag(
                                '${_filters.minExperience}+ yrs',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(
                                    minExperience: null,
                                  );
                                }),
                              ),
                            if (_filters.minRating != null &&
                                _filters.minRating != 4.0)
                              _activeTag(
                                '${_filters.minRating}★+',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(minRating: null);
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _filters = const PanditFilterState());
                        ref.invalidate(selectedServiceProvider);
                      },
                      child: Text(
                        'Clear all',
                        style: text12(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Pandit Grid ──────────────────────────────────────────
            Expanded(
              child: panditAsync.when(
                loading: () => RefreshIndicator(
                  onRefresh: _refreshPandits,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.button,
                        ),
                      ),
                    ),
                  ),
                ),
                error: (e, _) => RefreshIndicator(
                  onRefresh: _refreshPandits,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: const Center(child: Text('Something went wrong')),
                    ),
                  ),
                ),
                data: (data) {
                  final pandits = _applyFilters(data.pandit);

                  if (pandits.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshPandits,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No pandits found',
                                style: text16(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                locationState.isActive
                                    ? 'No pandits found in ${locationState.city}'
                                    : 'Try adjusting your filters',
                                style: text13(color: AppColors.grey500),
                              ),
                              const SizedBox(height: 16),
                              if (locationState.isActive)
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(panditProvider.notifier)
                                        .resetToUserLocation();
                                  },
                                  child: Text(
                                    'Reset Location',
                                    style: text13(color: AppColors.button),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () => setState(
                                    () => _filters = const PanditFilterState(),
                                  ),
                                  child: Text(
                                    'Clear filters',
                                    style: text13(color: AppColors.button),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshPandits,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      children: [
                        Row(
                          children: [
                            Text(
                              '${pandits.length} Pandit${pandits.length == 1 ? '' : 's'} found',
                              style: text13(
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (_filters.hasAnyFilter)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Filtered',
                                  style: text11(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: pandits.length,
                          itemBuilder: (context, index) =>
                              _buildPanditCard(pandits[index]),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View More',
                            style: text14(
                              color: AppColors.button,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _quickChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? Colors.white : AppColors.grey600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: text12(
                color: selected ? Colors.white : AppColors.grey700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeTag(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.button.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.button.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text12(color: AppColors.button, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: AppColors.button),
          ),
        ],
      ),
    );
  }

  Widget _sheetSectionLabel(String label) =>
      Text(label, style: text14(fontWeight: FontWeight.w600));

  Widget _serviceTypeCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.button,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: text11(
                color: selected ? Colors.white : AppColors.grey700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: text13(
            color: selected ? Colors.white : AppColors.grey700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPanditCard(PanditData pandit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomCachedImage(imageUrl: pandit.profileImage ?? ''),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.78),
                    ],
                    stops: const [0.35, 0.6, 1.0],
                  ),
                ),
              ),
            ),
            if (pandit.isVerified == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text('Verified', style: text10(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pandit.fullName ?? 'N/A',
                      style: text14(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          pandit.ratingAverage?.toStringAsFixed(1) ?? '—',
                          style: text11(color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        if ((pandit.yearsOfExperience ?? 0) > 0) ...[
                          const Icon(
                            Icons.circle,
                            size: 3,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${pandit.yearsOfExperience}y',
                            style: text11(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      height: 28,
                      textStyle: text11(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      title: 'View Details',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.panditDetails,
                        arguments: pandit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
