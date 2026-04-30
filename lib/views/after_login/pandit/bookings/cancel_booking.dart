import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class CancelBooking extends StatefulWidget {
  const CancelBooking({super.key});

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    controller.repeat(reverse: true); // 🔥 continuous animation
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 2,
            color: AppColors.white,
            shadowColor: AppColors.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ Animated Success Icon
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(50),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 40,
                        color: AppColors.success,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Booking Cancelled',
                    style: text20(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Your booking for Satyanarayan Pooja with Pandit Vishal Sharma has been successfully cancelled',
                    textAlign: TextAlign.center,
                    style: text15(color: AppColors.grey).copyWith(height: 1.4),
                  ),

                  const SizedBox(height: 30),

                  AppOutlineButton(
                    radius: 8,
                    title: "Back To Home",
                    onTap: () {
                      Navigator.pop(context); // close bottom sheet
                      Navigator.pop(context); // back previous screen
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
