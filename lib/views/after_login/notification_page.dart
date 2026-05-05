import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';

import '../../model/response/notification_list_res.dart';
import '../../view_model/after_login_provider/home_provider/notification_provider.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // ✅ Refresh on every page open
    Future.microtask(() => ref.read(notificationProvider.notifier).fetch());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Notifications',
        subtitle: "Stay updated with your orders,\nbookings, and offers",
        actions: [
          if (state.notifications.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (val) {
                if (val == 'clear') _showClearConfirmDialog(context);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Clear All'),
                    ],
                  ),
                ),
              ],
            ),
          // Padding(
          //   padding: const EdgeInsets.only(right: 16),
          //   child: CircleAvatar(
          //     backgroundColor: AppColors.warningLight.withAlpha(50),
          //     radius: 25,
          //     child: Image.asset(
          //       "assets/icon/noti.png",
          //       width: 30,
          //       height: 30,
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(state.filter),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.notifications.isEmpty
                ? _buildError()
                : state.notifications.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
              // ✅ Pull to refresh
              onRefresh: () =>
                  ref.read(notificationProvider.notifier).fetch(),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(15),
                itemCount: state.notifications.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: CircularProgressIndicator()),
                    );
                  }
                  return _buildNotificationCard(
                      state.notifications[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(NotificationFilter current) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _filterChip('All', NotificationFilter.all, current),
          const SizedBox(width: 8),
          _filterChip('Unread', NotificationFilter.unread, current),
          const SizedBox(width: 8),
          _filterChip('Read', NotificationFilter.read, current),
        ],
      ),
    );
  }

  Widget _filterChip(
      String label, NotificationFilter filter, NotificationFilter current) {
    final isSelected = current == filter;
    return GestureDetector(
      onTap: () =>
          ref.read(notificationProvider.notifier).changeFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.button : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: text13(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ✅ Tap opens bottom sheet, swipe deletes
  Widget _buildNotificationCard(NotificationItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 26),
      ),
      onDismissed: (_) =>
          ref.read(notificationProvider.notifier).deleteOne(item.id),
      child: GestureDetector(
        // ✅ Tap → open bottom sheet
        onTap: () {
          if (!item.isRead) {
            ref.read(notificationProvider.notifier).markAsRead(item.id);
          }
          _showNotificationSheet(context, item);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : AppColors.button.withAlpha(10),
            borderRadius: BorderRadius.circular(14),
            border: item.isRead
                ? null
                : Border.all(
                color: AppColors.button.withAlpha(40), width: 1),
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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.button.withOpacity(0.1),
                child: Icon(Icons.notifications,
                    color: AppColors.button, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text15(
                                  fontWeight: item.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: text13(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w400),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatTime(item.createdAt),
                                style: text12(
                                    color: Colors.grey, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),

                        IconButton(onPressed: (){
                          ref.read(notificationProvider.notifier).deleteOne(item.id);
                        }, icon: Icon(Icons.delete))
                      ],
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

  // ✅ Bottom sheet with full details + delete icon
  void _showNotificationSheet(BuildContext context, NotificationItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          // Watch live state so isRead updates instantly in sheet too
          final live = ref.watch(notificationProvider).notifications
              .firstWhere((n) => n.id == item.id, orElse: () => item);

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Title row + delete icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.button.withOpacity(0.1),
                      child: Icon(Icons.notifications,
                          color: AppColors.button, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            live.title,
                            style: text16(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(live.createdAt),
                            style: text12(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // ✅ Delete icon in sheet
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref
                            .read(notificationProvider.notifier)
                            .deleteOne(live.id);
                      },
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // ── Body
                Text(
                  live.body,
                  style: text14(
                      color: Colors.black87, fontWeight: FontWeight.w400),
                ),

                const SizedBox(height: 24),

                // ── Status chip + mark read button
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: live.isRead
                            ? Colors.green.withAlpha(20)
                            : Colors.orange.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        live.isRead ? '✓ Read' : '● Unread',
                        style: text12(
                          color: live.isRead ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (!live.isRead)
                      TextButton.icon(
                        onPressed: () {
                          ref
                              .read(notificationProvider.notifier)
                              .markAsRead(live.id);
                        },
                        icon: const Icon(Icons.done_all, size: 16),
                        label: const Text('Mark as read'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.button,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No notifications yet', style: text15(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text('Failed to load', style: text14()),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(notificationProvider.notifier).fetch(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear All Notifications'),
        content: const Text(
            'Are you sure you want to delete all notifications?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              ref.read(notificationProvider.notifier).clearAll();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}