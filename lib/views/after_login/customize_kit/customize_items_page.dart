import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class CustomizeItemsPage extends StatefulWidget {
  const CustomizeItemsPage({super.key});

  @override
  State<CustomizeItemsPage> createState() => _CustomizeItemsPageState();
}

class _CustomizeItemsPageState extends State<CustomizeItemsPage> {
  int selectedTab = 0;

  final List<TabItem> tabs = [
    TabItem('All', Icons.grid_view),
    TabItem('Agarbatti', Icons.local_fire_department),
    TabItem('Wax', Icons.light_mode),
    TabItem('Kumkum', Icons.spa),
    TabItem('Flowers', Icons.local_florist),
    TabItem('Haldi', Icons.circle),
  ];

  final products = [
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
    KitProduct('Kalash', 'Rs 79/-', 'Rs 100/-'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Customize\nYour Pooja Kit',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset("assets/icon/plate.png", width: 70, height: 70),
          ),
        ],
      ),

      body: Column(
        children: [
          // Search Bar
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'diya, puja thali...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
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

          // Tabs
          Container(
            height: 45,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.button
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tabs[index].icon,
                          size: 14,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tabs[index].title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Promotional Banners
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Row(
              children: [
                Expanded(
                  child: _buildPromoBanner(
                    Icons.local_offer,
                    'Get 5% Off on your first\npooja package order',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPromoBanner(
                    Icons.delivery_dining,
                    'Free Delivery on Puja Essentials\nOn orders above ₹499',
                  ),
                ),
              ],
            ),
          ),

          // Products Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(15),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _buildProductCard(products[index]);
              },
            ),
          ),

          // Next Button
          Container(
            decoration: BoxDecoration(
              color: AppColors.button,
              // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
            child: AppButton(
              title: "Next",
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.selectedCusKit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.button, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(KitProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
                image: DecorationImage(
                  image: AssetImage("assets/icon/sticks.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      product.discountedPrice,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.button,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.originalPrice,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppButton(
                  radius: 8,
                  textStyle: text12(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                  height: 25,
                  title: "Add",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KitProduct {
  final String name;
  final String discountedPrice;
  final String originalPrice;

  KitProduct(this.name, this.discountedPrice, this.originalPrice);
}

class TabItem {
  final String title;
  final IconData icon;

  TabItem(this.title, this.icon);
}
