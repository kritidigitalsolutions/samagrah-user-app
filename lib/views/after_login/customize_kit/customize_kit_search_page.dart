import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class CustomizePoojaKitScreen extends ConsumerWidget {
  CustomizePoojaKitScreen({super.key});

  final nameKitCtr = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPooja = ref.watch(selectedPoojaProvider);

    final poojas = [
      'Satyanarayan Pooja',
      'Griha Provesh Pooja',
      'Lakshmi Pooja',
      'Ganesh Pooja', // ✅ changed
    ];

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(color: AppColors.background),
        child: Column(
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
                        const Text(
                          'Customize\nYour Pooja Kit',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                        child: Center(child: Icon(Icons.image)),
                      );
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  SizedBox(height: 50),
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.pink.withOpacity(0.1),
                          child: Image.asset("assets/nav/cart.png", width: 40),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Create your own kit by\nchoosing the items you need\nfor your pooja',
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        /// ✅ STEP 2 (Dropdown)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: AppColors.button,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedPooja,
                              isExpanded: true,
                              dropdownColor: AppColors.button,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.white,
                              ),

                              hint: const Text(
                                "Search Kit",
                                style: TextStyle(color: AppColors.white),
                              ),

                              items: poojas.map((pooja) {
                                return DropdownMenuItem<String>(
                                  value: pooja,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          pooja,
                                          style: text14(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          bottom: 5,
                                          top: 5,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.asset(
                                            "assets/god.png",
                                            width: 50,
                                            height: 50,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          ref
                                                  .read(
                                                    selectedPoojaProvider
                                                        .notifier,
                                                  )
                                                  .state =
                                              null;
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: AppColors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),

                              onChanged: (value) {
                                ref.read(selectedPoojaProvider.notifier).state =
                                    value;

                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.festivalKitDetails,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        if (selectedPooja == null || selectedPooja.isEmpty) ...[
                          AppTextField(
                            radius: 8,
                            controller: nameKitCtr,
                            hintText: "Name your Kit",
                          ),

                          const SizedBox(height: 15),

                          AppButton(
                            radius: 8,
                            height: 45,
                            title: "+ Start Adding Items",
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.kitItems);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  // SizedBox(height: 20),

                  // AppButton(
                  //   radius: 8,
                  //   height: 45,
                  //   title: "Next",
                  //   onTap: () {
                  //     Navigator.pushNamed(context, AppRoutes.kitItems);
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
