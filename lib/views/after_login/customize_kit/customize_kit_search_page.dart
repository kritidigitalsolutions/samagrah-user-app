import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/custom_textfields.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/customize_kit_provider.dart';

class CustomizePoojaKitScreen extends ConsumerWidget {
  CustomizePoojaKitScreen({super.key});

  final nameKitCtr = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poojas = [
      'Satyanarayan Pooja',
      'Griha Provesh Pooja',
      'Lakshmi Pooja',
      'Ganesh Pooja',
    ];

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
            ],
          ),
        ),
        child: Column(
          children: [
            // ✅ Top bar - keeping it the same
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
                          'Customize\nYour Pooja Kit',
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
                        child: Center(child: Icon(Icons.image)),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ✅ Premium body design
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // ✅ Floating premium card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white, Colors.grey.shade50],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                              spreadRadius: -5,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Stack(
                            children: [
                              // ✅ Decorative circles
                              Positioned(
                                top: -50,
                                right: -50,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.orange.withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -30,
                                left: -30,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.pink.withOpacity(0.08),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // ✅ Main content
                              Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  children: [
                                    // ✅ Premium icon with animation-ready design
                                    Container(
                                      width: 90,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.orange.shade300,
                                            Colors.deepOrange.shade400,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.orange.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            "assets/nav/cart.png",
                                            width: 42,
                                            height: 42,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // ✅ Modern heading
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          LinearGradient(
                                            colors: [
                                              Colors.orange.shade700,
                                              Colors.deepOrange.shade600,
                                            ],
                                          ).createShader(bounds),
                                      child: const Text(
                                        'Create Your Custom Kit',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    Text(
                                      'Handpick sacred items for your\npersonalized pooja ceremony',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600,
                                        height: 1.6,
                                        letterSpacing: 0.2,
                                      ),
                                    ),

                                    const SizedBox(height: 36),

                                    // ✅ Premium search field
                                    _buildPremiumSearchField(
                                      context,
                                      ref,
                                      poojas,
                                    ),

                                    const SizedBox(height: 20),

                                    // ✅ Premium name field
                                    _buildPremiumTextField(),

                                    const SizedBox(height: 28),

                                    // ✅ Premium button
                                    _buildPremiumButton(context),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ✅ Feature cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildFeatureCard(
                              icon: Icons.check_circle_outline,
                              title: 'Customizable',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              icon: Icons.auto_awesome,
                              title: 'Premium Items',
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildFeatureCard(
                              icon: Icons.verified,
                              title: 'Authentic',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Premium search field builder
  Widget _buildPremiumSearchField(
    BuildContext context,
    WidgetRef ref,
    List<String> poojas,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Select Pooja Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppColors.button, AppColors.button.withOpacity(0.9)],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.button.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return poojas.where(
                (pooja) => pooja.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            fieldViewBuilder:
                (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    cursorColor: AppColors.white,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search for pooja kit...",
                      hintStyle: TextStyle(
                        color: AppColors.white.withOpacity(0.65),
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.white.withOpacity(0.9),
                        size: 24,
                      ),
                      suffixIcon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: AppColors.white.withOpacity(0.9),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  );
                },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 12,
                  shadowColor: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.15),
                                    Colors.deepOrange.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/god.png",
                                  width: 32,
                                  height: 32,
                                ),
                              ),
                            ),
                            title: Text(
                              option,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            onTap: () {
                              onSelected(option);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
            onSelected: (value) {
              ref.read(selectedPoojaProvider.notifier).state = value;
              ref.read(isFestivalProvider.notifier).state = false;
              Navigator.pushNamed(context, AppRoutes.festivalKitDetails);
            },
          ),
        ),
      ],
    );
  }

  // ✅ Premium text field builder
  Widget _buildPremiumTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange, Colors.deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kit Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AppTextField(
            radius: 16,
            controller: nameKitCtr,
            hintText: "e.g., My Diwali Special Kit",
          ),
        ),
      ],
    );
  }

  // ✅ Premium button builder
  Widget _buildPremiumButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.deepOrange.shade500],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.kitItems);
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Start Adding Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Feature card builder
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
