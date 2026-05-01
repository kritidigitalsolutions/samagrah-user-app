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
  });

  @override
  Widget build(BuildContext context) {
    final bool isValidUrl =
        imageUrl.isNotEmpty && Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    Widget image;

    if (!isValidUrl) {
      image =
          errorWidget ??
          Container(
            height: height,
            width: width,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported, size: 40),
          );
    } else {
      image = CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: fit,

        placeholder: (context, url) =>
            placeholder ??
            Center(
              child: SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: loaderColor,
                ),
              ),
            ),

        errorWidget: (context, url, error) =>
            errorWidget ??
            Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image, size: 40),
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
