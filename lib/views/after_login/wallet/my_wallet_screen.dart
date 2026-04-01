import 'package:flutter/material.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/textstyle.dart';

class MyWalletScreen extends StatelessWidget {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'My Wallet',
        subtitle: "Manage your refunds, cashback, and exclusive offers",

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],

                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available\nBalance',
                    style: text24(color: AppColors.grey300),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(width: 1, color: AppColors.grey50),
                        ),
                        child: Text(
                          'AMOUNT',
                          style: text12(
                            color: AppColors.grey300,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '₹ 120',
                        style: text24(
                          color: AppColors.warning,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Cashback Offers Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCashbackCard(
                  'Get ₹50 cashback',
                  'on your next pooja booking',
                ),
                _buildCashbackCard(
                  'Get ₹50 cashback',
                  'on your next pooja booking',
                ),
                _buildCashbackCard(
                  'Get ₹50 cashback',
                  'on your next pooja booking',
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Wallet Activity Section
            Row(
              children: [
                Icon(Icons.account_balance_wallet, color: AppColors.button),
                SizedBox(width: 8),
                Text(
                  'Wallet Activity',
                  style: text18(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Activity List
            _buildActivityItem(
              'Refund Credited',
              'For cancelled order #45821',
              '+ ₹50',
            ),
            _buildActivityItem(
              'Cashback Received',
              'On Oiwali Special Kit purchase',
              '+ ₹3',
            ),
            _buildActivityItem(
              'Cashback Received',
              'On Oiwali Special Kit purchase',
              '+ ₹3',
            ),
            _buildActivityItem(
              'Cashback Received',
              'On Oiwali Special Kit purchase',
              '+ ₹3',
            ),
            _buildActivityItem(
              'Cashback Received',
              'On Oiwali Special Kit purchase',
              '+ ₹3',
            ),
            _buildActivityItem(
              'Cashback Received',
              'On Oiwali Special Kit purchase',
              '+ ₹3',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashbackCard(String title, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.button, AppColors.primary],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Exclusive Offer🎉",
                  style: text8(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text15(
                    fontWeight: FontWeight.bold,
                    color: AppColors.button,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: text13(color: AppColors.grey400)),
              ],
            ),
          ),
          Text(
            amount,
            style: text16(color: AppColors.button, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
