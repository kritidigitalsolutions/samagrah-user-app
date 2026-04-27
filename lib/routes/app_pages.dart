import 'package:flutter/material.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/views/after_login/category_page.dart';
import 'package:samagrah/views/after_login/customize_kit/customize_items_page.dart';
import 'package:samagrah/views/after_login/customize_kit/festival_kit_details.dart';
import 'package:samagrah/views/after_login/customize_kit/festival_kit_page.dart';
import 'package:samagrah/views/after_login/customize_kit/kit_order_summary_page.dart';
import 'package:samagrah/views/after_login/customize_kit/selected_cus_kit_items.dart';
import 'package:samagrah/views/after_login/notification_page.dart';
import 'package:samagrah/views/after_login/order/my_order_screen.dart';
import 'package:samagrah/views/after_login/order/order_details_screen.dart';
import 'package:samagrah/views/after_login/order/track_order_screen.dart';
import 'package:samagrah/views/after_login/pandit/bookings/cancel_booking.dart';
import 'package:samagrah/views/after_login/pandit/checkout_pandit/address_selection.dart';
import 'package:samagrah/views/after_login/pandit/book_pandit_page.dart';
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
import 'package:samagrah/views/after_login/profile/about_us_page.dart';
import 'package:samagrah/views/after_login/profile/delete_account_page.dart';
import 'package:samagrah/views/after_login/profile/my_fav_products.dart';
import 'package:samagrah/views/after_login/profile/my_profile_Page.dart';
import 'package:samagrah/views/after_login/profile/saved_address_page.dart';
import 'package:samagrah/views/after_login/search_product_page.dart';
import 'package:samagrah/views/after_login/wallet/my_wallet_screen.dart';
import 'package:samagrah/views/before_login/login_page.dart';
import 'package:samagrah/views/before_login/otp_verfied_screen.dart';
import 'package:samagrah/views/before_login/register_screen.dart';
import 'package:samagrah/views/before_login/splash_screen.dart';
import 'package:samagrah/views/service_pages/location_page.dart';

class AppPages {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashScreen(),
    AppRoutes.register: (context) => const RegisterScreen(),
    AppRoutes.otp: (context) => const VerifyOtpScreen(),
    AppRoutes.loginPage: (context) => const LoginPage(),

    AppRoutes.home: (context) => const MyHomeScreen(),
    AppRoutes.notification: (context) => const NotificationPage(),
    AppRoutes.comparisionPage: (context) => const CategoryPage(),
    AppRoutes.myWallet: (context) => const MyWalletScreen(),
    AppRoutes.searchProduct: (context) => const SearchProductPage(),
    AppRoutes.locationPage: (context) => const LocationPage(),

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
    AppRoutes.accoundDelete: (context) => const DeleteAccountScreen(),
    AppRoutes.aboutUs: (context) => const AboutUsPage(),

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
    AppRoutes.kitOrderSummary: (context) => const KitOrderSummaryPage(),

    AppRoutes.myOrder: (context) => const MyOrdersPage(),
    AppRoutes.trackOrder: (context) => TrackOrderPage(),
    AppRoutes.orderDetails: (context) => const OrderDetailsPage(),
  };
}
