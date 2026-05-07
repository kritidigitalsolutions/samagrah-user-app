import 'package:flutter/material.dart';

import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';

// class BookingConfirmedScreen extends StatelessWidget {
//   const BookingConfirmedScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,

//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Booking Confirmed Header
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       radius: 40,
//                       backgroundColor: AppColors.success.withAlpha(20),
//                       child: Icon(
//                         Icons.check,
//                         color: AppColors.success,
//                         size: 32,
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       'Booking\nConfirmed',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFFD81B60),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Pooja Details Card
//                 Stack(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey.shade200),
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Row(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             child: Container(
//                               width: 60,
//                               height: 60,
//                               color: Colors.orange.shade100,
//                               child: const Icon(
//                                 Icons.temple_hindu,
//                                 color: Colors.orange,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Griha Pravesh',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   'Date: 13 March 2025',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 Text(
//                                   'Time: 11:00 AM - 1:00 PM',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 Text(
//                                   '2A/12 Shastri Nagar, Meerut',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: Consumer(
//                         builder: (context, ref, child) {
//                           final selectedService =
//                               ref.watch(selectedServiceProvider)
//                                   as ServiceModel;
//                           return Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               color: AppColors.button,
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   serviceIcon(selectedService.type),
//                                   size: 15,
//                                   color: AppColors.white,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   (selectedService.title),
//                                   style: text11(
//                                     fontWeight: FontWeight.bold,
//                                     color: AppColors.white,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 // Pandit Details Card
//                 Stack(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: AppColors.grey200),
//                       ),
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 radius: 30,
//                                 backgroundColor: AppColors.grey200,
//                                 child: const Icon(Icons.person, size: 32),
//                               ),
//                               const SizedBox(width: 12),
//                               const Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'Pandit Vishal\nSharma',
//                                           style: TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         SizedBox(width: 8),
//                                         Icon(
//                                           Icons.verified,
//                                           color: Color(0xFF4CAF50),
//                                           size: 16,
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.star,
//                                           color: Colors.amber,
//                                           size: 14,
//                                         ),
//                                         SizedBox(width: 4),
//                                         Text(
//                                           '4.8',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       '10+ Years Experience',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                     Text(
//                                       'Hindi | Sanskrit',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: AppColors.green,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       FaIcon(
//                                         FontAwesomeIcons.whatsapp,
//                                         color: AppColors.white,
//                                         size: 14,
//                                       ),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         'Chat on WhatsApp',
//                                         style: text10(
//                                           color: AppColors.white,

//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 10),
//                               Expanded(
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 12,
//                                     vertical: 6,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     border: Border.all(color: AppColors.button),
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.location_on,
//                                         color: AppColors.button,
//                                         size: 14,
//                                       ),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         'Track your pandit',
//                                         style: text10(
//                                           color: AppColors.button,

//                                           fontWeight: FontWeight.w600,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     Positioned(
//                       top: 0,
//                       right: 0,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: AppColors.green,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(Icons.call, color: Colors.white, size: 14),
//                             SizedBox(width: 4),
//                             Text(
//                               'Call Pandit Ji',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Recommendation Cards
//                 buildRecommendationCard(
//                   'Keep this required',
//                   'Pooja Samagri',
//                   'ready before the pandit ji arrives',
//                   true,
//                   () {
//                     Navigator.pushNamed(context, AppRoutes.panditRecKit);
//                   },
//                 ),
//                 const SizedBox(height: 12),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// IconData serviceIcon(String type) {
//   switch (type.toLowerCase()) {
//     case "home":
//       return Icons.home;

//     case "online":
//       return Icons.online_prediction_outlined;

//     case "temple":
//       return Icons.temple_hindu;

//     default:
//       return Icons.miscellaneous_services; // fallback icon
//   }
// }

Widget buildRecommendationCard(
  String badge,
  String title,
  String description,
  bool isPrimary,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? AppColors.button
                            : Colors.transparent,
                        border: Border.all(
                          color: isPrimary
                              ? Colors.transparent
                              : AppColors.white,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: text10(
                          color: AppColors.white,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: text18(
                        color: AppColors.yellow,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: text12(
                        color: AppColors.grey300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.yellow,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'View All',
                        style: text11(
                          color: AppColors.black,

                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Image.asset(
            "assets/icon/plate.png",
            width: 130,
            height: 130,
            fit: BoxFit.contain,
          ),
        ),
      ],
    ),
  );
}
