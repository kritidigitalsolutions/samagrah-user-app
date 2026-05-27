import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/availability_res_model.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/checkout_providers/address.provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';

import '../../../view_model/after_login_provider/pandit_provider/pandit_details_provider.dart';

class PanditDetailsPage extends ConsumerWidget {
  const PanditDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;
    final isExpanded = ref.watch(availabilityExpandedProvider);
    final availabilityAsync = isExpanded
        ? ref.watch(availabilityProvider(pandit.id ?? ''))
        : null;

    // Status bar transparent so image shows through
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
                size: 16,
              ),
            ),
          ),
        ),
        bottomNavigationBar: _BottomBar(
          pandit: pandit,
          isExpanded: isExpanded,
          onToggle: () {
            ref.read(availabilityExpandedProvider.notifier).state = !isExpanded;
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero image — full bleed, no appbar overlap issue ─────────
              _HeroSection(pandit: pandit),

              // ── All content below image ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service type chips
                    _ServiceChips(pandit: pandit),
                    const SizedBox(height: 16),

                    // About
                    if (pandit.bio != null && pandit.bio!.isNotEmpty)
                      _Card(
                        title: 'About',
                        icon: Icons.person_outline_rounded,
                        child: Text(
                          pandit.bio!,
                          style: text13(
                            color: AppColors.textPrimary,
                          ).copyWith(height: 1.6),
                        ),
                      ),

                    // Temple
                    if (pandit.templeAssociated != null &&
                        pandit.templeAssociated!.isNotEmpty)
                      _Card(
                        title: 'Temple Associated',
                        icon: Icons.temple_hindu_outlined,
                        child: Text(
                          pandit.templeAssociated!,
                          style: text13(
                            color: AppColors.textPrimary,
                          ).copyWith(height: 1.6),
                        ),
                      ),

                    // Address
                    if (pandit.address != null)
                      _Card(
                        title: 'Address',
                        icon: Icons.location_on_outlined,
                        child: Text(
                          _formatAddress(pandit.address!),
                          style: text13(color: AppColors.textPrimary),
                        ),
                      ),

                    // Pooja Services
                    if (pandit.poojaOfferings.isNotEmpty) ...[
                      const _Label('Pooja Services'),
                      const SizedBox(height: 10),
                      ...pandit.poojaOfferings.map(
                        (p) => _PoojaCard(
                          pooja: p,
                          panditId: pandit.id ?? '',
                          ref: ref,
                        ),
                      ),
                    ],

                    // Availability panel — expands when bottom button tapped
                    if (isExpanded) ...[
                      const SizedBox(height: 4),
                      _AvailabilityPanel(async: availabilityAsync),
                    ],

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAddress(PanditAddress a) => [
    a.line1,
    a.line2,
    a.city,
    a.state,
    a.pinCode,
  ].where((e) => e != null && e.isNotEmpty).join(', ');
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.pandit});
  final PanditData pandit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Image
        CustomCachedImage(
          imageUrl: pandit.profileImage ?? '',
          height: 300,
          width: double.infinity,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.zero,
        ),
        // Bottom gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppColors.black.withOpacity(0.7)],
                stops: const [0.45, 1.0],
              ),
            ),
          ),
        ),
        // Name + meta
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pandit.fullName ?? 'Pandit',
                style: text20(
                  color: AppColors.white,

                  fontWeight: FontWeight.w700,
                ).copyWith(letterSpacing: 0.1),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFB800),
                    size: 15,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${pandit.ratingAverage ?? 0}',
                    style: text13(
                      color: AppColors.white,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _sep(),
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.grey100,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${pandit.yearsOfExperience ?? 0}+ yrs',
                    style: text13(color: AppColors.grey100),
                  ),
                  if (pandit.languagesSpoken.isNotEmpty) ...[
                    _sep(),
                    const Icon(
                      Icons.translate_rounded,
                      color: AppColors.grey100,
                      size: 13,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        pandit.languagesSpoken.join(', '),
                        overflow: TextOverflow.ellipsis,
                        style: text13(color: AppColors.grey100),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sep() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text('·', style: TextStyle(color: Colors.white38, fontSize: 14)),
  );
}

// ─── Service Chips ────────────────────────────────────────────────────────────
class _ServiceChips extends StatelessWidget {
  const _ServiceChips({required this.pandit});
  final PanditData pandit;

  @override
  Widget build(BuildContext context) {
    final items = [
      if (pandit.serviceTypes?.homeVisit == true)
        _ChipItem(Icons.cottage_outlined, 'Home Visit'),
      if (pandit.serviceTypes?.onlinePooja == true)
        _ChipItem(Icons.videocam_outlined, 'Online Puja'),
      if (pandit.serviceTypes?.atTemple == true)
        _ChipItem(Icons.temple_hindu_outlined, 'Temple'),
      if (pandit.serviceTypes?.travelForSpecialPoojas == true)
        _ChipItem(Icons.luggage_outlined, 'Travel'),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(c.icon, size: 14, color: AppColors.button),
                    const SizedBox(width: 5),
                    Text(
                      c.label,
                      style: text12(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ChipItem {
  _ChipItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

// ─── Generic Card ─────────────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.icon, required this.child});
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.button),
              const SizedBox(width: 7),
              Text(
                title,
                style: text13(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: text14(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
  );
}

// ─── Pooja Card ───────────────────────────────────────────────────────────────
class _PoojaCard extends StatelessWidget {
  const _PoojaCard({
    required this.pooja,
    required this.panditId,
    required this.ref,
  });
  final PoojaOffering pooja;
  final String panditId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final notes = pooja.customSamagriNotes
        .map((n) => n.trim())
        .where((n) => n.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name row
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_outlined,
                size: 15,
                color: Color(0xFFB8860B),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  pooja.name ?? 'Pooja',
                  style: text14(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          if (pooja.description != null && pooja.description!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              pooja.description!,
              style: text13(
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
            ),
          ],

          const SizedBox(height: 10),

          // Tags
          Wrap(
            spacing: 7,
            runSpacing: 6,
            children: [
              if (pooja.durationHours != null)
                _Tag(Icons.schedule_outlined, '${pooja.durationHours} hrs'),
              if (pooja.standardSamagri == true)
                _Tag(Icons.check_circle_outline_rounded, 'Samagri included'),
              if (pooja.customSamagri == true)
                _Tag(Icons.shopping_bag_outlined, 'Custom samagri'),
              if (pooja.travelForSpecialPooja == true)
                _Tag(Icons.luggage_outlined, 'Travel available'),
            ],
          ),

          // Samagri notes
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE8CC6A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13,
                        color: Color(0xFF9E7500),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Note',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E7500),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ...notes.map(
                    (n) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        n,
                        style: text12(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Samagri kit link
          if (pooja.customSamagriItems.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                print(panditId);
                ref.read(panditIdProvider.notifier).state = panditId;
                Navigator.pushNamed(
                  context,
                  AppRoutes.panditRecKit,
                  arguments: pooja.customSamagriItems,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16,
                      color: AppColors.button,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'View recommended samagri list',
                        style: text13(color: AppColors.textPrimary),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: Color(0xFFAAAAAA),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF555555)),
          const SizedBox(width: 5),
          Text(
            label,
            style: text12(
              color: Color(0xFF444444),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Availability Panel ───────────────────────────────────────────────────────
class _AvailabilityPanel extends StatelessWidget {
  const _AvailabilityPanel({required this.async});
  final AsyncValue<AvailabilityResModel>? async;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 15,
                  color: AppColors.button,
                ),
                SizedBox(width: 7),
                Text(
                  'Available Slots',
                  style: text13(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (async == null)
            const SizedBox.shrink()
          else
            async!.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.button,
                  ),
                ),
              ),
              error: (_, _) => Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Could not load slots',
                    style: text13(color: AppColors.textPrimary),
                  ),
                ),
              ),
              data: (res) {
                final slots = res.data?.availability ?? [];
                if (slots.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'No slots available',
                        style: text13(color: AppColors.textPrimary),
                      ),
                    ),
                  );
                }

                final availCount = slots
                    .where((s) => s.status?.toLowerCase() == 'available')
                    .length;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Dot(color: Colors.green.shade600),
                          const SizedBox(width: 5),
                          Text(
                            '$availCount available',
                            style: text12(color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 14),
                          _Dot(color: Colors.grey.shade400),
                          const SizedBox(width: 5),
                          Text(
                            '${slots.length - availCount} booked',
                            style: text12(color: AppColors.textPrimary),
                          ),
                        ],
                      ),

                      GridView.builder(
                        padding: EdgeInsets.only(top: 15),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: slots.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              childAspectRatio: 1.35,
                            ),
                        itemBuilder: (_, i) => _SlotCell(
                          date: slots[i].date ?? '',
                          isAvailable:
                              slots[i].status?.toLowerCase() == 'available',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 8,
    height: 8,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({required this.date, required this.isAvailable});
  final String date;
  final bool isAvailable;

  String _fmt(String raw) {
    try {
      final p = raw.split('-');
      if (p.length < 3) return raw;
      const m = [
        '',
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
      return '${int.parse(p[2])}\n${m[int.tryParse(p[1]) ?? 0]}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFF0F7F1) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable
              ? const Color(0xFFA8CCA9)
              : const Color(0xFFDDDDDD),
        ),
      ),
      child: Center(
        child: Text(
          _fmt(date),
          textAlign: TextAlign.center,
          style: text12(
            fontWeight: FontWeight.w600,

            color: isAvailable
                ? const Color(0xFF2E7D32)
                : const Color(0xFFBBBBBB),
          ).copyWith(height: 1.4),
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.pandit,
    required this.isExpanded,
    required this.onToggle,
  });
  final PanditData pandit;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Availability toggle
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onToggle,
              icon: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.calendar_today_outlined,
                size: 16,
                color: AppColors.button,
              ),
              label: Text(
                isExpanded ? 'Hide Slots' : 'Availability',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.button,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                side: BorderSide(color: AppColors.button),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Book Now
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(selectedPanditProvider.notifier).state = pandit;
                Navigator.pushNamed(
                  context,
                  AppRoutes.serviceSelection,
                  arguments: pandit,
                );
              },
              icon: const Icon(
                Icons.check_circle_outline_rounded,
                size: 17,
                color: Colors.white,
              ),
              label: const Text(
                'Book Now',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
