import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';

// =============================================================
// custom app bar
//====================================================================

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.headerCard,
      elevation: 1,
      shadowColor: AppColors.button,
      surfaceTintColor: AppColors.white,
      titleSpacing: 0,

      leading: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(Icons.keyboard_arrow_left, color: AppColors.black),
        onPressed: onBack ?? () => Navigator.pop(context),
      ),

      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: text18()),

          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: text13(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),

      actions: actions?.isNotEmpty == true ? actions : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomCachedImage extends StatelessWidget {
  final String imageUrl;

  // Size
  final double? height;
  final double? width;

  // UI
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  // Placeholder & Error
  final Widget? placeholder;
  final Widget? errorWidget;

  // Loader color
  final Color loaderColor;

  // Optional overlay
  final Widget? overlay;

  // Tap
  final VoidCallback? onTap;

  // Cache limits
  final int? memCacheWidth;
  final int? memCacheHeight;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;

  const CustomCachedImage({
    super.key,
    required this.imageUrl,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.placeholder,
    this.errorWidget,
    this.loaderColor = AppColors.grey,
    this.overlay,
    this.onTap,
    this.memCacheWidth,
    this.memCacheHeight,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim().replaceAll(r'\', '/');
    final bool isValidUrl =
        cleanUrl.isNotEmpty && Uri.tryParse(cleanUrl)?.hasAbsolutePath == true;

    Widget image;

    if (!isValidUrl) {
      image =
          errorWidget ??
          Container(
            height: height,
            width: width,
            color: Colors.grey.shade100,
            child: Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: (height != null && height! < 50) ? 16 : 28,
                color: Colors.grey.shade400,
              ),
            ),
          );
    } else {
      // Calculate smart downsampling so massive PNGs/JPEGs don't saturate memory & decoding threads
      int? calcMemWidth = memCacheWidth;
      int? calcMemHeight = memCacheHeight;

      if (calcMemWidth == null && calcMemHeight == null) {
        if (width != null && width! > 0 && width!.isFinite) {
          calcMemWidth = (width! * 2.5).round();
        } else if (height != null && height! > 0 && height!.isFinite) {
          calcMemHeight = (height! * 2.5).round();
        } else {
          calcMemWidth = 600;
        }
      }

      image = CachedNetworkImage(
        imageUrl: cleanUrl,
        height: height,
        width: width,
        fit: fit,
        memCacheWidth: calcMemWidth,
        memCacheHeight: calcMemHeight,
        maxWidthDiskCache: maxWidthDiskCache ?? 800,
        maxHeightDiskCache: maxHeightDiskCache ?? 800,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        placeholder: (context, url) =>
            placeholder ??
            Container(
              height: height,
              width: width,
              color: Colors.grey.shade100,
              child: Center(
                child: SizedBox(
                  height: (height != null && height! < 50) ? 14 : 22,
                  width: (height != null && height! < 50) ? 14 : 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: loaderColor,
                  ),
                ),
              ),
            ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              height: height,
              width: width,
              color: Colors.grey.shade100,
              child: Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: (height != null && height! < 50) ? 16 : 28,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
      );
    }

    /// 🎨 Shape handling
    if (shape == BoxShape.circle) {
      image = ClipOval(child: image);
    } else if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    /// 🧩 Overlay support
    if (overlay != null) {
      image = Stack(
        children: [
          Positioned.fill(child: image),
          Positioned.fill(child: overlay!),
        ],
      );
    }

    /// 👆 Tap support
    if (onTap != null) {
      image = GestureDetector(onTap: onTap, child: image);
    }

    return image;
  }
}
