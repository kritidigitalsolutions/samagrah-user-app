import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
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
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final poojaName = (args?['poojaName'] as String?)?.trim();
    final panditName = (args?['panditName'] as String?)?.trim();
    final panditImage = (args?['panditImage'] as String?)?.trim();
    final bookingDate = (args?['bookingDate'] as String?)?.trim();

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
                    'Your booking${poojaName?.isNotEmpty == true ? ' for $poojaName' : ''}${panditName?.isNotEmpty == true ? ' with $panditName' : ''} has been successfully cancelled.',
                    textAlign: TextAlign.center,
                    style: text15(color: AppColors.grey).copyWith(height: 1.4),
                  ),

                  if (poojaName?.isNotEmpty == true ||
                      panditName?.isNotEmpty == true ||
                      panditImage?.isNotEmpty == true ||
                      bookingDate?.isNotEmpty == true) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.grey50),
                      ),
                      child: Column(
                        children: [
                          ClipOval(
                            child: CustomCachedImage(
                              imageUrl: panditImage ?? '',
                              height: 56,
                              width: 56,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                height: 56,
                                width: 56,
                                color: AppColors.grey50,
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (poojaName?.isNotEmpty == true)
                            _DetailRow(label: 'Pooja', value: poojaName!),
                          if (panditName?.isNotEmpty == true)
                            _DetailRow(label: 'Pandit', value: panditName!),
                          if (bookingDate?.isNotEmpty == true)
                            _DetailRow(label: 'Date', value: bookingDate!),
                        ],
                      ),
                    ),
                  ],

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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: text12(
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: text12(fontWeight: FontWeight.w600),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
