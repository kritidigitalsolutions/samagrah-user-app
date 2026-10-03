import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class CustomizePoojaKitScreen extends ConsumerStatefulWidget {
  const CustomizePoojaKitScreen({super.key});

  @override
  ConsumerState<CustomizePoojaKitScreen> createState() =>
      _CustomizePoojaKitScreenState();
}

class _CustomizePoojaKitScreenState
    extends ConsumerState<CustomizePoojaKitScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultKitsAsync = ref.watch(userDraftKits);

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.headerCard,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 1),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customize\nYour Puja Kit',
                          style: text18(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/icon/plate.png',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, exception, stackTrace) {
                      return Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(color: AppColors.grey500),
                        child: const Center(child: Icon(Icons.image)),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// ── Search Bar ──
            _buildSearchBar(),

            /// ── Kit List ──
            Expanded(
              child: defaultKitsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Failed to load kits $e")),
                data: (kitState) {
                  final allKits = kitState.defaultKit?.data ?? [];

                  final filtered = _searchQuery.isEmpty
                      ? allKits
                      : allKits
                            .where(
                              (kit) => (kit.name ?? '').toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(userDraftKits);
                      await Future.delayed(const Duration(milliseconds: 300));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final kit = filtered[index];
                        return _buildKitCard(kit);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: text14(color: AppColors.grey800),
          decoration: InputDecoration(
            hintText: 'Search Puja kit...',
            hintStyle: text14(color: AppColors.grey600),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.grey600,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: Icon(Icons.close, color: AppColors.grey600, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKitCard(DefaultKitData kit) {
    // ✅ Use actual model flags instead of index-based guessing
    final bool isPopular = kit.isMostPopularKit == true;
    final bool isMostUsed = kit.isMostUserUse == true;
    final bool isPanditApproved = kit.isPanditApproved == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── Image + Badges ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: SizedBox(
                  height: 160,
                  width: double.infinity,
                  child: CustomCachedImage(
                    imageUrl: kit.image ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // ✅ Most Popular badge from isMostPopularKit
              if (isPopular)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildBadge(
                    label: 'Most Popular',
                    color: Colors.orange.shade600,
                    icon: Icons.local_fire_department_rounded,
                  ),
                ),

              // ✅ Pandit Approved badge from isPanditApproved
              if (isPanditApproved)
                Positioned(
                  top: 12,
                  right: 12,
                  child: _buildBadge(
                    label: 'Pandit Approved',
                    color: Colors.green.shade600,
                    icon: Icons.verified_rounded,
                  ),
                ),

              // ✅ Kit type badge (e.g. "Premium", "Basic") from kitType
              if (kit.kitType != null && kit.kitType!.isNotEmpty)
                Positioned(
                  bottom: 10,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      kit.kitType == "default"
                          ? "Customize"
                          : capitalizeWords(kit.kitType ?? ''),
                      style: text11(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          /// ── Content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name + Category row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        kit.name ?? '',
                        style: text16(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // ✅ Category from new model
                    if (kit.category != null && kit.category!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.button.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kit.category!,
                          style: text10(
                            color: AppColors.button,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                /// Description
                if (kit.description != null && kit.description!.isNotEmpty)
                  Text(
                    kit.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text13(color: AppColors.grey600),
                  ),

                const SizedBox(height: 10),

                /// ── Price Row ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Kit price (selling price)
                    Text(
                      '₹${kit.kitPrice ?? kit.totalPrice ?? 0}',
                      style: text20(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),

                    // ✅ MRP strikethrough + savings from new model
                    if (kit.savings != null && kit.savings! > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${kit.totalPrice ?? 0}',
                        style: text13(
                          color: AppColors.grey500,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Save ₹${kit.savings}',
                          style: text10(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 8),

                /// ✅ Trust indicators row using new boolean fields
                if (isMostUsed || isPanditApproved)
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    children: [
                      if (isMostUsed)
                        _buildTrustChip(
                          icon: Icons.people_alt_rounded,
                          label: '98% users choose this',
                          color: Colors.green.shade700,
                        ),
                      if (isPanditApproved)
                        _buildTrustChip(
                          icon: Icons.how_to_reg_rounded,
                          label: 'Pandit recommended',
                          color: Colors.blue.shade700,
                        ),
                    ],
                  ),

                const SizedBox(height: 12),

                /// View Kit Button
                AppButton(
                  title: "View Kit",
                  radius: 10,
                  onTap: () {
                    final notifier = ref.read(customizeKitProvider.notifier);
                    notifier.initializeFromDefault(kit);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.festivalKitDetails,
                      arguments: kit,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable badge widget for image overlays
  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: text11(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  /// Reusable trust indicator chip
  Widget _buildTrustChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 4),
        Text(label, style: text11(color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 56, color: AppColors.grey600),
          const SizedBox(height: 14),
          Text(
            'No kits found for "$_searchQuery"',
            style: text14(color: AppColors.grey600),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            child: Text('Clear Search', style: text14(color: AppColors.button)),
          ),
        ],
      ),
    );
  }
}
