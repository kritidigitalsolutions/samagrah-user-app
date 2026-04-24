class AppUrls {
  static const String baseUrl = "http://192.168.1.40:8000/api";

  // ================ Auth =====================================

  static const String registerUser = "$baseUrl/auth/signup";
  static const String login = "$baseUrl/auth/login";
  static const String verifyOtp = "$baseUrl/auth/verify-otp";
  static const String resendOtp = "$baseUrl/auth/resend-otp";

  // ======================= Kit===================================

  static const String festivalKit = "$baseUrl/user/kits";
  static const String userKit = "$baseUrl/user-kits";
  static const String getMyKit = "$baseUrl/user-kits/my-kits";
  static const String defaultKit = "$baseUrl/default-kits";

  // ======================= product===================================

  static const String getProduct = "$baseUrl/user/items";

  //==========================payment =================================

  static const String createOrder = "$baseUrl/order/payment/razorpay/order";
  static const String verifyPayment = "$baseUrl/order/place";

  //==========================bokked order =================================

  static const String myOrder = "$baseUrl/order/my";
  //static const String verifyPayment = "$baseUrl/order/place";

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

  //========================== Policy api =================================

  static const String term = "$baseUrl/legal/term";
  static const String privacy = "$baseUrl/legal/privacy";
  static const String aboutUs = "$baseUrl/aboutus";
}
