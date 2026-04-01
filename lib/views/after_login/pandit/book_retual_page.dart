import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';

class BookRetualPage extends StatefulWidget {
  const BookRetualPage({super.key});

  @override
  State<BookRetualPage> createState() => _BookRitualViewState();
}

class _BookRitualViewState extends State<BookRetualPage> {
  String? selectedRitual;

  final List<RitualItem> rituals = [
    RitualItem(
      'Satyanarayan Pooja',
      'A sacred ritual for prosperity and blessings',
      'assets/retual.png',
    ),
    RitualItem(
      'Griha Pravesh',
      'Ritual for entering a new home',
      'assets/retual.png',
    ),
    RitualItem(
      'Mundan Ceremony',
      'First haircut ritual for children',
      'assets/retual.png',
    ),
    RitualItem(
      'Wedding Ritual',
      'Traditional Hindu marriage rituals',
      'assets/retual.png',
    ),

    RitualItem(
      'Mundan Ceremony',
      'First haircut ritual for children',
      'assets/retual.png',
    ),
    RitualItem(
      'Wedding Ritual',
      'Traditional Hindu marriage rituals',
      'assets/retual.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Column(
          children: [
            /// 🔹 Header Section (Custom AppBar Style)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Info Row
                Container(
                  color: AppColors.headerCard,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book your Pandit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schedule a pandit for your\nritual needs',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/panditLogo.png',
                        width: 70,
                        height: 70,
                        errorBuilder: (context, exception, stackTrace) {
                          return Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(color: AppColors.grey500),
                            child: Center(child: Icon(Icons.image)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: const Text(
                          'Choose the ritual you would like to perform',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // search bar
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search ritual...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Icon(Icons.search, color: Colors.grey.shade600),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// 🔹 Ritual List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: rituals.length,
                itemBuilder: (context, index) {
                  final ritual = rituals[index];
                  final isSelected = selectedRitual == '${ritual.title}_$index';

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedRitual = '${ritual.title}_$index';
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE91E63)
                              : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ritual.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ritual.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 10),

                          /// Image
                          Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(ritual.imagePath),
                                fit: BoxFit.cover,
                                onError: (exception, stackTrace) {
                                  Container(
                                    width: 65,
                                    height: 65,
                                    decoration: BoxDecoration(
                                      color: AppColors.grey500,
                                    ),
                                    child: Center(child: Icon(Icons.image)),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /// 🔹 Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: AppButton(
                title: 'Next >',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.bookPandit);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 Model
class RitualItem {
  final String title;
  final String description;
  final String imagePath;

  RitualItem(this.title, this.description, this.imagePath);
}
