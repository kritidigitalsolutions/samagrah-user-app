import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class BookRetualPage extends ConsumerStatefulWidget {
  const BookRetualPage({super.key});

  @override
  ConsumerState<BookRetualPage> createState() => _BookRitualViewState();
}

class _BookRitualViewState extends ConsumerState<BookRetualPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _expandedRitualIds = {};

  Future<void> _refreshRituals() {
    return ref.refresh(ritualProvider.future);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ritualAsync = ref.watch(ritualProvider);
    final selectedRitual = ref.watch(selectedRitualProvider);
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Column(
          children: [
            /// 🔹 Header Section (Custom AppBar Style)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Info Row
                Container(
                  color: AppColors.headerCard,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Book your Pandit',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Schedule a pandit for your\nritual needs',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        'assets/panditLogo.png',
                        width: 70,
                        height: 70,
                        errorBuilder: (context, exception, stackTrace) {
                          return Container(
                            width: 65,
                            height: 65,
                            decoration: BoxDecoration(color: AppColors.grey500),
                            child: Center(child: Icon(Icons.image)),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: const Text(
                          'Choose the ritual you would like to perform',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      // search bar
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.grey600,
                                size: 18,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    ref
                                        .read(ritualProvider.notifier)
                                        .searchProducts(value);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search ritual...',
                                    hintStyle: TextStyle(
                                      color: AppColors.grey400,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();

                                  // reset search
                                  ref
                                      .read(ritualProvider.notifier)
                                      .searchProducts('');
                                },
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.grey600,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            /// 🔹 Ritual List
            ritualAsync.when(
              loading: () => Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRituals,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
              ),

              error: (e, _) => Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshRituals,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: Center(child: Text("Error: $e")),
                    ),
                  ),
                ),
              ),

              data: (state) {
                final rituals = state.searchResults.isNotEmpty
                    ? state.searchResults
                    : state.rituals;

                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshRituals,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: rituals.length,
                      itemBuilder: (context, index) {
                        final ritual = rituals[index];
                        final isSelected = selectedRitual?.id == ritual.id;
                        final isExpanded = _expandedRitualIds.contains(
                          ritual.id,
                        );
                        final desc = ritual.description ?? '';
                        final isLong = desc.length > 120;

                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedRitualProvider.notifier).state =
                                ritual;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.button
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ritual.title ?? '',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        desc,
                                        maxLines: isExpanded ? null : 4,
                                        overflow: isExpanded
                                            ? TextOverflow.visible
                                            : TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      if (isLong) ...[
                                        const SizedBox(height: 4),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isExpanded) {
                                                _expandedRitualIds.remove(
                                                  ritual.id,
                                                );
                                              } else {
                                                _expandedRitualIds.add(
                                                  ritual.id ?? '',
                                                );
                                              }
                                            });
                                          },
                                          child: Text(
                                            isExpanded
                                                ? "Show Less"
                                                : "Read More",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.button,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          if (ritual.durationHours != null)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.grey100,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.access_time_rounded,
                                                    size: 12,
                                                    color: AppColors.grey600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${ritual.durationHours} Hours',
                                                    style: text10(
                                                      color: AppColors.grey700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (ritual.standardSamagri == true ||
                                              ritual.customSamagri == true)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.inventory_2_outlined,
                                                    size: 12,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Samagri Available',
                                                    style: text10(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          // if (ritual.travelForSpecialPooja ==
                                          //     true)
                                          //   Container(
                                          //     padding:
                                          //         const EdgeInsets.symmetric(
                                          //           horizontal: 6,
                                          //           vertical: 2,
                                          //         ),
                                          //     decoration: BoxDecoration(
                                          //       color: Colors.blue.withOpacity(
                                          //         0.1,
                                          //       ),
                                          //       borderRadius:
                                          //           BorderRadius.circular(6),
                                          //     ),
                                          //     child: Row(
                                          //       mainAxisSize: MainAxisSize.min,
                                          //       children: [
                                          //         const Icon(
                                          //           Icons
                                          //               .flight_takeoff_rounded,
                                          //           size: 12,
                                          //           color: Colors.blue,
                                          //         ),
                                          //         const SizedBox(width: 4),
                                          //         Text(
                                          //           'Travel Support',
                                          //           style: text10(
                                          //             color: Colors.blue,
                                          //           ),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),

                                /// Image
                                CustomCachedImage(
                                  imageUrl: ritual.image ?? '',
                                  width: 65,
                                  height: 65,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),

            /// 🔹 Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: AppButton(
                title: 'Next >',
                onTap: () {
                  final selected = ref.read(selectedRitualProvider);

                  if (selected == null) {
                    AppSnackbar.show(
                      context,
                      message: "Please select a ritual",
                      type: SnackBarType.info,
                    );
                    return;
                  }

                  ref.invalidate(panditProvider);

                  Navigator.pushNamed(
                    context,
                    AppRoutes.bookPandit,
                    arguments: selected, // 🔥 pass selected ritual
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
