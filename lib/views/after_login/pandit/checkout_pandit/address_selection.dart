import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';

// Screen 1: Address Selection Screen
class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _addressController = TextEditingController(
    text: 'B-245, Shastri Nagar\nMeerut, Uttar Pradesh - 250004',
  );

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
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            decoration: BoxDecoration(color: AppColors.headerCard),
            child: buildCustomStepper(),
          ),
          const SizedBox(height: 24),
          // Select Address Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _addressController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(16),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              right: 12,
                              bottom: 12,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD81B60),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFFD81B60),
                      ),
                      label: const Text(
                        'Add Address',
                        style: TextStyle(color: Color(0xFFD81B60)),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD81B60)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Next Button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(color: AppColors.button),
            child: AppButton(
              title: "Next",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.bookingSummary);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCustomStepper() {
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
            buildCircle("3", true),
          ],
        ),
        const SizedBox(height: 8),

        bottomLable(),
      ],
    );
  }

  // Widget _buildProgressStep(String number, String label, bool isActive) {
  //   return Column(
  //     children: [
  //       Container(
  //         width: 32,
  //         height: 32,
  //         decoration: BoxDecoration(
  //           color: isActive ? AppColors.button : Colors.white,
  //           shape: BoxShape.circle,
  //           border: Border.all(
  //             color: isActive ? AppColors.button : Colors.grey.shade300,
  //             width: 2,
  //           ),
  //         ),
  //         child: Center(
  //           child: Text(
  //             number,
  //             style: TextStyle(
  //               color: isActive ? Colors.white : Colors.grey,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 14,
  //             ),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       SizedBox(
  //         width: 70,
  //         child: Text(
  //           label,
  //           textAlign: TextAlign.center,
  //           style: TextStyle(
  //             fontSize: 10,
  //             color: isActive ? Colors.black : Colors.grey,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
