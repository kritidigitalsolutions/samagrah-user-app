class AppUrls {
  static const String baseUrl = "http://192.168.1.4:8000/api";

  //static const String baseUrl = "https://samagran-backend.vercel.app/api";

  // ================ Auth =====================================

  static const String registerUser = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/send-otp";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String resendOtp = "$baseUrl/auth/resend-otp";

  // ======================= Kit===================================

  static const String festivalKit = "$baseUrl/user/kits";
  static const String userKit = "$baseUrl/user-kits";
  // static const String getMyKit = "$baseUrl/user-kits/my-kits";
  static const String defaultKit = "$baseUrl/kits";

  // ======================= product===================================

  static const String getProduct = "$baseUrl/user/items";
  static const String banner = "$baseUrl/banners";

  //==========================payment =================================

  static const String productCreateOrder =
      "$baseUrl/order/payment/razorpay/order";
  static const String productVerifyPayment = "$baseUrl/order/place";

  //==========================bokked order =================================

  static const String myOrder = "$baseUrl/order/my";
  static const String order = "$baseUrl/order";

  //========================== Address pages =================================

  static const String address = "$baseUrl/order/addresses";
  // static const String postAddress = "$baseUrl/order/place";

  //========================== my cart =================================

  static const String myCart = "$baseUrl/cart";
  static const String addCart = "$baseUrl/cart/add";
  static const String removeCart = "$baseUrl/cart/remove";

  //==========================Wishlist api =================================

  static const String wishlist = "$baseUrl/wishlist/my";
  static const String wishlistToggle = "$baseUrl/wishlist/toggle";

  //========================== Pandit api =================================

  static const String rituals = "$baseUrl/pandit-bookings/rituals";
  static const String pandit = "$baseUrl/pandit-bookings/pandits";
  static const String availability = "$baseUrl/pandit-availability";
  static const String panditCreateOrder = "$baseUrl/pandit-bookings";
  static const String panditVerifyPayment = "$baseUrl/order/place";
  static const String slotPanditBooking = "$baseUrl/booking-price/price";
  static const String temple = "$baseUrl/temples";
  static const String panditHistory = "$baseUrl/pandit-bookings/my";

  //========================== Policy api =================================

  static const String term = "$baseUrl/legal/term";
  static const String privacy = "$baseUrl/legal/privacy";
  static const String aboutUs = "$baseUrl/legal/aboutus";

  //========================== profile edit api =================================

  static const String editProfile = "$baseUrl/user";
  static const String deleteAccount = "$baseUrl/user/delete-account";

  //========================== wallet and offers =================================

  static const String offers = "$baseUrl/user/offers/active";
  static const String wallet = "$baseUrl/user/wallet/transactions";
  static const String walletCreateOrder =
      "$baseUrl/user/wallet/topup/razorpay/order";
  static const String walletVerify = "$baseUrl/user/wallet/topup/confirm";

  // ================== Coupons ===============================

  static const String coupon = "$baseUrl/user/coupons";

  static const String couponApply = "$baseUrl/user/coupons/apply";

  // video call

  static const String video = '$baseUrl/user/video';
  static const String videoToken = '$baseUrl/user/video/token';
  static const String videoStart = '$baseUrl/user/video/start';

  // notification

  static const String fcmToken = "$baseUrl/user/fcm-token";
  static const String notifications = '$baseUrl/user/notifications';
  static String notificationRead(String id) =>
      '$baseUrl/user/notifications/$id/read';
  static String notificationDelete(String id) =>
      '$baseUrl/user/notifications/$id';
}
