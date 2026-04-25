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
                              Navigator.pushNamed(
                                context,
                                AppRoutes.serviceSelection,
                              );
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
