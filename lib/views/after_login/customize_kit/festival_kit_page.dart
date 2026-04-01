import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';

class FestivalKitPage extends StatelessWidget {
  const FestivalKitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Special Kit for\nFestivals Kit',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/hands.png',
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              SizedBox(height: 10),

              /// Search Bar
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search festival kit...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Icon(Icons.search, color: AppColors.grey),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// List
              Expanded(
                child: ListView(
                  children: const [
                    FestivalCard(
                      title: "Diwali Pooja Kit",
                      subtitle:
                          "Complete kit for Lakshmi\nPooja and Diwali rituals",
                      image: "assets/god.png",
                    ),
                    FestivalCard(
                      title: "Ganesh Chaturthi Kit",
                      subtitle: "Essential pooja items for\nGanesh worship",
                      image: "assets/god.png",
                    ),
                    FestivalCard(
                      title: "Diwali Pooja Kit",
                      subtitle:
                          "Complete kit for Lakshmi\nPooja and Diwali rituals",
                      image: "assets/god.png",
                    ),
                    FestivalCard(
                      title: "Ganesh Chaturthi Kit",
                      subtitle: "Essential pooja items for\nGanesh worship",
                      image: "assets/god.png",
                    ),

                    SizedBox(height: 10),

                    Center(
                      child: Text(
                        "View More",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FestivalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String image;

  const FestivalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.festivalKitDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text16(
                      color: AppColors.white,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: text12(color: AppColors.grey400)),
                  const Spacer(),

                  /// Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "View Kit",
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// Image
            Image.asset(image, height: 110, fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }
}
