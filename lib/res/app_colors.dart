import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // prevent instantiation

  // ══════════════════════════════════════════════
  //  PRIMARY BRAND COLORS
  // ══════════════════════════════════════════════

  static const Color primary = Color(0xFF31181E);
  static const Color primaryLight = Color(0xFF5A3A40);

  // ══════════════════════════════════════════════
  //  Button colors
  // ══════════════════════════════════════════════

  static const Color button = Color(0xFFCA1F48);

  static const Color headerCard = Color(0xFFF3EFE6);

  static const Color yellow = Colors.yellow;

  // ══════════════════════════════════════════════
  //  NEUTRAL / GREY SCALE
  // ══════════════════════════════════════════════

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color black26 = Colors.black26;
  static const Color black54 = Colors.black54;
  static const Color black87 = Colors.black87;

  static const Color grey = Colors.grey;
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // ══════════════════════════════════════════════
  //  SEMANTIC — SUCCESS
  // ══════════════════════════════════════════════

  static const Color success = Color(0xFF10B981);
  static const Color green = Color(0xFF4CAF50);

  // ══════════════════════════════════════════════
  //  SEMANTIC — ERROR
  // ══════════════════════════════════════════════

  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  // ══════════════════════════════════════════════
  //  SEMANTIC — WARNING
  // ══════════════════════════════════════════════

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);
  static const Color warningLighter = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  // ══════════════════════════════════════════════
  //  SEMANTIC — INFO
  // ══════════════════════════════════════════════

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF93C5FD);

  // ══════════════════════════════════════════════
  //  BACKGROUND COLORS
  // ══════════════════════════════════════════════

  static const Color background = Color(0xFFF6F6F6);

  // ══════════════════════════════════════════════
  //  TEXT COLORS
  // ══════════════════════════════════════════════

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);

  // ══════════════════════════════════════════════
  //  BORDER / DIVIDER COLORS
  // ══════════════════════════════════════════════

  static const Color divider = Color(0xFFF3F4F6);
  static const Color dividerDark = Color(0xFF374151);

  // ══════════════════════════════════════════════
  //  GRADIENT PRESETS
  // ══════════════════════════════════════════════

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [grey900, grey700],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
