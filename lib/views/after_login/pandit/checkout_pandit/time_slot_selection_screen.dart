// Time Slot Selection Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

class TimeSlotSelectionScreen extends StatefulWidget {
  const TimeSlotSelectionScreen({super.key});

  @override
  State<TimeSlotSelectionScreen> createState() =>
      _TimeSlotSelectionScreenState();
}

class _TimeSlotSelectionScreenState extends State<TimeSlotSelectionScreen> {
  late List<DateSlot> dateList;

  @override
  void initState() {
    super.initState();

    dateList = List.generate(30, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return DateSlot(date: "${date.day} ${getMonth(date.month)} ${date.year}");
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available\nTime Slots',
                    style: text20(fontWeight: FontWeight.bold),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      DateTime? date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (date != null) {
                        TimeOfDay? time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        color: AppColors.grey200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Select Date',
                            style: text12(color: AppColors.grey400),
                          ),
                          IconButton(
                            icon: const Icon(Icons.search, size: 20),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Date and Time Selection
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
                            onTap: () {
                              setState(() {
                                // close all others
                                for (var d in dateList) {
                                  d.isExpanded = false;
                                }
                                item.isExpanded = true;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item.selectedTime == null
                                        ? item.date
                                        : "${item.date}, ${item.selectedTime}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Icon(
                                    item.isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          /// 🔴 TIME SLOTS
                          if (item.isExpanded)
                            Column(
                              children: timeSlots.map((slot) {
                                final isSelected = item.selectedTime == slot;

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      item.selectedTime = slot;
                                      item.isExpanded = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.pink.shade50
                                          : Colors.white,
                                      border: Border(
                                        top: BorderSide(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(slot),
                                        const Spacer(),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check,
                                            color: Colors.pink,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
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
  bool isExpanded;
  String? selectedTime;

  DateSlot({required this.date, this.isExpanded = false, this.selectedTime});
}
