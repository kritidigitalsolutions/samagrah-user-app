import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
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
  await Firebase.initializeApp();
  await FCMNotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Samagran',
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

  // ─────────────────────────────────────────────────────────────
  // LOCATION CHECK LOGIC
  //
  // Case 1: City not saved at all → LocationPage (select city)
  // Case 2: City saved + GPS permission granted → ✅ do nothing
  // Case 3: City saved + GPS permission NOT granted → show popup
  // ─────────────────────────────────────────────────────────────
  void _handleLocationCheck() async {
    // FCM token
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('fcm_token');
    if (token == null || token.isEmpty) {
      token = await FirebaseMessaging.instance.getToken();
      await _repo.postFCMToken(token ?? '');
    } else {
      await _repo.postFCMToken(token);
    }

    // Step 1 — city saved hai?
    final savedCity = await LocationStorage.getCity();
    final savedState = await LocationStorage.getState();
    final hasSavedCity =
        savedCity != null &&
        savedCity.isNotEmpty &&
        savedState != null &&
        savedState.isNotEmpty;

    if (!hasSavedCity) {
      // City nahi → LocationPage pe bhejo
      if (mounted) Navigator.pushNamed(context, AppRoutes.locationPage);
      return;
    }

    // Step 2 — city hai, GPS permission check karo
    final hasPermission = await checkLocationPermission();
    if (!hasPermission && mounted) {
      _showLocationPermissionPopup();
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

  // ─────────────────────────────────────────────────────────────
  // PERMISSION POPUP
  // City saved hai but GPS off — gentle reminder, skip allowed
  // ─────────────────────────────────────────────────────────────
  void _showLocationPermissionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 68,
              width: 68,
              decoration: BoxDecoration(
                color: AppColors.button.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: AppColors.button,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Enable Location Access',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Allow location permission for accurate delivery estimates and better experience near you.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary — Enable
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final status = await Permission.location.request();
                  if (status.isPermanentlyDenied && mounted) {
                    await openAppSettings();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Enable Location',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              // Secondary — Skip
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // BACK BUTTON HANDLER
  // ─────────────────────────────────────────────────────────────
  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;

    final currentIndex = ref.read(bottomNavProvider);

    if (currentIndex != 0) {
      ref.read(bottomNavProvider.notifier).state = 0;
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.white,
        elevation: 8,
        titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Text(
                'Exit App',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to leave the app?',
          style: TextStyle(fontSize: 15.5, color: Colors.black87, height: 1.4),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Exit',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (shouldExit == true) {
      ref.read(bottomNavProvider.notifier).state = 0;
      Navigator.of(context).pop();
    }
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookRetualPage(),
    CustomizePoojaKitScreen(),
    const CategoryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavProvider);
    ref.read(userProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        backgroundColor: AppColors.headerCard,
        body: IndexedStack(index: currentIndex, children: _screens),
        bottomNavigationBar: SafeArea(child: _customBottomBar(currentIndex)),
      ),
    );
  }

  Widget _customBottomBar(int currentIndex) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: const BoxDecoration(color: AppColors.background),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
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
