import 'package:flutter/material.dart';
import 'package:samagrah/model/response/complaint_res_model.dart';
import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/views/after_login/profile/help_support_page.dart';

Complaint? complaintForOrder(List<Complaint> complaints, Order order) {
  final orderIds = {order.id, order.razorpayOrderId}
      .whereType<String>()
      .map((id) => id.trim())
      .where((id) => id.isNotEmpty)
      .toSet();

  for (final complaint in complaints) {
    if (orderIds.contains(complaint.orderId.trim())) return complaint;
  }
  return null;
}

String complaintStatusLabel(String status) {
  switch (status.toLowerCase().trim().replaceAll('-', '_')) {
    case 'resolved':
      return 'Resolved';
    case 'rejected':
    case 'closed':
      return 'Closed';
    case 'in_progress':
    case 'processing':
      return 'In progress';
    default:
      return 'Open';
  }
}

Color complaintStatusColor(String status) {
  switch (complaintStatusLabel(status)) {
    case 'Resolved':
      return AppColors.success;
    case 'Closed':
      return AppColors.grey600;
    case 'In progress':
      return AppColors.info;
    default:
      return AppColors.warningDark;
  }
}

class OrderComplaintStatusCard extends StatelessWidget {
  final Complaint complaint;

  const OrderComplaintStatusCard({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final label = complaintStatusLabel(complaint.status);
    final color = complaintStatusColor(complaint.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.support_agent_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reported issue · $label',
                  style: text13(color: color, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  complaint.issue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text11(color: AppColors.grey600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ComplaintDetailPage(complaint: complaint),
              ),
            ),
            child: const Text('View issue'),
          ),
        ],
      ),
    );
  }
}
