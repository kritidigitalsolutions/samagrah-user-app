import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';
import 'package:samagrah/model/response/pandit_res/ritual_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/checkout_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/service_selection_screen.dart';
import 'package:samagrah/views/custom_loader.dart/pandit_card_loader.dart';

// ─────────────────────────────────────────────
// Filter State Model
// ─────────────────────────────────────────────

class PanditFilterState {
  final String? serviceType; // 'home' | 'online' | 'temple' | null
  final String? language;
  final int? minExperience;
  final double? minRating;

  const PanditFilterState({
    this.serviceType,
    this.language,
    this.minExperience,
    this.minRating,
  });

  bool get hasAnyFilter =>
      serviceType != null ||
      language != null ||
      minExperience != null ||
      minRating != null;

  PanditFilterState copyWith({
    Object? serviceType = _sentinel,
    Object? language = _sentinel,
    Object? minExperience = _sentinel,
    Object? minRating = _sentinel,
  }) {
    return PanditFilterState(
      serviceType: serviceType == _sentinel
          ? this.serviceType
          : serviceType as String?,
      language: language == _sentinel ? this.language : language as String?,
      minExperience: minExperience == _sentinel
          ? this.minExperience
          : minExperience as int?,
      minRating: minRating == _sentinel ? this.minRating : minRating as double?,
    );
  }
}

const _sentinel = Object();

// Quick filter config — shown as horizontal chips below search bar
class _QuickFilter {
  final String label;
  final IconData icon;
  final String type;
  final String dec;
  // matches serviceType values

  const _QuickFilter(this.label, this.icon, this.type, this.dec);
}

const _quickFilters = [
  _QuickFilter(
    'Home Visit',
    Icons.home_outlined,
    'home',
    'Pooja will be performed at your home.',
  ),
  _QuickFilter(
    'Online',
    Icons.video_call_outlined,
    'online',
    'Pooja will be performed online.',
  ),
  _QuickFilter(
    'Temple',
    Icons.temple_hindu_outlined,
    'temple',
    'Pooja will be performed at temple.',
  ),
];

// ─────────────────────────────────────────────
// BookPanditPage
// ─────────────────────────────────────────────

class BookPanditPage extends ConsumerStatefulWidget {
  const BookPanditPage({super.key});

  @override
  ConsumerState<BookPanditPage> createState() => _BookPanditPageState();
}

class _BookPanditPageState extends ConsumerState<BookPanditPage> {
  PanditFilterState _filters = const PanditFilterState();
  final TextEditingController _searchController = TextEditingController();

  Future<void> _refreshPandits() {
    return ref.refresh(panditProvider.future);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ritual = ModalRoute.of(context)!.settings.arguments as RitualData;
      _searchController.text = ritual.name ?? '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  List<PanditData> _applyFilters(List<PanditData> source) {
    return source.where((p) {
      if (_filters.serviceType != null) {
        final st = p.serviceTypes;
        bool matches = false;
        if (_filters.serviceType == 'home') matches = st?.homeVisit == true;
        if (_filters.serviceType == 'online') matches = st?.onlinePooja == true;
        if (_filters.serviceType == 'temple') matches = st?.atTemple == true;
        if (!matches) return false;
      }
      if (_filters.language != null) {
        final hasLang = p.languagesSpoken.any(
          (l) => l.toLowerCase().contains(_filters.language!.toLowerCase()),
        );
        if (!hasLang) return false;
      }
      if (_filters.minExperience != null &&
          (p.yearsOfExperience ?? 0) < _filters.minExperience!) {
        return false;
      }
      if (_filters.minRating != null &&
          (p.ratingAverage ?? 0) < _filters.minRating!) {
        return false;
      }
      return true;
    }).toList();
  }

  // ── Advanced Filter Bottom Sheet ──
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        PanditFilterState draft = _filters;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.80,
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.grey300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header row
                  Row(
                    children: [
                      Text(
                        'Advanced Filters',
                        style: text18(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (draft.hasAnyFilter)
                        TextButton(
                          onPressed: () =>
                              setSheet(() => draft = const PanditFilterState()),
                          child: Text(
                            'Clear All',
                            style: text13(color: AppColors.error),
                          ),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(sheetCtx),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Service Type ──
                          _sheetSectionLabel('Service Type'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final qf in _quickFilters) ...[
                                Expanded(
                                  child: _serviceTypeCard(
                                    label: qf.label,
                                    icon: qf.icon,
                                    selected: draft.serviceType == qf.type,
                                    onTap: () => setSheet(() {
                                      draft = draft.copyWith(
                                        serviceType:
                                            draft.serviceType == qf.type
                                            ? null
                                            : qf.type,
                                      );
                                    }),
                                  ),
                                ),
                                if (qf != _quickFilters.last)
                                  const SizedBox(width: 8),
                              ],
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Language ──
                          _sheetSectionLabel('Language'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final lang in [
                                'Hindi',
                                'English',
                                'Sanskrit',
                                'Bengali',
                                'Tamil',
                              ])
                                _sheetChip(
                                  label: lang,
                                  selected: draft.language == lang,
                                  onTap: () => setSheet(() {
                                    draft = draft.copyWith(
                                      language: draft.language == lang
                                          ? null
                                          : lang,
                                    );
                                  }),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Minimum Rating ──
                          _sheetSectionLabel('Minimum Rating'),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              for (final r in [3.0, 3.5, 4.0, 4.5]) ...[
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setSheet(() {
                                      draft = draft.copyWith(
                                        minRating: draft.minRating == r
                                            ? null
                                            : r,
                                      );
                                    }),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 160,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: draft.minRating == r
                                            ? AppColors.button
                                            : AppColors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: draft.minRating == r
                                              ? AppColors.button
                                              : AppColors.grey300,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 16,
                                            color: draft.minRating == r
                                                ? AppColors.white
                                                : AppColors.warning,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            '$r+',
                                            style: text12(
                                              color: draft.minRating == r
                                                  ? AppColors.white
                                                  : AppColors.grey700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (r != 4.5) const SizedBox(width: 8),
                              ],
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ── Experience ──
                          Row(
                            children: [
                              _sheetSectionLabel('Min. Experience'),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  draft.minExperience == null ||
                                          draft.minExperience == 0
                                      ? 'Any'
                                      : '${draft.minExperience}+ yrs',
                                  style: text12(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(ctx).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 18,
                              ),
                              activeTrackColor: AppColors.button,
                              inactiveTrackColor: AppColors.button.withOpacity(
                                0.15,
                              ),
                              thumbColor: AppColors.button,
                              overlayColor: AppColors.button.withOpacity(0.12),
                            ),
                            child: Slider(
                              value: (draft.minExperience ?? 0).toDouble(),
                              min: 0,
                              max: 30,
                              divisions: 6,
                              onChanged: (val) => setSheet(() {
                                draft = draft.copyWith(
                                  minExperience: val == 0 ? null : val.toInt(),
                                );
                              }),
                            ),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SafeArea(
                    child: AppButton(
                      title: 'Apply Filters',
                      onTap: () {
                        setState(() => _filters = draft);
                        Navigator.pop(sheetCtx);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(panditProvider, (previous, next) {
      next.whenData((_) {
        if (_searchController.text.isNotEmpty) {
          ref
              .read(panditProvider.notifier)
              .searchPandit(_searchController.text);
        }
      });
    });
    final panditAsync = ref.watch(panditProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Book my Pandit',
        subtitle: 'Schedule a pandit for your ritual needs',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/panditLogo.png',
              width: 70,
              height: 70,
              errorBuilder: (context, exception, stackTrace) {
                return Container(
                  width: 70,
                  height: 70,
                  color: AppColors.grey500,
                  child: const Icon(Icons.image),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════
            // Search + Filter icon bar
            // ══════════════════════════════════
            Container(
              color: AppColors.headerCard,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (value) => ref
                            .read(panditProvider.notifier)
                            .searchPandit(value),
                        style: text14(),
                        decoration: InputDecoration(
                          hintText: 'Search by name, city, language...',
                          hintStyle: text13(color: AppColors.grey500),

                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 20,
                            color: AppColors.grey600,
                          ),

                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    ref
                                        .read(panditProvider.notifier)
                                        .searchPandit('');
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: AppColors.grey500,
                                  ),
                                )
                              : null,

                          border: InputBorder.none,

                          isDense: true,

                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Advanced filter button
                  GestureDetector(
                    onTap: _openFilterSheet,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _filters.hasAnyFilter
                            ? AppColors.button
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: _filters.hasAnyFilter
                                ? AppColors.white
                                : AppColors.grey700,
                          ),
                          // Red dot when filters active
                          if (_filters.hasAnyFilter)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════
            // Quick filter chips row (under search)
            // ══════════════════════════════════
            Container(
              color: AppColors.headerCard,
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // "All" chip
                    _quickChip(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      selected:
                          _filters.serviceType == null &&
                          _filters.minRating == null &&
                          _filters.language == null &&
                          _filters.minExperience == null,
                      onTap: () =>
                          setState(() => _filters = const PanditFilterState()),
                    ),

                    const SizedBox(width: 8),

                    // Service type quick chips
                    for (final qf in _quickFilters) ...[
                      _quickChip(
                        label: qf.label,
                        icon: qf.icon,
                        selected: _filters.serviceType == qf.type,
                        onTap: () => setState(() {
                          final selected = ServiceModel(
                            title: qf.label,
                            type: qf.type,
                            description: qf.dec,
                            icon: qf.icon,
                          );

                          ref.read(selectedServiceProvider.notifier).state =
                              selected;

                          print(ref.read(selectedServiceProvider));
                          _filters = _filters.copyWith(
                            serviceType: _filters.serviceType == qf.type
                                ? null
                                : qf.type,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                    ],

                    // Rating quick chip
                    _quickChip(
                      label: '4★ & above',
                      icon: Icons.star_rounded,
                      selected: _filters.minRating == 4.0,
                      onTap: () => setState(() {
                        _filters = _filters.copyWith(
                          minRating: _filters.minRating == 4.0 ? null : 4.0,
                        );
                      }),
                    ),

                    const SizedBox(width: 8),

                    // Experience quick chip
                    _quickChip(
                      label: '5+ yrs exp',
                      icon: Icons.workspace_premium_outlined,
                      selected: _filters.minExperience == 5,
                      onTap: () => setState(() {
                        _filters = _filters.copyWith(
                          minExperience: _filters.minExperience == 5 ? null : 5,
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),

            // ══════════════════════════════════
            // Active filter tags (when advanced filters set)
            // ══════════════════════════════════
            if (_filters.hasAnyFilter)
              Container(
                color: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (_filters.language != null)
                              _activeTag(
                                _filters.language!,
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(language: null);
                                }),
                              ),
                            if (_filters.minExperience != null &&
                                _filters.minExperience != 5)
                              _activeTag(
                                '${_filters.minExperience}+ yrs',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(
                                    minExperience: null,
                                  );
                                }),
                              ),
                            if (_filters.minRating != null &&
                                _filters.minRating != 4.0)
                              _activeTag(
                                '${_filters.minRating}★+',
                                onRemove: () => setState(() {
                                  _filters = _filters.copyWith(minRating: null);
                                }),
                              ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _filters = const PanditFilterState());
                        ref.invalidate(selectedServiceProvider);
                      },
                      child: Text(
                        'Clear all',
                        style: text12(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),

            // ══════════════════════════════════
            // Pandit Grid
            // ══════════════════════════════════
            Expanded(
              child: panditAsync.when(
                loading: () => RefreshIndicator(
                  onRefresh: _refreshPandits,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.button,
                        ),
                      ),
                    ),
                  ),
                ),
                error: (e, _) => RefreshIndicator(
                  onRefresh: _refreshPandits,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: const Center(child: Text('Something went wrong')),
                    ),
                  ),
                ),
                data: (data) {
                  final isSearching = _searchController.text.trim().isNotEmpty;

                  final pandits = _applyFilters(
                    isSearching ? data.searchResults : data.pandit,
                  );
                  // final base = data.searchResults.isNotEmpty
                  //     ? data.searchResults
                  //     : data.pandit;
                  // final pandits = _applyFilters(base);

                  if (pandits.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshPandits,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.55,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.grey100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 40,
                                  color: AppColors.grey400,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No pandits found',
                                style: text16(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Try adjusting your filters',
                                style: text13(color: AppColors.grey500),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () => setState(
                                  () => _filters = const PanditFilterState(),
                                ),
                                child: Text(
                                  'Clear filters',
                                  style: text13(color: AppColors.button),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshPandits,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                      children: [
                        // Results count row
                        Row(
                          children: [
                            Text(
                              '${pandits.length} Pandit${pandits.length == 1 ? '' : 's'} found',
                              style: text13(
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (_filters.hasAnyFilter)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.button.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Filtered',
                                  style: text11(
                                    color: AppColors.button,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.72,
                              ),
                          itemCount: pandits.length,
                          itemBuilder: (context, index) =>
                              _buildPanditCard(pandits[index]),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'View More',
                            style: text14(
                              color: AppColors.button,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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

  // ── Quick chip (horizontal row under search) ──
  Widget _quickChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
            width: 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? Colors.white : AppColors.grey600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: text12(
                color: selected ? Colors.white : AppColors.grey700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Active tag (advanced filter applied) ──
  Widget _activeTag(String label, {required VoidCallback onRemove}) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.button.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.button.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: text12(color: AppColors.button, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: AppColors.button),
          ),
        ],
      ),
    );
  }

  // ── Sheet helpers ──

  Widget _sheetSectionLabel(String label) =>
      Text(label, style: text14(fontWeight: FontWeight.w600));

  Widget _serviceTypeCard({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.button.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Colors.white : AppColors.button,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: text11(
                color: selected ? Colors.white : AppColors.grey700,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.button : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.button : AppColors.grey300,
          ),
        ),
        child: Text(
          label,
          style: text13(
            color: selected ? Colors.white : AppColors.grey700,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ── Pandit Card ──
  Widget _buildPanditCard(PanditData pandit) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          children: [
            // Background image
            Positioned.fill(
              child: CustomCachedImage(imageUrl: pandit.profileImage ?? ''),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.35),
                      Colors.black.withOpacity(0.78),
                    ],
                    stops: const [0.35, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Verified badge (top-right)
            if (pandit.isVerified == true)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text('Verified', style: text10(color: Colors.white)),
                    ],
                  ),
                ),
              ),

            // Content (bottom)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pandit.fullName ?? 'N/A',
                      style: text14(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          pandit.ratingAverage?.toStringAsFixed(1) ?? '—',
                          style: text11(color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        if ((pandit.yearsOfExperience ?? 0) > 0) ...[
                          const Icon(
                            Icons.circle,
                            size: 3,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${pandit.yearsOfExperience}y',
                            style: text11(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppButton(
                      height: 28,
                      textStyle: text11(
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      title: 'View Details',
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.panditDetails,
                        arguments: pandit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
