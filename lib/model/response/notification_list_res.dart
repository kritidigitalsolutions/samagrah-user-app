// lib/model/response/notification_model.dart

class NotificationListResponse {
  final bool success;
  final int count;
  final int total;
  final int page;
  final int limit;
  final List<NotificationItem> data;

  NotificationListResponse({
    required this.success,
    required this.count,
    required this.total,
    required this.page,
    required this.limit,
    required this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      success: json['success'] ?? false,
      count: _toInt(json['count']),
      total: _toInt(json['total']),
      page: _toInt(json['page'], fallback: 1),
      limit: _toInt(json['limit'], fallback: 20),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e))
          .toList() ??
          [],
    );
  }

  static int _toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final List<String> readBy;
  final List<String> deletedBy;
  final String status;
  final String createdAt;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.readBy,
    required this.deletedBy,
    required this.status,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      readBy: List<String>.from(json['readBy'] ?? []),
      deletedBy: List<String>.from(json['deletedBy'] ?? []),
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isRead: json['isRead'] ?? false,
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      readBy: readBy,
      deletedBy: deletedBy,
      status: status,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
