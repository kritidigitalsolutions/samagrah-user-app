import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/views/after_login/product/product_image_viewer_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductImageSlider extends StatefulWidget {
  final List<String> images;

  const ProductImageSlider({super.key, required this.images});

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductImageViewerPage(
              images: widget.images,
              initialIndex: currentIndex,
            ),
          ),
        );
      },
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              viewportFraction: 1,
              enlargeCenterPage: false,
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                });
              },
            ),
            items: widget.images.map((image) {
              final cleanImage = image.replaceAll("\\", "/");

              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomCachedImage(
                  imageUrl: cleanImage,
                  fit: BoxFit.cover,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          AnimatedSmoothIndicator(
            activeIndex: currentIndex,
            count: widget.images.length,
            effect: JumpingDotEffect(
              dotHeight: 8,
              dotWidth: 8,
              jumpScale: 1.4,
              verticalOffset: 10,
              activeDotColor: AppColors.button,
              dotColor: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
