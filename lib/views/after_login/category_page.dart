import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(color: AppColors.headerCard),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prepare for your',
                          style: text15(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Pooja today',
                          style: text15(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Meerut, UP', // 👈 dynamic bhi kar sakte ho
                              style: text12(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.profile);
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.grey500,
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              child: TextField(
                style: text14(
                  fontWeight: FontWeight.normal,
                  color: AppColors.white,
                ),
                cursorColor: AppColors.white,
                decoration: InputDecoration(
                  hintText: 'diya, agarbatti thali...',
                  hintStyle: text14(color: AppColors.grey100),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.grey100,
                  ),
                  filled: true,
                  fillColor: AppColors.primary,
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

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 8),
                children: [
                  //=================================================================
                  // Everyday Ritual Items
                  //=====================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Everyday Ritual Items',
                          style: text15(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.dalityPujaE);
                          },
                          child: Text(
                            'View all >',
                            style: text13(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warningDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                          );
                        },
                        child: _buildProductCard(
                          'Khatak',

                          'assets/icon/kalash.png', // Replace with your image or use NetworkImage
                        ),
                      );
                    },
                  ),

                  //==========================================================
                  // Most Used Items in Samagri
                  //==========================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Most Used Items in Samagri',
                          style: text15(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.dalityPujaE);
                          },
                          child: Text(
                            'View all >',
                            style: text13(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warningDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                          );
                        },
                        child: _buildProductCard(
                          'Khatak',

                          'assets/icon/kalash.png', // Replace with your image or use NetworkImage
                        ),
                      );
                    },
                  ),

                  //============================================================
                  // Ritual Essentials
                  //===================================================================
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ritual Essentials',
                          style: text15(fontWeight: FontWeight.bold),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.dalityPujaE);
                          },
                          child: Text(
                            'View all >',
                            style: text13(
                              fontWeight: FontWeight.w600,
                              color: AppColors.warningDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productDetails,
                          );
                        },
                        child: _buildProductCard(
                          'Khatak',

                          'assets/icon/kalash.png', // Replace with your image or use NetworkImage
                        ),
                      );
                    },
                  ),
                ],
              ),
            ), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, String image) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔝 Image + Heart Icon
          Expanded(
            child: Stack(
              children: [
                Center(child: Image.asset(image, height: 90)),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey.shade300),

          // 🔽 Details Section
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Discount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '65% off',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Old Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rs. 149/-',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      'Rs. 100/-',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB71C1C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),

                AppButton(
                  height: 22,
                  radius: 4,
                  textStyle: text11(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
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
