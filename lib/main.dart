import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/repo/notification_repo.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_pages.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/localStogare_service/location_storage.dart';
import 'package:samagrah/utils/service/firebase_notification.dart';
import 'package:samagrah/utils/service/location_checker.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/home_provider.dart';
import 'package:samagrah/views/after_login/category_page.dart';
import 'package:samagrah/views/after_login/customize_kit/customize_kit_search_page.dart';
import 'package:samagrah/views/after_login/home_screen.dart';
import 'package:samagrah/views/after_login/pandit/book_retual_page.dart';
import 'package:samagrah/views/service_pages/location_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize FCM Service
  await FCMNotificationService().initialize();
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
      routes: AppPages.routes,
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
  final NotificationRepo _repo = NotificationRepo();
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bottomNavProvider.notifier).state = widget.index ?? 0;
    });
    _loadSavedLocation();
    _handleLocationCheck();
  }

  void _handleLocationCheck() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');

    if (token == null || token.isEmpty) {
      token = await FirebaseMessaging.instance.getToken();
      await _repo.postFCMToken(token ?? '');
    } else {
      await _repo.postFCMToken(token);
    }

    final hasPermission = await checkLocationPermission();

    if (!hasPermission && mounted) {
      Navigator.pushNamed(context, AppRoutes.locationPage);
    }
  }

  void _loadSavedLocation() async {
    final city = await LocationStorage.getCity();
    final state = await LocationStorage.getState();

    if (city != null && state != null) {
      ref.read(locationProvider.notifier).state = LocationModel(
        city: city,
        state: state,
      );
    }
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
   ref.read(userProvider);
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
