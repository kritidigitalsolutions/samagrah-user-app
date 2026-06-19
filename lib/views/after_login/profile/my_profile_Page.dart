import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';
import 'package:samagrah/view_model/after_login_provider/order_provider/order_provider.dart';
import 'package:samagrah/view_model/after_login_provider/pandit_provider/booking_provider.dart';
import 'package:samagrah/view_model/before_login_provider/auth_provider.dart';
import 'package:samagrah/views/after_login/profile/policy/policy_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,

        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: text18(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Profile Section
              userAsync.when(
                data: (user) => _buildProfileHeader(context, user),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => const Text("Error loading user"),
              ),

              const SizedBox(height: 30),

              // User Menu Section
              _buildSectionTitle('User Menu'),
              const SizedBox(height: 15),

              _buildMenuCard([
                _MenuItem("assets/profile/bag.png", 'My Orders', () {
                  Navigator.pushNamed(context, AppRoutes.myOrder);
                }),

                _MenuItem("assets/profile/wishlist.png", 'Wishlist', () {
                  print("my booking kjsa =======================");
                  Navigator.pushNamed(context, AppRoutes.favProduct);
                }),

                _MenuItem("assets/profile/trolley.png", 'My Cart', () {
                  Navigator.pushNamed(context, AppRoutes.myCart);
                }),

                _MenuItem("assets/profile/pray.png", 'Book my Pandit', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyHomeScreen(index: 1)),
                  );
                }),

                // _MenuItem(
                //   "assets/profile/fireworks.png",
                //   'Special Kit for Festivals',
                //   () {
                //     Navigator.pushNamed(context, AppRoutes.festivalKit);
                //   },
                // ),
                _MenuItem("assets/profile/box.png", 'Customer and Kit', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyHomeScreen(index: 2)),
                  );
                }),

                _MenuItem("assets/profile/booking.png", 'My Bookings', () {
                  Navigator.pushNamed(context, AppRoutes.myBooking);
                }),
                _MenuItem("assets/profile/voucher.png", 'My Coupons', () {
                  Navigator.pushNamed(context, AppRoutes.coupon);
                }),
              ]),
              const SizedBox(height: 30),

              // Settings Section
              _buildSectionTitle(''),
              const SizedBox(height: 15),
              _buildMenuCard([
                _MenuItem("assets/profile/support.png", 'Help & Support', () {
                  Navigator.pushNamed(context, AppRoutes.helpAndSupport);
                }),
                _MenuItem("assets/profile/loc.png", 'Saved Address', () {
                  Navigator.pushNamed(context, AppRoutes.savedAddress);
                }),
                _MenuItem("assets/profile/info.png", 'About US', () {
                  Navigator.pushNamed(context, AppRoutes.aboutUs);
                }),
                _MenuItem("assets/profile/term.png", 'Terms & Conditions', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PolicyPage(
                        title: "Terms & Conditions",
                        isTerms: true,
                      ),
                    ),
                  );
                }),

                _MenuItem("assets/profile/privacy.png", 'Privacy Policy', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PolicyPage(
                        title: "Privacy Policy",
                        isTerms: false,
                      ),
                    ),
                  );
                }),

                _MenuItem("assets/profile/refund.png", 'Refund Policy', () {
                  Navigator.pushNamed(context, AppRoutes.refund);
                }),
                _MenuItem("assets/profile/delete.png", 'Delete Account', () {
                  Navigator.pushNamed(context, AppRoutes.accoundDelete);
                }),
              ]),

              const SizedBox(height: 30),

              // Logout Button
              CustomElevatedButton(
                title: "Logout",
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 24, 24),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Color(
                              0xFFE91E63,
                            ), // Pink color matching your app
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Are you sure you want to logout?\nYou will need to login again to continue.',
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            ref.read(cartProvider.notifier).clearCart();
                            await AuthLocalstorageService.clear();
                            ref.read(authProvider.notifier).reset();
                            ref.invalidate(userProvider);
                            ref.invalidate(panditBookingProvider);
                            ref.invalidate(orderProvider);
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Map<String, dynamic>? user) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['name'] ?? 'No Name',
                  style: text15(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?['phone'] ?? 'No Phone',
                  style: text13(color: Colors.black45),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Edit',
                      style: text12(
                        color: AppColors.white,

                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Profile Image
          CircleAvatar(
            radius: 39,
            backgroundColor: AppColors.button,
            child: CircleAvatar(
              radius: 37,
              child: CustomCachedImage(
                imageUrl: user?['profileImage'] ?? '',

                borderRadius: BorderRadius.circular(35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: text16(fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    return Container(
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
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                leading: Image.asset(item.img, width: 22, height: 22),
                title: Text(
                  item.title,
                  style: text14(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.black26,
                  size: 20,
                ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Divider(height: 1, thickness: 1, color: AppColors.grey100),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final String img;
  final String title;
  final VoidCallback onTap;

  _MenuItem(this.img, this.title, this.onTap);
}
