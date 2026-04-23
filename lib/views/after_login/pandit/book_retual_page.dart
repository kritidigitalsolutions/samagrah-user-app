import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/ritual_pandit_provider.dart';

class BookRetualPage extends ConsumerStatefulWidget {
  const BookRetualPage({super.key});

  @override
  ConsumerState<BookRetualPage> createState() => _BookRitualViewState();
}

class _BookRitualViewState extends ConsumerState<BookRetualPage> {
  final TextEditingController _searchController = TextEditingController();

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
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) => Center(child: Text("Error: $e")),

              data: (state) {
                final rituals = state.searchResults.isNotEmpty
                    ? state.searchResults
                    : state.rituals;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: rituals.length,
                    itemBuilder: (context, index) {
                      final ritual = rituals[index];
                      final isSelected = selectedRitual?.id == ritual.id;

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
                            children: [
                              /// Text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ritual.description ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
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
