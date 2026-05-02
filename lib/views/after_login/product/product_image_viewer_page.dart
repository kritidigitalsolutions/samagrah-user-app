import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
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

  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  Future<void> downloadImage() async {
    try {
      setState(() => isDownloading = true);

      final permission = await Permission.storage.request();

      if (!permission.isGranted) {
        AppSnackbar.show(
          context,
          message: 'Storage permission denied',
          type: SnackBarType.warning,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
        return;
      }

      final imageUrl = widget.images[currentIndex];

      debugPrint("⬇️ Downloading image: $imageUrl");

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Dio().download(imageUrl, filePath);

      await ImageGallerySaverPlus.saveFile(filePath);

      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Image downloaded successfully',
          type: SnackBarType.success,
        );
      }

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint("❌ Download error: $e");
      AppSnackbar.show(
        context,
        message: 'Download failed: $e',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => isDownloading = false);
      }
    }
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
        actions: [
          IconButton(
            onPressed: isDownloading ? null : downloadImage,
            icon: isDownloading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                : const Icon(Icons.download),
          ),
        ],
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
