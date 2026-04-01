import 'package:dotted_line/dotted_line.dart';
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

Widget buildDottedLine() {
  return Expanded(
    child: DottedLine(
      dashLength: 4,
      dashGapLength: 2,
      lineThickness: 2,
      dashColor: AppColors.button,
    ),
  );
}

Widget buildCircle(String text, bool isActive) {
  return Container(
    width: 28,
    height: 28,
    margin: EdgeInsets.all(0),
    decoration: BoxDecoration(
      color: isActive ? AppColors.button : AppColors.white,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        text,
        style: text12(
          color: isActive ? AppColors.white : AppColors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget bottomLable() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: const [
      SizedBox(
        width: 80,
        child: Text(
          "Select Pooja Mode",
          textAlign: TextAlign.start,
          style: TextStyle(fontSize: 10),
        ),
      ),
      SizedBox(
        width: 80,
        child: Text(
          "Select Date & Time",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10),
        ),
      ),
      SizedBox(
        width: 80,
        child: Text(
          "Select Address",
          textAlign: TextAlign.end,
          style: TextStyle(fontSize: 10),
        ),
      ),
    ],
  );
}
