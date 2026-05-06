import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class BookPanditPage extends ConsumerStatefulWidget {
  const BookPanditPage({super.key});

  @override
  ConsumerState<BookPanditPage> createState() => _BookPanditPageState();
}

class _BookPanditPageState extends ConsumerState<BookPanditPage> {
  int selectedOption = 2;
  Map<String, dynamic> assignedPanditBookingDetails = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            // Header Section
            Container(
              decoration: BoxDecoration(color: AppColors.headerCard),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  /// 📍 Location
                  GestureDetector(
                    onTap: () {
                      _showLocationBottomSheet(context);
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Location',
                                  style: text11(
                                    color: AppColors.grey800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 14),
                              ],
                            ),
                            Text(
                              'Agra, UP',
                              style: text10(color: AppColors.grey700),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// 🔍 Search
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          ref.read(panditProvider.notifier).searchPandit(value);
                        },
                        decoration: InputDecoration(
                          hintText: "Search",
                          hintStyle: text13(),
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              _searchController.clear();

                              // reset search
                              ref
                                  .read(panditProvider.notifier)
                                  .searchPandit('');
                            },
                            child: Icon(Icons.close, size: 18),
                          ),
                          filled: true,
                          fillColor: AppColors.warning.withAlpha(50),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  /// 📅 Date & Time
                  // Expanded(
                  //   flex: 3,
                  //   child: SizedBox(
                  //     height: 40,
                  //     child: TextField(
                  //       readOnly: true,
                  //       onTap: () async {
                  //         DateTime? date = await showDatePicker(
                  //           context: context,
                  //           initialDate: DateTime.now(),
                  //           firstDate: DateTime.now(),
                  //           lastDate: DateTime(2100),
                  //         );

                  //         if (date != null) {
                  //           await showTimePicker(
                  //             context: context,
                  //             initialTime: TimeOfDay.now(),
                  //           );
                  //         }
                  //       },
                  //       decoration: InputDecoration(
                  //         hintText: "Date & Time",
                  //         hintStyle: text13(),
                  //         prefixIcon: const Icon(
                  //           Icons.calendar_today,
                  //           size: 18,
                  //         ),
                  //         filled: true,
                  //         fillColor: AppColors.warning.withAlpha(50),
                  //         contentPadding: const EdgeInsets.symmetric(
                  //           horizontal: 8,
                  //         ),
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(25),
                  //           borderSide: BorderSide.none,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Selection Options
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildOptionCard(
                          1,
                          'Assign Best Available Pandit',
                          'We assign the best pandit available',
                          AppColors.button,
                          true,
                        ),
                        if (selectedOption == 1) ...[
                          const SizedBox(height: 15),
                          AppButton(
                            title: "Next",
                            onTap: () {
                              _showAssignPanditBottomSheet();
                            },
                          ),
                        ],

                        const SizedBox(height: 15),
                        _buildOptionCard(
                          2,
                          'Choose Pandit',
                          'Choose from our best pandits and experience',
                          AppColors.button,
                          false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Pandits Grid
                  panditAsync.when(
                    loading: () => Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) => Text("Something went wrong"),
                    data: (data) {
                      final pandits = data.searchResults.isNotEmpty
                          ? data.searchResults
                          : data.pandit;
                      if (pandits.isEmpty) {
                        return Text("Pandit Not found");
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                          itemCount: pandits.length,
                          itemBuilder: (context, index) {
                            final pandit = pandits[index];
                            return _buildPanditCard(pandit);
                          },
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 15),

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

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    int index,
    String title,
    String description,
    Color color,
    bool isRec,
  ) {
    final isSelected = selectedOption == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOption = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.grey400,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.circle, size: 10, color: AppColors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isRec
                      ? Container(
                          width: 130,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 15,
                                color: AppColors.warningLight,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Recommended",
                                style: text10(color: AppColors.white),
                              ),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                  Text(
                    title,
                    style: text14(
                      fontWeight: FontWeight.w600,
                      color: AppColors.black87,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: text11(
                      color: AppColors.grey600,
                    ).copyWith(height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanditCard(PanditData pandit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: CustomCachedImage(imageUrl: pandit.profileImage ?? ''),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pandit.fullName ?? 'N/A',
                      style: text14(
                        color: AppColors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pandit.ratingAverage.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      height: 30,
                      textStyle: text12(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      title: "View Details",
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.panditDetails,
                          arguments: pandit, // 👈 your PanditData object
                        );
                      },
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

  Future<void> _showAssignPanditBottomSheet() async {
    final poojaController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    int currentStep = 0;
    String? selectedService;
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final bottomInset = MediaQuery.of(context).viewInsets.bottom;
            final selectedDateText = selectedDate == null
                ? 'Pick date'
                : '${selectedDate!.day} ${_monthName(selectedDate!.month)} ${selectedDate!.year}';
            final selectedTimeText = selectedTime == null
                ? 'Pick time'
                : _formatTime(selectedTime!);

            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.86,
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Assign Pandit',
                            style: text18(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSheetStep(1, currentStep >= 0),
                        _buildSheetLine(currentStep >= 1),
                        _buildSheetStep(2, currentStep >= 1),
                        _buildSheetLine(currentStep >= 2),
                        _buildSheetStep(3, currentStep >= 2),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Flexible(
                      child: SingleChildScrollView(
                        child: currentStep == 0
                            ? _buildServiceStep(
                                selectedService: selectedService,
                                onSelect: (value) {
                                  setModalState(() {
                                    selectedService = value;
                                  });
                                },
                              )
                            : currentStep == 1
                            ? _buildDateTimeStep(
                                context: context,
                                selectedDateText: selectedDateText,
                                selectedTimeText: selectedTimeText,
                                onPickDate: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    setModalState(() {
                                      selectedDate = date;
                                    });
                                  }
                                },
                                onPickTime: () async {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        selectedTime ?? TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setModalState(() {
                                      selectedTime = time;
                                    });
                                  }
                                },
                              )
                            : _buildOtherDetailsStep(
                                poojaController: poojaController,
                                nameController: nameController,
                                phoneController: phoneController,
                                addressController: addressController,
                                notesController: notesController,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (currentStep > 0) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setModalState(() {
                                  currentStep--;
                                });
                              },
                              child: Text(
                                'Back',
                                style: text14(color: AppColors.button),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: AppButton(
                            title: currentStep == 2 ? 'Save' : 'Next',
                            onTap: () {
                              if (currentStep == 0 && selectedService == null) {
                                _showMessage('Please select service');
                                return;
                              }

                              if (currentStep == 1 &&
                                  (selectedDate == null ||
                                      selectedTime == null)) {
                                _showMessage('Please select date and time');
                                return;
                              }

                              if (currentStep < 2) {
                                setModalState(() {
                                  currentStep++;
                                });
                                return;
                              }

                              final details = {
                                'booking_type': 'assign_best_available_pandit',
                                'service': selectedService,
                                'date': selectedDate == null
                                    ? ''
                                    : '${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                                'time': selectedTime == null
                                    ? ''
                                    : _formatTime(selectedTime!),
                                'pooja_name': poojaController.text.trim(),
                                'devotee_name': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'address': addressController.text.trim(),
                                'notes': notesController.text.trim(),
                              };

                              setState(() {
                                assignedPanditBookingDetails = details;
                              });

                              Navigator.pop(sheetContext);
                              _showMessage('Pandit booking details saved');
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
      },
    );

    poojaController.dispose();
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    notesController.dispose();
  }

  Widget _buildServiceStep({
    required String? selectedService,
    required ValueChanged<String> onSelect,
  }) {
    final services = [
      {
        'title': 'Home Pooja',
        'type': 'home',
        'description': 'Pandit ji will visit your home.',
        'icon': Icons.home_outlined,
      },
      {
        'title': 'Online Pooja',
        'type': 'online',
        'description': 'Pooja will happen on a video call.',
        'icon': Icons.video_call_outlined,
      },
      {
        'title': 'Temple Pooja',
        'type': 'temple',
        'description': 'Pooja will be performed at temple.',
        'icon': Icons.temple_hindu_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Service', style: text16(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...services.map((service) {
          final type = service['type'] as String;
          final isSelected = selectedService == type;

          return GestureDetector(
            onTap: () => onSelect(type),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.button : AppColors.grey200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(service['icon'] as IconData, color: AppColors.button),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service['title'] as String,
                          style: text15(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          service['description'] as String,
                          style: text12(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: AppColors.button,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimeStep({
    required BuildContext context,
    required String selectedDateText,
    required String selectedTimeText,
    required VoidCallback onPickDate,
    required VoidCallback onPickTime,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick Date & Time', style: text16(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildPickerTile(
          icon: Icons.calendar_today_outlined,
          title: 'Date',
          value: selectedDateText,
          onTap: onPickDate,
        ),
        const SizedBox(height: 12),
        _buildPickerTile(
          icon: Icons.access_time,
          title: 'Time',
          value: selectedTimeText,
          onTap: onPickTime,
        ),
      ],
    );
  }

  Widget _buildOtherDetailsStep({
    required TextEditingController poojaController,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController addressController,
    required TextEditingController notesController,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Other Details', style: text16(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _buildDetailField(
          controller: poojaController,
          label: 'Pooja name',
          icon: Icons.spa_outlined,
        ),
        _buildDetailField(
          controller: nameController,
          label: 'Devotee name',
          icon: Icons.person_outline,
        ),
        _buildDetailField(
          controller: phoneController,
          label: 'Phone number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _buildDetailField(
          controller: addressController,
          label: 'Address',
          icon: Icons.location_on_outlined,
          maxLines: 2,
        ),
        _buildDetailField(
          controller: notesController,
          label: 'Notes',
          icon: Icons.notes_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.button),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text12(color: AppColors.grey600)),
                  const SizedBox(height: 4),
                  Text(value, style: text15(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.button),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.button),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetStep(int step, bool isActive) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.button : AppColors.grey300,
      ),
      child: Text(
        step.toString(),
        style: text12(
          color: isActive ? AppColors.white : AppColors.grey700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSheetLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.button : AppColors.grey300,
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _monthName(int month) {
    const months = [
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
    return months[month - 1];
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

void _showLocationBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows full height if needed
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        height:
            MediaQuery.of(context).size.height *
            0.65, // Adjust height as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select Location",
                  style: text18(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search on Map Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open Google Map or your map screen
                Navigator.pop(context);
              },
              icon: const Icon(Icons.map, color: AppColors.button),
              label: Text(
                "Search on Map",
                style: text14(color: AppColors.button),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 12),

            // Near Me Button
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Get current location
                Navigator.pop(context);
              },
              icon: const Icon(Icons.my_location, color: AppColors.button),
              label: Text("Near Me", style: text14(color: AppColors.button)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Recent / Saved Locations",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Location List
            Expanded(
              child: ListView(
                children: [
                  _buildLocationTile(
                    "MG Road, Near City Mall, Sector 18, Noida",
                    onTap: () {
                      // Update selected location
                      Navigator.pop(context);
                    },
                  ),
                  _buildLocationTile(
                    "Linking Road, Bandra West, Mumbai, Maharashtra",
                    isSelected:
                        true, // Highlight current one like in your image
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  _buildLocationTile(
                    "Brigade Road, Ashok Nagar, Bengaluru, Karnataka",
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper widget for location items
Widget _buildLocationTile(
  String address, {
  bool isSelected = false,
  VoidCallback? onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
    leading: const Icon(Icons.location_on, color: AppColors.warning),
    title: Text(
      address,
      style: text14(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    ),
    onTap: onTap,
    selected: isSelected,
    selectedTileColor: Colors.orange.withOpacity(0.1),
  );
}
