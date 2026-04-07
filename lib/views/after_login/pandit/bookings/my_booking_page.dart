import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';

final bookingFilterProvider = StateProvider<String>((ref) => "All");

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(bookingFilterProvider);

    final allBookings = [
      {
        "type": "Home Visit",
        "type1": "home",
        "title": "Satyanarayan Pooja",
        "date": "12 Nov 2026",
        "time": "10:00 AM — 12:00 PM",
        "image": "assets/retual.png",
        "status": "Pending",
      },
      {
        "type": "Online Pooja (Video Call)",
        "type1": "online",
        "title": "Lakshmi Pooja",
        "date": "12 Nov 2026",
        "time": "10:00 AM — 12:00 PM",
        "image": "assets/retual.png",
        "status": "Completed",
      },
      {
        "type": "Temple Pooja",
        "type1": "temple",
        "title": "Navgraha Shanti Pooja",
        "date": "12 Nov 2026",
        "time": "10:00 AM — 12:00 PM",
        "image": "assets/retual.png",
        "status": "Confirmed",
      },

      {
        "type": "Online Pooja (Video Call)",
        "type1": "online",
        "title": "Lakshmi Pooja",
        "date": "12 Nov 2026",
        "time": "10:00 AM — 12:00 PM",
        "image": "assets/retual.png",
        "status": "Cancelled",
      },
    ];

    /// ✅ FILTER LOGIC
    final filteredBookings = selectedFilter == "All"
        ? allBookings
        : allBookings.where((b) => b["status"] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "My Bookings",
        subtitle: "View and manage your pandit bookings",
      ),
      body: SafeArea(
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
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredBookings.length,
                itemBuilder: (context, index) {
                  final booking = filteredBookings[index];

                  return BookingCard(
                    type: booking["type"]!,
                    title: booking["title"]!,
                    date: booking["date"]!,
                    time: booking["time"]!,
                    image: booking["image"]!,
                    status: booking["status"]!,
                    onTap: () {
                      ref.watch(typeSelected.notifier).state =
                          booking["type1"]!;
                      Navigator.pushNamed(context, AppRoutes.myBookingDetails);
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
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.image,
    required this.status,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Confirmed":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
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
                        child: Text(type, style: const TextStyle(fontSize: 10)),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 6),
                      Text(date, style: const TextStyle(fontSize: 12)),
                      Text(time, style: const TextStyle(fontSize: 12)),

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
                        child: const Text(
                          "View Details",
                          style: TextStyle(color: Colors.white, fontSize: 12),
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
                      child: Image.asset(
                        image,
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Pandit Vishal Sharma",
                      style: TextStyle(fontSize: 10),
                    ),
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
                borderRadius: BorderRadius.circular(20),
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
