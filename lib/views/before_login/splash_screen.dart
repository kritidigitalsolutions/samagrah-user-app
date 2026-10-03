import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));

    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final token = await AuthLocalstorageService.getToken();
    final isGuest = await AuthLocalstorageService.isGuestMode();

    // ── Apple 5.1.1(v):
    // 1. Logged in users -> Home
    // 2. Returning guest users -> Home directly (restart handling)
    // 3. First time users -> Register/Login (initial auth flow) with Skip/Guest option
    if (token != null && token.trim().isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (isGuest) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B0E1E),
      body: Image.asset(
        "assets/starting-screen.png",
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
