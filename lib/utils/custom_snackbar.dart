import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackbar {
  static void show(
    BuildContext context, {
    required String message,

    // 🔹 Optional Customization
    SnackBarType type = SnackBarType.info,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(14)),
    double elevation = 6,
    Widget? action,
    bool showIcon = true,
  }) {
    final config = _getDefaultConfig(type);

    final bgColor = backgroundColor ?? config.color;
    final txtColor = textColor ?? Colors.white;
    final icn = icon ?? config.icon;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: elevation,
        behavior: behavior,
        backgroundColor: Colors.transparent, // 👈 for custom container
        duration: duration,

        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: bgColor, borderRadius: borderRadius),
          child: Row(
            children: [
              if (showIcon) ...[
                Icon(icn, color: txtColor, size: 20),
                const SizedBox(width: 10),
              ],

              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: txtColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              if (action != null) ...[const SizedBox(width: 10), action],
            ],
          ),
        ),
        margin: margin,
      ),
    );
  }

  // 🔹 Default configs
  static _SnackBarConfig _getDefaultConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          color: const Color(0xFF2ECC71),
          icon: Icons.check_circle_rounded,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          color: const Color(0xFFE74C3C),
          icon: Icons.error_rounded,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          color: const Color(0xFFF39C12),
          icon: Icons.warning_rounded,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          color: const Color(0xFF3498DB),
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({required this.color, required this.icon});
}
