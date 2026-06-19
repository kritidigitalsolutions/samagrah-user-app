// model/complaint_model.dart
class Complaint {
  final String id;
  final String orderId;
  final String issue;
  final String details;
  final String status;
  final String adminResponse;
  final DateTime createdAt;
  final num? orderTotalAmount;
  final String? orderStatus;

  Complaint({
    required this.id,
    required this.orderId,
    required this.issue,
    required this.details,
    required this.status,
    required this.adminResponse,
    required this.createdAt,
    this.orderTotalAmount,
    this.orderStatus,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    final order = json['order'];
    return Complaint(
      id: json['_id'] ?? '',
      orderId: order is Map ? (order['_id'] ?? '') : (order ?? ''),
      issue: json['issue'] ?? '',
      details: json['details'] ?? '',
      status: json['status'] ?? 'Pending',
      adminResponse: json['adminResponse'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      orderTotalAmount: order is Map ? order['totalAmount'] : null,
      orderStatus: order is Map ? order['orderStatus'] : null,
    );
  }
}

class SupportSettings {
  final String whatsappNo;
  final String callNo;
  final String email;

  SupportSettings({
    required this.whatsappNo,
    required this.callNo,
    required this.email,
  });

  factory SupportSettings.fromJson(Map<String, dynamic> json) {
    return SupportSettings(
      whatsappNo: json['whatsappNo'] ?? '',
      callNo: json['callNo'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
