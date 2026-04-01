import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final otpProvider = StateProvider<List<String>>((ref) => ['', '', '', '']);

final verifyOtpProvider = FutureProvider.family<bool, String>((ref, otp) async {
  // call API here
  await Future.delayed(Duration(seconds: 2));
  return otp == "1234"; // example
});
