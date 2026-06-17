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

    final token = await AuthLocalstorageService.getToken(); // 👈 GET TOKEN

    if (token != null && token.isNotEmpty) {
      // ✅ USER LOGGED IN
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // ❌ NEW USER
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
