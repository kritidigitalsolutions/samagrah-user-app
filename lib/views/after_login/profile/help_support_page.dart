// views/after_login/profile/help_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/complaint_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.amber.shade700;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase().trim()) {
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Closed';
      case 'in_progress':
      case 'in progress':
        return 'In Progress';
      default:
        return 'Under Review';
    }
  }

  String _shortOrderId(String orderId) {
    if (orderId.isEmpty) return 'Not available';
    return orderId.length > 8 ? orderId.substring(orderId.length - 8) : orderId;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaintsAsync = ref.watch(complaintListProvider);
    final supportAsync = ref.watch(supportSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "Help & Support"),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(complaintListProvider);
          ref.invalidate(supportSettingsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Contact Support Card ───────────────────────────────────
            supportAsync.when(
              data: (support) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Support',
                      style: text16(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _ContactTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: "WhatsApp",
                            color: Colors.green,
                            onTap: () {
                              final url =
                                  "https://wa.me/${support.whatsappNo.replaceAll(RegExp(r'[^0-9]'), '')}";
                              launchUrl(
                                Uri.parse(url),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ContactTile(
                            icon: Icons.phone_outlined,
                            label: "Call",
                            color: Colors.blue,
                            onTap: () =>
                                launchUrl(Uri.parse("tel:${support.callNo}")),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () =>
                          launchUrl(Uri.parse("mailto:${support.email}")),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: AppColors.grey700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              support.email,
                              style: text13(
                                color: AppColors.grey800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Failed to load support info',
                style: text13(color: Colors.red),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Your Reported Issues',
              style: text16(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Track issues reported from your orders and see updates from our support team. Pull down to refresh the latest status.',
              style: text12(color: AppColors.grey600),
            ),
            const SizedBox(height: 12),

            complaintsAsync.when(
              data: (complaints) {
                if (complaints.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.task_alt_rounded,
                          size: 36,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No issues reported yet',
                          style: text14(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Issues reported from your orders will appear here with their current status.',
                          textAlign: TextAlign.center,
                          style: text12(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: complaints.map((c) {
                    final color = _statusColor(c.status);
                    final statusLabel = _statusLabel(c.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  c.issue,
                                  style: text14(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  statusLabel,
                                  style: text11(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 14,
                                color: AppColors.grey600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Order #${_shortOrderId(c.orderId)}',
                                  style: text12(color: AppColors.grey600),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: AppColors.grey600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reported ${_formatDate(c.createdAt)}',
                                style: text11(color: AppColors.grey600),
                              ),
                            ],
                          ),
                          if (c.details.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'Your message',
                              style: text11(
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            c.details.isEmpty
                                ? 'No additional details'
                                : c.details,
                            style: text13(color: AppColors.grey700),
                          ),
                          if (c.adminResponse.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Support response',
                                    style: text11(
                                      color: Colors.blue.shade900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.adminResponse,
                                    style: text12(color: Colors.blue.shade900),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 8),
                            Text(
                              statusLabel == 'Under Review'
                                  ? 'Our support team is reviewing your issue.'
                                  : 'No support response added yet.',
                              style: text11(color: AppColors.grey600),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Text(
                'Failed to load complaints',
                style: text13(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
