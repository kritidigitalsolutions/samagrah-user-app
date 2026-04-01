import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        subtitle: "Stay updated with your orders,\nbookings, and offers",

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.warningLight.withAlpha(50),
              radius: 25,
              child: Center(
                child: Image.asset(
                  "assets/icon/noti.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),

      body: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: 3,
        itemBuilder: (context, index) {
          return _buildActivityItem(
            title:
                'Your order for Clay Diyas (Pack of 10) is on the way and will arrive soon',
            subtitle: 'Order #45821',
            time: '2 min ago',
            isUnread: index == 0, // first item unread
          );
        },
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 ICON
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.button.withOpacity(0.1),
            child: Icon(Icons.notifications, color: AppColors.button, size: 22),
          ),

          const SizedBox(width: 12),

          /// 🔹 TEXT AREA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE + DOT
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: text15(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    /// 🔴 Unread dot
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                /// SUBTITLE
                Text(
                  subtitle,
                  style: text13(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 8),

                /// TIME
                Text(
                  time,
                  style: text12(
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
