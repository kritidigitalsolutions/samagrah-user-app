import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:samagrah/model/response/wallet_res/wallet_res_model.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_snackbar.dart';
import 'package:samagrah/utils/service/helper_methods.dart';
import 'package:samagrah/utils/textstyle.dart';
import 'package:samagrah/view_model/after_login_provider/wallet_provider/wallet_provider.dart';

class MyWalletScreen extends ConsumerWidget {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final offerAsync = ref.watch(offerProvider);
    final walletAsync = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Wallet',
        subtitle: "Manage your balance & offers",

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: AppColors.warningLight.withAlpha(50),
              radius: 25,
              child: Center(
                child: Image.asset(
                  "assets/icon/purse.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.button,
        onRefresh: () async {
          ref.invalidate(walletProvider);
          //  ref.invalidate(offerProvider);
          await ref.read(walletProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Balance Card ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _BalanceCard(walletAsync: walletAsync),
              ),

              const SizedBox(height: 12),

              // ── Stats Row ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _StatsRow(walletAsync: walletAsync),
              ),

              // ── Offers ─────────────────────────────────────────────────
              _SectionHeader(
                title: 'Exclusive Offers',
                actionLabel: 'View all',
                onAction: () {},
              ),

              // offerAsync.when(
              //   loading: () => const _ShimmerBox(height: 140),
              //   error: (_, _) =>
              //       _ErrorText(message: "Offers load nahi ho paye"),
              //   data: (data) {
              //     final offers = data.data?.offers ?? [];
              //     if (offers.isEmpty) {
              //       return _EmptyText(message: "Koi offer nahi mila");
              //     }
              //     return SizedBox(
              //       height: 148,
              //       child: ListView.builder(
              //         scrollDirection: Axis.horizontal,
              //         padding: const EdgeInsets.symmetric(horizontal: 16),
              //         itemCount: offers.length,
              //         itemBuilder: (_, i) => _OfferCard(offer: offers[i]),
              //       ),
              //     );
              //   },
              //  ),

              // ── Activity ───────────────────────────────────────────────
              _SectionHeader(
                title: 'Wallet Activity',
                actionLabel: 'See all',
                onAction: () {},
              ),

              walletAsync.when(
                loading: () => const _ShimmerBox(height: 200),
                error: (_, _) =>
                    _ErrorText(message: "Transactions load nahi ho paye"),
                data: (walletData) {
                  final transactions = walletData.data?.transactions ?? [];
                  if (transactions.isEmpty) {
                    return _EmptyText(message: "Koi transaction nahi mila");
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length,
                    itemBuilder: (_, i) {
                      final tx = transactions[i];
                      final isCredit = tx.type?.toLowerCase() == "credit";
                      final date = tx.updatedAt != null
                          ? DateFormat('dd MMM yyyy').format(tx.updatedAt!)
                          : "—";
                      return _TransactionItem(
                        title: tx.source ?? "Wallet Transaction",
                        date: date,
                        amount: "${isCredit ? '+' : '-'}₹${tx.amount ?? 0}",
                        isCredit: isCredit,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Balance Card ─────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final AsyncValue walletAsync;
  const _BalanceCard({required this.walletAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.button, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Decorative blob top-right
          Positioned(
            top: -35,
            right: -35,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.button.withOpacity(0.12),
              ),
            ),
          ),
          // Decorative blob bottom-left
          Positioned(
            bottom: -25,
            left: 10,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AVAILABLE BALANCE',
                      style: text10(
                        color: AppColors.grey300,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Text(
                        'WALLET',
                        style: text10(
                          color: AppColors.grey300,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Amount
                walletAsync.when(
                  data: (data) {
                    final amount = data.data?.wallet?.balance ?? 0;
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '₹',
                            style: text20(color: AppColors.warningLight),
                          ),
                          TextSpan(
                            text: amount.toString(),
                            style: text30(color: AppColors.white),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox(
                    height: 42,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => Text(
                    "Error loading balance",
                    style: text13(color: AppColors.error),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Last updated: Today',
                  style: text11(color: AppColors.grey300),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(
                        label: '+ Add Money',
                        onTap: () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const AddMoneyBottomSheet(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _RoundIconButton(icon: Icons.arrow_upward_rounded),
                    const SizedBox(width: 8),
                    _RoundIconButton(icon: Icons.history_rounded),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.warning,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: text13(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  const _RoundIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Icon(icon, color: AppColors.grey300, size: 18),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AsyncValue<WalletResModel> walletAsync;

  const _StatsRow({required this.walletAsync});

  @override
  Widget build(BuildContext context) {
    return walletAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const SizedBox(),
      data: (walletData) {
        final transactions = walletData.data?.transactions ?? [];

        int credited = 0;
        int spent = 0;
        int cashback = 0;

        for (final tx in transactions) {
          final amount = tx.amount ?? 0;
          final type = tx.type?.toLowerCase() ?? "";
          final source = tx.source?.toLowerCase() ?? "";

          if (type == "credit") {
            credited += amount;
          } else if (type == "debit") {
            spent += amount;
          }

          if (source == "cashback") {
            cashback += amount;
          }
        }

        return Row(
          children: [
            _StatCard(
              label: 'Credited',
              value: '+₹$credited',
              color: AppColors.success,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Spent',
              value: '-₹$spent',
              color: AppColors.error,
            ),
            const SizedBox(width: 10),
            _StatCard(
              label: 'Cashback',
              value: '₹$cashback',
              color: AppColors.warning,
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey200, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: text10(color: AppColors.grey400)),
            const SizedBox(height: 4),
            Text(
              value,
              style: text14(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: text15(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel, style: text12(color: AppColors.button)),
          ),
        ],
      ),
    );
  }
}

// ─── Offer Card ───────────────────────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final dynamic offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.button],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.button.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              '🎉 Exclusive',
              style: text10(
                color: AppColors.warningLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (offer.value != null)
            Text(
              'Get ₹${offer.value} Back',
              style: text16(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            offer.title ?? 'Special Offer',
            style: text12(color: AppColors.grey300),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            offer.description ?? '',
            style: text10(color: AppColors.grey400),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Item ─────────────────────────────────────────────────────────
class _TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool isCredit;
  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  capitalizeWords(title),
                  style: text13(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(date, style: text11(color: AppColors.grey400)),
              ],
            ),
          ),
          Text(
            amount,
            style: text14(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  final double height;
  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.button,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;
  const _ErrorText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(message, style: text13(color: AppColors.error)),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String message;
  const _EmptyText({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(message, style: text13(color: AppColors.grey400)),
      ),
    );
  }
}

// ─── Add Money Bottom Sheet ───────────────────────────────────────────────────
class AddMoneyBottomSheet extends ConsumerStatefulWidget {
  const AddMoneyBottomSheet({super.key});

  @override
  ConsumerState<AddMoneyBottomSheet> createState() =>
      _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends ConsumerState<AddMoneyBottomSheet> {
  final controller = TextEditingController();
  final quickAmounts = [100, 200, 500, 1000];

  Future<void> _pay() async {
    final amount = int.tryParse(controller.text.trim()) ?? 0;
    if (amount <= 0) {
      AppSnackbar.show(
        context,
        message: "Valid amount daalo",
        type: SnackBarType.warning,
      );
      return;
    }
    ref.read(addMoneyLoadingProvider.notifier).state = true;
    try {
      final success = await ref.read(razorpayProvider).openCheckout(amount);
      if (success) {
        ref.invalidate(walletProvider);
        await ref.read(walletProvider.future);
        if (mounted) {
          Navigator.pop(context);
          AppSnackbar.show(
            context,
            message: "Paisa add ho gaya!",
            type: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      AppSnackbar.show(
        context,
        message: e.toString(),
        type: SnackBarType.error,
      );
    } finally {
      ref.read(addMoneyLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addMoneyLoadingProvider);
    final selectedAmount = ref.watch(selectedAmountProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 22),

          Text('Add Money', style: text18(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Wallet mein paisa add karo',
            style: text12(color: AppColors.grey400),
          ),
          const SizedBox(height: 24),

          // Quick amount chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: quickAmounts.map((amount) {
              final isSelected = selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  controller.text = amount.toString();
                  ref.read(selectedAmountProvider.notifier).state = amount;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.button : AppColors.grey100,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.button : AppColors.grey200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '₹$amount',
                    style: text13(
                      color: isSelected ? AppColors.white : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Amount TextField
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: text16(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
            onChanged: (_) =>
                ref.read(selectedAmountProvider.notifier).state = null,
            decoration: InputDecoration(
              hintText: 'Amount enter karo',
              prefixText: '₹  ',
              prefixStyle: text16(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
              hintStyle: text14(color: AppColors.grey300),
              filled: true,
              fillColor: AppColors.grey50,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.button,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // Pay button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading
                    ? AppColors.grey200
                    : AppColors.button,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: isLoading ? null : _pay,
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Proceed to Pay',
                      style: text15(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
