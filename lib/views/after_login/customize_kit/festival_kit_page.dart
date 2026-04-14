import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/festival_kit_provider.dart';

class FestivalKitPage extends ConsumerStatefulWidget {
  const FestivalKitPage({super.key});

  @override
  ConsumerState<FestivalKitPage> createState() => _FestivalKitPageState();
}

class _FestivalKitPageState extends ConsumerState<FestivalKitPage> {
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(festivalProvider.notifier).searchFestival(value);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final festivalAsync = ref.watch(festivalProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Special Kit for\nFestivals Kit',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/hands.png',
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
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              SizedBox(height: 10),

              /// Search Bar
              TextField(
                style: text14(
                  fontWeight: FontWeight.normal,
                  color: AppColors.black,
                ),
                onChanged: _onSearchChanged,
                cursorColor: AppColors.black,
                decoration: InputDecoration(
                  hintText: 'Search festival kit...',
                  hintStyle: text14(color: AppColors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// List
              Expanded(
                child: festivalAsync.when(
                  loading: () => ListView.builder(
                    itemCount: 4,
                    itemBuilder: (_, __) => Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  error: (e, _) => Center(child: Text("Something went wrong")),

                  data: (state) {
                    final list = state.festivalKit?.data ?? [];

                    if (list.isEmpty) {
                      return const Center(child: Text("No Data Found"));
                    }

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];

                        return FestivalCard(
                          title: item.name ?? "",
                          subtitle: item.description ?? "",
                          image: item.image ?? "", // 👈 from API
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FestivalCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String image;

  const FestivalCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(isFestivalProvider.notifier).state = true;
        Navigator.pushNamed(context, AppRoutes.festivalKitDetails);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.primaryGradient,
        ),
        child: Row(
          children: [
            /// Text Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: text16(
                      color: AppColors.white,

                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(subtitle, style: text12(color: AppColors.grey400)),
                  const Spacer(),

                  /// Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "View Kit",
                      style: TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            /// Image
            Image.network(
              "http://192.168.1.40:8000$image",
              height: 110,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, size: 80);
              },
            ),
          ],
        ),
      ),
    );
  }
}
