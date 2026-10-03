// lib/utils/auth_guard.dart
//
// Reusable authentication guard for Apple Guideline 5.1.1(v) compliance.
//
// Usage:
//   AuthGuard.run(context, onAuthed: () => doAccountAction());
//
// For async context:
//   if (await AuthGuard.isLoggedIn()) { ... }

import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';

class AuthGuard {
  // ─── Token check ────────────────────────────────────────────────────────────

  /// Returns true when a valid (non-empty) auth token is stored locally.
  /// Does NOT make any network request.
  static Future<bool> isLoggedIn() async {
    final token = await AuthLocalstorageService.getToken();
    return token != null && token.trim().isNotEmpty;
  }

  /// Returns true when user is browsing as a guest (no token, but guest mode enabled).
  static Future<bool> isGuest() async {
    final loggedIn = await isLoggedIn();
    if (loggedIn) return false;
    return await AuthLocalstorageService.isGuestMode();
  }

  /// Enables guest mode and navigates directly to the home/browse screen.
  static Future<void> continueAsGuest(BuildContext context) async {
    final navigator = Navigator.of(context);
    await AuthLocalstorageService.setGuestMode(true);
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  // ─── Inline guard ────────────────────────────────────────────────────────────

  /// Runs [onAuthed] if the user is logged in.
  /// Otherwise shows the "Sign In Required" bottom sheet.
  ///
  /// [context]   — current BuildContext
  /// [onAuthed]  — callback to execute when authenticated
  /// [message]   — optional custom message shown in the bottom sheet
  static Future<void> run(
    BuildContext context, {
    required VoidCallback onAuthed,
    String? message,
  }) async {
    final loggedIn = await isLoggedIn();
    if (!context.mounted) return;

    if (loggedIn) {
      onAuthed();
    } else {
      _showSignInSheet(context, message: message);
    }
  }

  // ─── Bottom sheet ────────────────────────────────────────────────────────────

  static void _showSignInSheet(BuildContext context, {String? message}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SignInRequiredSheet(message: message),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign-In Required Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SignInRequiredSheet extends StatelessWidget {
  final String? message;
  const _SignInRequiredSheet({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Icon ─────────────────────────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.button.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_person_rounded,
              color: AppColors.button,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),

          // ── Title ─────────────────────────────────────────────────────────
          const Text(
            'Sign In Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // ── Message ───────────────────────────────────────────────────────
          Text(
            message ??
                'Please sign in or create an account to continue with this action.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Sign In button ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.loginPage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.button,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── Create Account button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.register);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.button,
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.button),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Create Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // ── Continue browsing ─────────────────────────────────────────────
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue Browsing',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
