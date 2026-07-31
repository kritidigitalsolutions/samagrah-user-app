import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';

class ProductImageViewerPage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ProductImageViewerPage({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ProductImageViewerPage> createState() => _OrderImageViewerPageState();
}

class _OrderImageViewerPageState extends State<ProductImageViewerPage> {
  late final PageController _pageController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          '${currentIndex + 1}/${widget.images.length}',
          style: text15(color: AppColors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });

          debugPrint('🖼️ Current image index: $currentIndex');
        },
        itemBuilder: (context, index) {
          return PhotoView(
            imageProvider: NetworkImage(widget.images[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 4,
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            loadingBuilder: (context, event) {
              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
