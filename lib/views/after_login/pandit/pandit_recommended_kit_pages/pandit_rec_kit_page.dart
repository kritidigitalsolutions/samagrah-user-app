import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class PanditRecKitPage extends StatelessWidget {
  const PanditRecKitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Samagri Kit',
        subtitle: 'Pandit Recommended',

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/god.png',
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text('Items Included', style: text18()),
            SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.panditRecKit2);
                      },
                      child: _buildItemCard(item),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: AppButton(title: "Add More Items", onTap: () {}),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔴 Item Card
  Widget _buildItemCard(ItemModel item) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 4, spreadRadius: 6, color: AppColors.grey100),
        ],
      ),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.image,
              height: 50,
              width: 60,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Choose the best product",
                  style: TextStyle(fontSize: 11, color: AppColors.button),
                ),
              ],
            ),
          ),

          /// ARROW
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

/// 🔴 Model
class ItemModel {
  final String title;
  final String image;

  ItemModel({required this.title, required this.image});
}

/// 🔴 Dummy Data
final List<ItemModel> items = [
  ItemModel(title: "Sindoor", image: "assets/icon/sticks.png"),
  ItemModel(title: "Chandan", image: "assets/icon/sticks.png"),
  ItemModel(title: "Agarbatti", image: "assets/icon/sticks.png"),
  ItemModel(title: "Sindoor", image: "assets/icon/sticks.png"),
  ItemModel(title: "Chandan", image: "assets/icon/sticks.png"),
];
