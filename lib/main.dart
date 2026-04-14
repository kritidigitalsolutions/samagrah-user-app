import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/after_login/category_page.dart';
import 'package:samagrah/views/after_login/customize_kit/customize_items_page.dart';
import 'package:samagrah/views/after_login/customize_kit/customize_kit_search_page.dart';
import 'package:samagrah/views/after_login/customize_kit/festival_kit_details.dart';
import 'package:samagrah/views/after_login/customize_kit/festival_kit_page.dart';
import 'package:samagrah/views/after_login/customize_kit/selected_cus_kit_items.dart';
import 'package:samagrah/views/after_login/home_screen.dart';
import 'package:samagrah/views/after_login/notification_page.dart';
import 'package:samagrah/views/after_login/order/my_order_screen.dart';
import 'package:samagrah/views/after_login/order/order_details_screen.dart';
import 'package:samagrah/views/after_login/order/track_order_screen.dart';
import 'package:samagrah/views/after_login/pandit/bookings/cancel_booking.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/address_selection.dart';
import 'package:samagrah/views/after_login/pandit/book_pandit_page.dart';
import 'package:samagrah/views/after_login/pandit/book_retual_page.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/booking_confirmed_page.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/booking_summary_page.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/online_booking_details.dart';
import 'package:samagrah/views/after_login/pandit/bookings/my_booking_details.dart';
import 'package:samagrah/views/after_login/pandit/bookings/my_booking_page.dart';
import 'package:samagrah/views/after_login/pandit/pandit_details_page.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/pandit_payment_success.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/service_selection_screen.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/temple_selection_screen.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/time_slot_selection_screen.dart';
import 'package:samagrah/views/after_login/pandit/pandit_recommended_kit_pages/pandit_rec_kit_page.dart';
import 'package:samagrah/views/after_login/pandit/pandit_recommended_kit_pages/pandit_rec_kit_selection.dart';
import 'package:samagrah/views/after_login/product/checkout/address_page.dart';
import 'package:samagrah/views/after_login/product/checkout/order_summary_page.dart';
import 'package:samagrah/views/after_login/product/checkout/payment_page.dart';
import 'package:samagrah/views/after_login/product/checkout/success_page.dart';
import 'package:samagrah/views/after_login/product/daliy_pooja_essential_page.dart';
import 'package:samagrah/views/after_login/product/my_cart_page.dart';
import 'package:samagrah/views/after_login/product/product_details.dart';
import 'package:samagrah/views/after_login/profile/my_fav_products.dart';
import 'package:samagrah/views/after_login/profile/my_profile_Page.dart';
import 'package:samagrah/views/after_login/profile/saved_address_page.dart';
import 'package:samagrah/views/after_login/wallet/my_wallet_screen.dart';
import 'package:samagrah/views/before_login/login_page.dart';
import 'package:samagrah/views/before_login/otp_verfied_screen.dart';
import 'package:samagrah/views/before_login/register_screen.dart';
import 'package:samagrah/views/before_login/splash_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      // ← Must wrap the entire app
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.headerCard,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.otp: (context) => const VerifyOtpScreen(),
        AppRoutes.loginPage: (context) => const LoginPage(),

        AppRoutes.home: (context) => const MyHomeScreen(),
        AppRoutes.notification: (context) => const NotificationPage(),
        AppRoutes.comparisionPage: (context) => const CategoryPage(),
        AppRoutes.myWallet: (context) => const MyWalletScreen(),

        AppRoutes.productDetails: (context) => const ProductDetails(),
        AppRoutes.orderSummary: (context) => const OrderSummaryScreen(),
        AppRoutes.addressPage: (context) => const AddressPage(),
        AppRoutes.paymentPage: (context) => const PaymentPage(),
        AppRoutes.successPage: (context) => const SuccessPage(),
        AppRoutes.dalityPujaE: (context) => DailyPujaEssentialsScreen(),
        AppRoutes.myCart: (context) => MyCartPage(),

        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.savedAddress: (context) => const SavedAddressesScreen(),
        AppRoutes.favProduct: (context) => const MyFavProducts(),

        // AppRoutes.editAddAddress: (context) => const EditAddAddressPage(),
        AppRoutes.bookPandit: (context) => const BookPanditPage(),
        AppRoutes.panditDetails: (context) => const PanditDetailsPage(),
        AppRoutes.serviceSelection: (context) => ServiceSelectionScreen(),
        AppRoutes.timeSelection: (context) => const TimeSlotSelectionScreen(),
        AppRoutes.addressSelection: (context) => const AddressSelectionScreen(),
        AppRoutes.bookingSummary: (context) => const BookingSummaryScreen(),
        AppRoutes.panditPayment: (context) => const PaymentSuccessScreen(),
        AppRoutes.bookingConfirmed: (context) => const BookingConfirmedScreen(),
        AppRoutes.onlineDetails: (context) => const OnlineBookingDetails(),
        AppRoutes.templeSelection: (context) => const TempleSelectionScreen(),
        AppRoutes.panditRecKit: (context) => const PanditRecKitPage(),
        AppRoutes.panditRecKit2: (context) => const PanditRecKitSelection(),
        AppRoutes.myBooking: (context) => const MyBookingsPage(),
        AppRoutes.myBookingDetails: (context) => const MyBookingDetails(),
        AppRoutes.cancelBooking: (context) => const CancelBooking(),

        AppRoutes.kitItems: (context) => const CustomizeItemsPage(),
        AppRoutes.selectedCusKit: (context) => const SelectedCusKitItems(),
        AppRoutes.festivalKit: (context) => const FestivalKitPage(),
        AppRoutes.festivalKitDetails: (context) => const FestivalKitDetails(),

        AppRoutes.myOrder: (context) => const MyOrdersPage(),
        AppRoutes.trackOrder: (context) => const TrackOrderPage(),
        AppRoutes.orderDetails: (context) => const OrderDetailsPage(),
      },
    );
  }
}

class MyHomeScreen extends ConsumerStatefulWidget {
  final int? index;
  const MyHomeScreen({super.key, this.index = 0});

  @override
  ConsumerState<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends ConsumerState<MyHomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bottomNavProvider.notifier).state = widget.index ?? 0;
    });
  }

  final List<Widget> _screens = [
    const HomeScreen(), // Main screen
    const BookRetualPage(),
    CustomizePoojaKitScreen(),
    const CategoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      backgroundColor: AppColors.headerCard,
      body: IndexedStack(index: currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(child: _customBottomBar(currentIndex)),
    );
  }

  Widget _customBottomBar(int currentIndex) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Row(
          children: [
            _navItem('assets/nav/home.png', 'Home', 0, currentIndex),
            _navItem('assets/nav/p.png', 'Book Pandit', 1, currentIndex),
            _navItem('assets/nav/k.png', 'Customize Kit', 2, currentIndex),
            _navItem('assets/nav/category.png', 'Categories', 3, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String path, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (currentIndex == index) return;
          ref.read(bottomNavProvider.notifier).state = index;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Image.asset(
                  path,
                  width: isSelected ? 26 : 24,
                  height: isSelected ? 26 : 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.2,
                  color: isSelected ? AppColors.button : AppColors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
