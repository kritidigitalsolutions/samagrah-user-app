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

  // ======================= product===================================

  static const String getProduct = "$baseUrl/user/items";
}
