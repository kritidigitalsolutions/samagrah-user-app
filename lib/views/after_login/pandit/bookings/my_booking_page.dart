import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:intl/intl.dart';

final bookingFilterProvider = StateProvider<String>((ref) => "All");

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  String _mapStatus(String? status) {
    if (status == null) return "Pending";

    // Map API status to filter status
    switch (status.toLowerCase()) {
      case "pending":
        return "Pending";
      case "confirmed":
        return "Confirmed";
      case "completed":
        return "Completed";
      case "cancelled":
        return "Cancelled";
      default:
        return "Pending";
    }
  }

  String _formatBookingType(String? bookingMode) {
    if (bookingMode == null) return "Home Visit";

    switch (bookingMode.toLowerCase()) {
      case "home":
        return "Home Visit";
      case "online":
        return "Online Pooja (Video Call)";
      case "temple":
        return "Temple Pooja";
      default:
        return "Home Visit";
    }
  }

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
    final selectedFilter = ref.watch(bookingFilterProvider);
    final bookingsAsync = ref.watch(panditBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "My Bookings",
        subtitle: "View and manage your pandit bookings",
      ),
      body: bookingsAsync.when(
        data: (bookingsData) {
          final allBookings = bookingsData.data;

          /// ✅ FILTER LOGIC
          final filteredBookings = selectedFilter == "All"
              ? allBookings
              : allBookings
                    .where((b) => _mapStatus(b.bookingStatus) == selectedFilter)
                    .toList();

          return SafeArea(
            child: Column(
              children: [
                /// ✅ FILTER TABS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildTab(ref, "All"),
                      _buildTab(ref, "Pending"),
                      _buildTab(ref, "Confirmed"),
                      _buildTab(ref, "Completed"),
                      _buildTab(ref, "Cancelled"),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// ✅ LIST
                Expanded(
                  child: filteredBookings.isEmpty
                      ? Center(
                          child: Text(
                            "No bookings found",
                            style: text14(color: AppColors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = filteredBookings[index];

                            return BookingCard(
                              type: _formatBookingType(booking.bookingMode),
                              title:
                                  booking.ritual?.name ??
                                  booking.ritualRef?.title ??
                                  "Pooja",
                              date: _formatDate(booking.bookingDate),
                              time: _formatTime(
                                booking.dateAndTime?.dateAndTime,
                              ),
                              image:
                                  booking.ritual?.image ??
                                  booking.ritualRef?.image ??
                                  "assets/retual.png",
                              status: _mapStatus(booking.bookingStatus),
                              panditName:
                                  booking.pandit?.fullName ?? "Pandit Ji",
                              onTap: () {
                                ref.watch(typeSelected.notifier).state =
                                    booking.bookingMode?.toLowerCase() ??
                                    "home";
                                ref
                                        .watch(selectedBookingProvider.notifier)
                                        .state =
                                    booking;
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.myBookingDetails,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: "My Bookings",
            subtitle: "View and manage your pandit bookings",
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                SizedBox(height: 16),
                Text(
                  "Failed to load bookings",
                  style: text16(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: text12(color: AppColors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(panditBookingProvider),
                  child: Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 TAB BUILDER
  Widget _buildTab(WidgetRef ref, String text) {
    final selected = ref.watch(bookingFilterProvider);

    return GestureDetector(
      onTap: () {
        ref.read(bookingFilterProvider.notifier).state = text;
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        decoration: BoxDecoration(
          color: selected == text ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.button),
        ),
        child: Text(
          text,
          style: text12(
            color: selected == text ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final String type;
  final String title;
  final String date;
  final String time;
  final String image;
  final String status;
  final String panditName;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.image,
    required this.status,
    required this.panditName,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Confirmed":
        return Colors.blue;
      case "Completed":
        return AppColors.green;
      case "Cancelled":
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                /// LEFT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TYPE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warningLighter,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(type, style: text10()),
                      ),

                      const SizedBox(height: 8),

                      Text(title, style: text14(fontWeight: FontWeight.bold)),

                      const SizedBox(height: 6),
                      Text(date, style: text12()),
                      Text(time, style: text12()),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "View Details",
                          style: text12(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                /// IMAGE
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomCachedImage(
                        imageUrl: image,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(panditName, style: const TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          /// 🔥 STATUS BADGE (TOP RIGHT)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
              child: Text(
                status,
                style: text10(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
