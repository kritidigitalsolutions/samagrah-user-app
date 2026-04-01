import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class DailyPujaEssentialsScreen extends StatelessWidget {
  DailyPujaEssentialsScreen({super.key});

  final controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: CustomAppBar(
        title: 'Daliy Puja Essentials',

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              radius: 18,
              child: Center(
                child: Icon(Icons.search, size: 20, color: AppColors.grey400),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Category Tabs (Left Sidebar)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Category List
                SizedBox(
                  width: 100,
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(
                        AppColors.button,
                      ), // ✅ updated
                      trackColor: WidgetStateProperty.all(Colors.grey.shade200),
                      thickness: WidgetStateProperty.all(4),
                      radius: const Radius.circular(10),
                    ),
                    child: Scrollbar(
                      controller: controller,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: 2,
                      radius: const Radius.circular(5),
                      child: ListView.builder(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        itemCount: 15,
                        padding: const EdgeInsets.only(top: 8),
                        itemBuilder: (context, index) {
                          final bool isSelected =
                              index == 0; // First item selected
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? const Border(
                                            left: BorderSide(
                                              color: Color(0xFFE91E63),
                                              width: 3,
                                            ),
                                          )
                                        : null,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            '🪔',
                                            style: TextStyle(fontSize: 28),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Cotton Wicks\n(Batti)',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // Vertical Divider
                Container(
                  width: 1,
                  color: Colors.grey.shade200,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),

                // Product Grid
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Kumkum Products Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.80,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: 12,
                          itemBuilder: (context, index) {
                            return _buildProductCard(
                              title: 'Kumkum',
                              price: index % 2 == 0 ? '₹50' : '₹60',
                              originalPrice: index % 2 == 0 ? '₹70' : null,
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        // View All Button
                        Center(
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                color: Color(0xFFE91E63),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Promotional Banner
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/id/1015/800/300', // Replace with real puja thali image
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Colors.black54, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Get ₹50 OFF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Add items worth\n₹200 more',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    String? originalPrice,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            // ✅ FIXED HEIGHT
            width: double.infinity,
            alignment: Alignment.center,
            child: Image.asset("assets/icon/kalash.png", height: 50),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text14(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      price,
                      style: text15(
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                    if (originalPrice != null) ...[
                      const SizedBox(width: 3),
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 4),

                AppButton(radius: 8, height: 25, title: "Add", onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
