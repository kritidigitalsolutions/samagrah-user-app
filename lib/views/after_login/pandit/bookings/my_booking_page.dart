import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';

class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "My Bookings",
        subtitle: "View and manage your pandit bookings",
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
            /// Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: const [
                  BookingTab(text: "Upcoming", isSelected: true),
                  SizedBox(width: 10),
                  BookingTab(text: "Completed"),
                  SizedBox(width: 10),
                  BookingTab(text: "Cancelled"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  BookingCard(
                    type: "Home Visit",
                    title: "Satyanarayan Pooja",
                    date: "12 Nov 2026",
                    time: "10:00 AM — 12:00 PM",
                    image: "assets/retual.png",
                    onTap: () {
                      ref.watch(typeSelected.notifier).state = "home";
                      Navigator.pushNamed(context, AppRoutes.myBookingDetails);
                    },
                  ),
                  BookingCard(
                    type: "Online Pooja (Video Call)",
                    title: "Lakshmi Pooja",
                    date: "12 Nov 2026",
                    time: "10:00 AM — 12:00 PM",
                    image: "assets/retual.png",
                    onTap: () {
                      ref.watch(typeSelected.notifier).state = "online";
                      Navigator.pushNamed(context, AppRoutes.myBookingDetails);
                    },
                  ),
                  BookingCard(
                    type: "Temple Pooja",
                    title: "Navgraha Shanti Pooja",
                    date: "12 Nov 2026",
                    time: "10:00 AM — 12:00 PM",
                    image: "assets/retual.png",
                    onTap: () {
                      ref.watch(typeSelected.notifier).state = "temple";
                      Navigator.pushNamed(context, AppRoutes.myBookingDetails);
                    },
                  ),
                ],
              ),
            ),
          ],
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
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.type,
    required this.title,
    required this.date,
    required this.time,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  /// Type Badge
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

                  /// Button
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
    );
  }
}

class BookingTab extends StatelessWidget {
  final String text;
  final bool isSelected;

  const BookingTab({super.key, required this.text, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.button),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? AppColors.white : AppColors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
