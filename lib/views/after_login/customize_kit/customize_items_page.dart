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
    TabItem('All', "assets/home/select-all.png"),
    TabItem('Agarbatti', "assets/home/incense.png"),
    TabItem('Diya', "assets/home/lamp.png"),
    TabItem('Fruits', "assets/home/fruit.png"),
    TabItem('Flowers', "assets/home/flower.png"),
    TabItem('Mala(Gralands)', "assets/home/mala.png"),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: text14(
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
              cursorColor: AppColors.black,
              decoration: InputDecoration(
                hintText: 'diya, puja thali...',
                hintStyle: text14(color: AppColors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Tabs
          SingleChildScrollView(
            padding: EdgeInsets.only(left: 12, right: 12),
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 10,
              children: List.generate(tabs.length, (index) {
                final isSelected = selectedTab == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.button.withAlpha(30)
                          : AppColors.grey200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          tabs[index].img,
                          width: 18,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          tabs[index].title,
                          style: text11(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.button
                                : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Promotional Banners
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 10, 12, 0),
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
        color: AppColors.white,
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
  final String img;

  TabItem(this.title, this.img);
}
