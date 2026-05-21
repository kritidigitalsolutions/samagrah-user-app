// views/screens/coupon_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:samagrah/model/response/coupon_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/res/app_image.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/coupon_provider.dart';
import 'package:samagrah/views/custom_widget/empty_data_widget.dart';

class CouponPage extends ConsumerWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(couponProvider);

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final offers = state.coupon;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Coupons & Offers",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(
              Icons.local_offer_rounded,
              color: AppColors.button,
              size: 26,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: state.error != null
            ? _ErrorView(
                message: state.error!,
                onRetry: () => ref.read(couponProvider.notifier).fetchCoupons(),
              )
            : offers.isEmpty
            ? EmptyDataWidget(
                title: "No Coupons Available",
                subtitle: "Check back soon for exciting offers!",
                animationPath: AppImages.empty,
                height: 250,
              )
            : RefreshIndicator(
                color: AppColors.button,
                onRefresh: () =>
                    ref.read(couponProvider.notifier).fetchCoupons(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(15, 12, 15, 24),
                  children: [
                    _OffersBanner(count: offers.length),
                    const SizedBox(height: 16),
                    ...offers.map(
                      (coupon) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CouponCard(coupon: coupon),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner
// ─────────────────────────────────────────────────────────────────────────────

class _OffersBanner extends StatelessWidget {
  final int count;
  const _OffersBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.button, AppColors.button.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count offer${count == 1 ? '' : 's'} available for you!',
                  style: text15(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Apply at checkout to save more.',
                  style: text12(color: AppColors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Coupon Card  —  uses new CouponData fields
// ─────────────────────────────────────────────────────────────────────────────

class _CouponCard extends StatelessWidget {
  final CouponData coupon;
  const _CouponCard({required this.coupon});

  /// Days remaining until expiry (null = no expiry set)
  int? get _daysRemaining {
    if (coupon.expiresAt == null) return null;
    final diff = coupon.expiresAt!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Formatted label e.g. "20% OFF" or "₹200 OFF"
  String get _discountLabel {
    final v = (coupon.discountValue ?? 0).toInt();
    return coupon.discountType == 'percent' ? '$v% OFF' : '₹$v OFF';
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysRemaining;
    final isExpiringSoon = daysLeft != null && daysLeft <= 3;
    final expired = daysLeft != null && daysLeft == 0;
    final isActive = coupon.isActive ?? false;

    return Opacity(
      opacity: (expired || !isActive) ? 0.55 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent strip + discount badge ──────────────────────
              _DiscountBadge(
                label: _discountLabel,
                discountType: coupon.discountType ?? '',
                discountValue: coupon.discountValue ?? 0,
              ),

              // ── Dashed divider ──────────────────────────────────────────
              _DashedDivider(),

              // ── Right content ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + status chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              coupon.title ?? '',
                              style: text15(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _StatusChip(
                            expired: expired || !isActive,
                            isExpiringSoon: isExpiringSoon,
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Text(
                        coupon.description ?? '',
                        style: text12(color: AppColors.grey500),
                      ),

                      const SizedBox(height: 10),

                      // Details chips
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          if ((coupon.minOrderAmount ?? 0) > 0)
                            _InfoChip(
                              icon: Icons.shopping_bag_outlined,
                              label:
                                  'Min ₹${coupon.minOrderAmount?.toInt() ?? 0}',
                            ),
                          if ((coupon.maxDiscount ?? 0) > 0)
                            _InfoChip(
                              icon: Icons.savings_outlined,
                              label:
                                  'Max benefit ₹${coupon.maxDiscount?.toInt() ?? 0}',
                            ),
                          if (coupon.expiresAt != null)
                            _InfoChip(
                              icon: Icons.calendar_today_outlined,
                              label:
                                  'Expires ${DateFormat('dd MMM yy').format(coupon.expiresAt!)}',
                              urgent: isExpiringSoon && !expired,
                            ),
                          if ((coupon.usageLimit ?? 0) > 0)
                            _InfoChip(
                              icon: Icons.people_outline,
                              label:
                                  '${coupon.usedCount ?? 0}/${coupon.usageLimit} used',
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Copy code button — uses coupon.code field directly
                      _CopyCodeButton(code: coupon.code ?? ''),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Left discount badge
// ─────────────────────────────────────────────────────────────────────────────

class _DiscountBadge extends StatelessWidget {
  final String label;
  final String discountType;
  final num discountValue;

  const _DiscountBadge({
    required this.label,
    required this.discountType,
    required this.discountValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            discountType == 'percent'
                ? '${discountValue.toInt()}%'
                : '₹${discountValue.toInt()}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            'OFF',
            style: text11(
              color: AppColors.white.withOpacity(0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Icon(Icons.local_offer, color: Colors.white54, size: 18),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dashed divider
// ─────────────────────────────────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 14, child: CustomPaint(painter: _DashPainter()));
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashHeight = 5.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 1.5;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chip
// ─────────────────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final bool expired;
  final bool isExpiringSoon;

  const _StatusChip({required this.expired, required this.isExpiringSoon});

  @override
  Widget build(BuildContext context) {
    if (expired) {
      return _chip('Expired', Colors.red.shade400, Colors.red.shade50);
    }
    if (isExpiringSoon) {
      return _chip(
        'Ending Soon',
        Colors.orange.shade600,
        Colors.orange.shade50,
      );
    }
    return _chip('Active', Colors.green.shade600, Colors.green.shade50);
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: fg),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Info chip
// ─────────────────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool urgent;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = urgent ? Colors.orange.shade700 : AppColors.grey500;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Copy code button  —  uses coupon.code directly
// ─────────────────────────────────────────────────────────────────────────────

class _CopyCodeButton extends StatefulWidget {
  final String code;
  const _CopyCodeButton({required this.code});

  @override
  State<_CopyCodeButton> createState() => _CopyCodeButtonState();
}

class _CopyCodeButtonState extends State<_CopyCodeButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.code.isEmpty ? null : _copy,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.button.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.button.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.code.isEmpty ? '—' : widget.code,
              style: text13(
                color: AppColors.button,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _copied
                  ? const Icon(
                      Icons.check_circle_outline,
                      key: ValueKey('check'),
                      size: 16,
                      color: Colors.green,
                    )
                  : Icon(
                      Icons.copy_outlined,
                      key: const ValueKey('copy'),
                      size: 16,
                      color: AppColors.button,
                    ),
            ),
            const SizedBox(width: 4),
            Text(
              _copied ? 'Copied!' : 'Tap to copy',
              style: text11(color: _copied ? Colors.green : AppColors.button),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.button, size: 48),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: text15(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(message, style: text12(color: AppColors.grey500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
