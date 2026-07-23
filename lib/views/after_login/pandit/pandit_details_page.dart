import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class PanditDetailsPage extends ConsumerWidget {
  const PanditDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ModalRoute.of(context)!.settings.arguments as PanditData;

    final selectedService = ref.read(selectedServiceProvider);

    print(selectedService);

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
        bottomNavigationBar: _BottomBar(pandit: pandit),
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
                      const _Label('Puja Services'),
                      const SizedBox(height: 10),
                      ...pandit.poojaOfferings.map(
                        (p) => _PoojaCard(
                          pooja: p,
                          panditId: pandit.id ?? '',
                          ref: ref,
                        ),
                      ),
                    ],

                    if (pandit.serviceTypes != null)
                      _ServiceAreaCard(serviceTypes: pandit.serviceTypes!),

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
      if (pandit.serviceTypes?.travelForSpecialPoojas == true ||
          pandit.poojaOfferings.any(
            (offering) => offering.travelForSpecialPooja == true,
          ))
        _ChipItem(Icons.luggage_outlined, 'Travel for Puja'),
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
    // final notes = pooja.customSamagriNotes
    //     .map((n) => n.trim())
    //     .where((n) => n.isNotEmpty)
    //     .toList();

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
                  pooja.name ?? 'Puja',
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

// ─── Bottom Bar ───────────────────────────────────────────────────────────────
class _BottomBar extends ConsumerWidget {
  const _BottomBar({required this.pandit});
  final PanditData pandit;

  // ── Checks whether booking this pandit needs outstation approval ──
  Future<bool> _isOtherCityOrPincode(WidgetRef ref) async {
    final locationState = ref.read(panditLocationProvider);

    // Agar user ne koi custom location search nahi ki (GPS/default use ho
    // raha hai), to local booking treat karo — outstation check nahi lagega.
    if (!locationState.isActive) return false;

    final searchedCity = locationState.city.trim().toLowerCase();
    final searchedPincode = locationState.pincode.trim();
    final userCity = (await LocationStorage.getCity() ?? '')
        .trim()
        .toLowerCase();
    final userPincode = (await LocationStorage.getPincode() ?? '').trim();

    final isDifferentCity =
        userCity.isEmpty || searchedCity.isEmpty || userCity != searchedCity;
    final isDifferentPincode =
        searchedPincode.isNotEmpty &&
        (userPincode.isEmpty || userPincode != searchedPincode);

    return isDifferentCity || isDifferentPincode;
  }

  void _showOutstationBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Booking Not Available"),
        content: Text(
          "${pandit.fullName ?? 'This pandit'} currently does not accept outstation bookings. To book a pandit in a different city or pincode, please select another pandit.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }

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
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                // ── NEW: outstation booking gate ──
                final isOtherLocation = await _isOtherCityOrPincode(ref);
                if (!context.mounted) return;
                final anywhereInIndia =
                    pandit
                        .serviceTypes
                        ?.outstationAvailability
                        ?.anywhereInIndia ==
                    true;

                if (isOtherLocation && !anywhereInIndia) {
                  _showOutstationBlockedDialog(context);
                  return;
                }

                ref.read(selectedPanditProvider.notifier).state = pandit;

                final selectedService = ref.read(selectedServiceProvider);

                if (selectedService == null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.serviceSelection,
                    arguments: pandit,
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.timeSelection,
                    arguments: pandit,
                  );
                }
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

// ─── Service Area Card ────────────────────────────────────────────────────
class _ServiceAreaCard extends StatelessWidget {
  const _ServiceAreaCard({required this.serviceTypes});
  final ServiceTypes serviceTypes;

  String _distanceLabel() {
    final sd = serviceTypes.serviceDistance;
    if (sd == null) return 'Not specified';
    if (sd.customKm != null) return 'Within ${sd.customKm} km';
    switch (sd.selected) {
      case 'within5':
        return 'Within 5 km';
      case 'within10':
        return 'Within 10 km';
      case 'within20':
        return 'Within 20 km';
      default:
        return sd.selected ?? 'Not specified';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = serviceTypes.detectedLocation;
    final outstation = serviceTypes.outstationAvailability;

    final locationLabel = [
      loc?.city,
      loc?.state,
    ].where((e) => e != null && e.isNotEmpty).join(', ');

    final outstationTags = <String>[
      if (outstation?.withinDistrict == true) 'Within District',
      if (outstation?.withinState == true) 'Within State',
      if (outstation?.anywhereInIndia == true) 'Anywhere in India',
    ];

    return _Card(
      title: 'Service Area',
      icon: Icons.map_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (locationLabel.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.my_location_rounded,
                  size: 14,
                  color: AppColors.grey600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Based in $locationLabel',
                  style: text12(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.social_distance_rounded,
                size: 14,
                color: AppColors.grey600,
              ),
              const SizedBox(width: 6),
              Text(
                'Local service radius: ${_distanceLabel()}',
                style: text12(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (outstationTags.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: outstationTags
                  .map((t) => _Tag(Icons.travel_explore_rounded, t))
                  .toList(),
            )
          else
            Text(
              'Does not travel outside local service area',
              style: text12(color: AppColors.grey500),
            ),
        ],
      ),
    );
  }
}
