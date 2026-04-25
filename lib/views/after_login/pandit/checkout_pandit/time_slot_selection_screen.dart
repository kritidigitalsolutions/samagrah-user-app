// Time Slot Selection Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

class TimeSlotSelectionScreen extends ConsumerStatefulWidget {
  const TimeSlotSelectionScreen({super.key});

  @override
  ConsumerState<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState
    extends ConsumerState<TimeSlotSelectionScreen> {
  late List<DateSlot> dateList;

  // List to store all selected date-time slots
  List<SelectedDateTimeSlot> selectedSlots = [];

  @override
  void initState() {
    super.initState();

    dateList = List.generate(30, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return DateSlot(
        date: "${date.day} ${getMonth(date.month)} ${date.year}",
        dateTime: date,
      );
    });
  }

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

  /// Format DateTime to "DD MMM YYYY" format
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
  Future<void> handleDateTimeSelection() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null && mounted) {
      // Select start time
      TimeOfDay? startTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        helpText: 'Select Start Time',
      );

      if (startTime != null && mounted) {
        // Select end time
        TimeOfDay? endTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: startTime.hour + 2,
            minute: startTime.minute,
          ),
          helpText: 'Select End Time',
        );

        if (endTime != null) {
          // Create time slot string
          String timeSlot = "${formatTime(startTime)} - ${formatTime(endTime)}";
          String formattedDate = formatDate(selectedDate);

          // Add to selected slots list
          setState(() {
            selectedSlots.add(
              SelectedDateTimeSlot(
                date: formattedDate,
                dateTime: selectedDate,
                timeSlot: timeSlot,
                startTime: startTime,
                endTime: endTime,
              ),
            );
          });

          // Show confirmation
          if (mounted) {
            AppSnackbar.show(
              context,
              message: 'Added: $formattedDate, $timeSlot',
              type: SnackBarType.success,
            );
          }
        }
      }
    }
  }

  /// Remove a selected slot
  void removeSlot(int index) {
    setState(() {
      selectedSlots.removeAt(index);
    });

    AppSnackbar.show(
      context,
      message: 'Slot removed',
      type: SnackBarType.error,
    );
  }

  /// Get formatted date and time for API
  String getApiFormattedDateTime(DateTime date, TimeOfDay time) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    int hour = time.hour;
    final minute = time.minute;

    // Return formatted string for API
    return "${year.toString()}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')} ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00";
  }

  /// Get all selected slots in API format
  List<Map<String, String>> getApiFormattedSlots() {
    return selectedSlots.map((slot) {
      return {
        'date': formatDate(slot.dateTime),
        'start_time': getApiFormattedDateTime(slot.dateTime, slot.startTime),
        'end_time': getApiFormattedDateTime(slot.dateTime, slot.endTime),
        'time_slot': slot.timeSlot,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.grey500,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16,
              ),
              decoration: BoxDecoration(color: AppColors.headerCard),
              child: _buildCustomStepper(),
            ),
            const SizedBox(height: 16),

            // Available Time Slots Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    'Available\nTime Slots',
                    style: text20(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: handleDateTimeSelection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.grey200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Date & Time',
                              style: text12(color: AppColors.grey400),
                            ),
                            Icon(
                              Icons.add_circle_outline,
                              size: 20,
                              color: AppColors.grey400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected Slots Display
            if (selectedSlots.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 18,
                          color: Colors.pink.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Slots (${selectedSlots.length})',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.pink.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...selectedSlots.asMap().entries.map((entry) {
                      int index = entry.key;
                      SelectedDateTimeSlot slot = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot.date,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    slot.timeSlot,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                              onPressed: () => removeSlot(index),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            if (selectedSlots.isNotEmpty) const SizedBox(height: 16),

            // Date and Time Selection (Original List)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: dateList.length,
                itemBuilder: (context, index) {
                  final item = dateList[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isExpanded
                              ? const Color(0xFFD81B60)
                              : Colors.grey.shade200,
                          width: item.isExpanded ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          /// 🔴 DATE HEADER
                          InkWell(
                            onTap: () async {
                              // When date is tapped, show time pickers
                              TimeOfDay? startTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                                helpText: 'Select Start Time',
                              );

                              if (startTime != null && mounted) {
                                TimeOfDay? endTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(
                                    hour: startTime.hour + 2,
                                    minute: startTime.minute,
                                  ),
                                  helpText: 'Select End Time',
                                );

                                if (endTime != null) {
                                  String timeSlot =
                                      "${formatTime(startTime)} - ${formatTime(endTime)}";

                                  setState(() {
                                    selectedSlots.add(
                                      SelectedDateTimeSlot(
                                        date: item.date,
                                        dateTime: item.dateTime,
                                        timeSlot: timeSlot,
                                        startTime: startTime,
                                        endTime: endTime,
                                      ),
                                    );
                                  });

                                  if (mounted) {
                                    AppSnackbar.show(
                                      context,
                                      message: 'Added: ${item.date}, $timeSlot',
                                      type: SnackBarType.success,
                                    );
                                  }
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.date,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.pink.shade400,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Next Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppColors.button),
              child: Consumer(
                builder: (context, ref, child) {
                  final service = ref.watch(selectedServiceProvider);

                  return AppButton(
                    title: "Next",
                    onTap: () {
                      // Get all selected slots in API format
                      final apiSlots = getApiFormattedSlots();
                      ref.read(selectedDateProvider.notifier).state =
                          getApiFormattedSlots();
                      print('API Formatted Slots: $apiSlots');

                      if (selectedSlots.isEmpty) {
                        AppSnackbar.show(
                          context,
                          message: 'Please select at least one time slot',
                          type: SnackBarType.info,
                        );
                        return;
                      }

                      // Save to provider if needed
                      // ref.read(apiDateTimeSlotsProvider.notifier).state = apiSlots;

                      if (service?.type == "home") {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.addressSelection,
                        );
                      } else if (service?.type == "online") {
                        Navigator.pushNamed(context, AppRoutes.onlineDetails);
                      } else {
                        Navigator.pushNamed(context, AppRoutes.templeSelection);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomStepper() {
    return Column(
      children: [
        const SizedBox(height: 8),

        /// 🔴 DOT + LINE ROW
        Row(
          children: [
            buildCircle("1", true),
            buildDottedLine(),
            buildCircle("2", true),
            buildDottedLine(),
            buildCircle("3", false),
          ],
        ),
        const SizedBox(height: 8),

        bottomLable(),
      ],
    );
  }

  final List<String> timeSlots = [
    "6:00 AM - 8:00 AM",
    "12:00 PM - 2:00 PM",
    "6:00 PM - 8:00 PM",
  ];
}

class DateSlot {
  final String date;
  final DateTime dateTime;
  bool isExpanded;
  String? selectedTime;
  TimeOfDay? customTime;

  DateSlot({
    required this.date,
    required this.dateTime,
    this.isExpanded = false,
    this.selectedTime,
    this.customTime,
  });
}

// New class to store selected date-time slots
class SelectedDateTimeSlot {
  final String date;
  final DateTime dateTime;
  final String timeSlot;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  SelectedDateTimeSlot({
    required this.date,
    required this.dateTime,
    required this.timeSlot,
    required this.startTime,
    required this.endTime,
  });

  // Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time_slot': timeSlot,
      'start_time': '${startTime.hour}:${startTime.minute}',
      'end_time': '${endTime.hour}:${endTime.minute}',
    };
  }
}
