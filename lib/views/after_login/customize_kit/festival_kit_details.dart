import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class FestivalKitDetails extends StatelessWidget {
  const FestivalKitDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Diwali Pooja Kit',
        subtitle:
            'A complete pooja kit specially\nprepared for Diwali Lakshmi Pooja with all essential items',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/god.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(color: AppColors.grey500),
                  child: Center(child: Icon(Icons.image)),
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

            // total price
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.button,
              ),
              child: Row(
                children: [
                  Text(
                    "Kit Price",
                    style: text15(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "250",
                    style: text15(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.all(16),
              elevation: 1,
              color: AppColors.white,
              child: ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.green,
                ),
                title: Text(
                  "Save ₹80 compared to buying items individually",
                  style: text13(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.save_outlined),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: AppButton(
                title: "Buy Now",
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.orderSummary);
                },
              ),
            ),
            SizedBox(height: 10),
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
                  "View Product",
                  style: TextStyle(fontSize: 11, color: AppColors.button),
                ),
              ],
            ),
          ),

          /// ARROW
          Text("75", style: text18(color: AppColors.button)),
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
