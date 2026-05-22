import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/localStogare_service/auth_localStorage_service.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/account_provider.dart';
import 'package:samagrah/view_model/after_login_provider/home_provider/cart_provider.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  bool _isConfirmChecked = false;
  String? _selectedReason;

  final List<String> _deleteReasons = [
    "I'm not using the app anymore",
    "I have privacy concerns",
    "I found a better alternative",
    "Too many notifications",
    "Technical issues",
    "Other",
  ];

  void _showDeleteConfirmationDialog() {
    if (_selectedReason == null) {
      AppSnackbar.show(
        context,
        message: "Please select why you want to delete your account",
        type: SnackBarType.warning,
      );
      return;
    }

    if (!_isConfirmChecked) {
      AppSnackbar.show(
        context,
        message: "Please confirm that you understand this action is permanent",
        type: SnackBarType.warning,
      );

      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Icon
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.warning_rounded,
                        color: AppColors.error,
                        size: 35,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Final Confirmation",
                      style: text20(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "Are you absolutely sure? This will permanently delete your account and all associated data. This action cannot be undone.",
                      style: text14(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: AppOutlineButton(
                            onTap: () => Navigator.pop(context),
                            title: "Cancel",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            title: "Delete",
                            onTap: () {
                              Navigator.pop(context); // close dialog
                              _deleteAccount();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    // ✅ Dialog pehle band karo (caller mein already ho raha hai)
    // Yahan se Navigator.pop(context) HATAO

    if (!mounted) return; // ✅ safety check

    try {
      final isDeleted = await ref
          .read(deleteAccountProvider.notifier)
          .deleteAccount(_selectedReason!);

      if (!mounted) return; // ✅ await ke baad check karo

      if (isDeleted) {
        ref.read(cartProvider.notifier).clearCart();
        await AuthLocalstorageService.clear();

        if (!mounted) return; // ✅ async ke baad phir check

        AppSnackbar.show(
          context,
          message: "Your account has been permanently deleted",
          type: SnackBarType.success,
        );

        Navigator.pushReplacementNamed(context, AppRoutes.register);
      } else {
        AppSnackbar.show(
          context,
          message: "Failed to delete account",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return; // ✅

      AppSnackbar.show(
        context,
        message: "Failed to delete account",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Delete Account"),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Warning Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.error.withOpacity(0.3),
                        AppColors.error.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Warning Title
              Text(
                "We're sorry to see you go!",
                style: text24(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "Before you delete your account, please note:",
                style: text16(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // Warning Points
              _buildWarningPoint(
                icon: Icons.cancel_rounded,
                text: "All your data will be permanently deleted",
              ),
              _buildWarningPoint(
                icon: Icons.history_rounded,
                text: "Your activity history will be lost",
              ),
              _buildWarningPoint(
                icon: Icons.block_rounded,
                text: "This action cannot be undone",
              ),
              _buildWarningPoint(
                icon: Icons.people_rounded,
                text: "You'll lose access to all communities",
              ),

              const SizedBox(height: 32),

              // Reason Selection
              Text(
                "Why are you leaving?",
                style: text18(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              ..._deleteReasons.map((reason) {
                return _buildReasonOption(reason);
              }),

              const SizedBox(height: 32),

              // Confirmation Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isConfirmChecked = !_isConfirmChecked;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _isConfirmChecked
                              ? AppColors.error
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.error, width: 2),
                        ),
                        child: _isConfirmChecked
                            ? const Icon(
                                Icons.check,
                                color: AppColors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "I understand this is permanent and cannot be reversed",
                          style: text14(
                            color: AppColors.button,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Delete Button
              AppButton(
                title: "Delete My Account",
                isLoading: ref.watch(deleteAccountProvider).isLoading,
                onTap: _showDeleteConfirmationDialog,
                color: AppColors.error,
              ),

              const SizedBox(height: 16),

              // Cancel Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Text(
                    "Cancel",
                    style: text16(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningPoint({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: text14(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedReason = reason;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.button.withOpacity(0.2)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.button
                : AppColors.black.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.button : AppColors.white,
                border: Border.all(
                  color: isSelected ? AppColors.button : AppColors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason,
                style: text14(
                  color: isSelected
                      ? AppColors.button
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
