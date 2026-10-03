
import 'package:flutter_riverpod/legacy.dart';

import '../../../model/response/notification_list_res.dart';
import '../../../repo/notification_repo.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepo _repo;
  static const int _pageLimit = 20;

  NotificationNotifier(this._repo) : super(const NotificationState()) {
    fetch();
  }

  String get _filterStr {
    switch (state.filter) {
      case NotificationFilter.read:
        return 'read';
      case NotificationFilter.unread:
        return 'unread';
      default:
        return 'all';
    }
  }

  // Initial / refresh fetch
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, error: null, page: 1);
    try {
      final res = await _repo.getNotifications(
        status: _filterStr,
        page: 1,
        limit: _pageLimit,
      );
      state = state.copyWith(
        isLoading: false,
        notifications: res.data,
        total: res.total,
        page: 1,
        hasMore: _hasMore(res, loadedCount: res.data.length),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Pagination
  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final res = await _repo.getNotifications(
        status: _filterStr,
        page: nextPage,
        limit: _pageLimit,
      );
      final merged = [...state.notifications, ...res.data];
      state = state.copyWith(
        isLoadingMore: false,
        notifications: merged,
        page: nextPage,
        total: res.total,
        hasMore: _hasMore(res, loadedCount: merged.length),
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  bool _hasMore(NotificationListResponse res, {required int loadedCount}) {
    if (res.total > 0) return loadedCount < res.total;
    final limit = res.limit > 0 ? res.limit : _pageLimit;
    return res.data.length >= limit;
  }

  // Filter change
  Future<void> changeFilter(NotificationFilter filter) async {
    state = state.copyWith(filter: filter);
    await fetch();
  }

  // Mark single as read (optimistic update)
  Future<void> markAsRead(String id) async {
    // Optimistic UI update
    final updated = state.notifications.map((n) {
      return n.id == id ? n.copyWith(isRead: true) : n;
    }).toList();
    state = state.copyWith(notifications: updated);

    try {
      await _repo.markAsRead(id);
    } catch (e) {
      // Revert on failure
      final reverted = state.notifications.map((n) {
        return n.id == id ? n.copyWith(isRead: false) : n;
      }).toList();
      state = state.copyWith(notifications: reverted, error: e.toString());
    }
  }

  // Delete single (optimistic)
  Future<void> deleteOne(String id) async {
    final prev = state.notifications;
    state = state.copyWith(
      notifications: prev.where((n) => n.id != id).toList(),
      total: state.total - 1,
    );
    try {
      await _repo.deleteNotification(id);
    } catch (e) {
      state = state.copyWith(notifications: prev, error: e.toString());
    }
  }

  // Clear all
  Future<void> clearAll() async {
    final prev = state.notifications;
    state = state.copyWith(notifications: [], total: 0);
    try {
      await _repo.clearAllNotifications();
    } catch (e) {
      state = state.copyWith(notifications: prev, error: e.toString());
    }
  }
}

final notificationProvider =
StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(NotificationRepo());
});



/// state


enum NotificationFilter { all, read, unread }

class NotificationState {
  final List<NotificationItem> notifications;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final NotificationFilter filter;
  final int page;
  final int total;
  final bool hasMore;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.filter = NotificationFilter.all,
    this.page = 1,
    this.total = 0,
    this.hasMore = false,
  });

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    NotificationFilter? filter,
    int? page,
    int? total,
    bool? hasMore,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      filter: filter ?? this.filter,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
