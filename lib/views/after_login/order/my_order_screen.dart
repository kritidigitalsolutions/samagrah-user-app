import 'package:flutter/material.dart';
import 'package:samagrah/main.dart';
import 'package:samagrah/res/app_colors.dart';
import 'package:samagrah/routes/app_routes.dart';
import 'package:samagrah/utils/components.dart';
import 'package:samagrah/utils/custom_button.dart';
import 'package:samagrah/utils/textstyle.dart';

class OrderItem {
  final String name;
  final String emoji;
  final String pack;

  OrderItem({required this.name, required this.emoji, required this.pack});
}

class Order {
  final int id;
  final String orderNumber;
  final List<OrderItem> items;
  final String status;
  final Color statusColor;
  final String date;
  final String total;

  Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.total,
  });
}

// My Orders Page
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  List<Order> getOrders() {
    return [
      Order(
        id: 1,
        orderNumber: '#79',
        items: [OrderItem(name: 'Clay Diyas', emoji: '🪔', pack: 'Pack of 10')],
        status: 'Out for Delivery',
        statusColor: Colors.blue,
        date: 'August 31, 2025, 21:21',
        total: '₹79',
      ),
      Order(
        id: 2,
        orderNumber: '#79',
        items: [OrderItem(name: 'Clay Diyas', emoji: '🪔', pack: 'Pack of 10')],
        status: 'Preparing',
        statusColor: Colors.orange,
        date: 'August 31, 2025',
        total: '₹79',
      ),
      Order(
        id: 3,
        orderNumber: '#79',
        items: [OrderItem(name: 'Clay Diyas', emoji: '🪔', pack: 'Pack of 10')],
        status: 'Delivered',
        statusColor: Colors.green,
        date: 'Track to Delivery',
        total: '₹79',
      ),
      Order(
        id: 4,
        orderNumber: '#79',
        items: [
          OrderItem(name: 'Clay Diyas', emoji: '🪔', pack: 'Pack of 10'),
          OrderItem(name: 'Peanut Chikki', emoji: '🥜', pack: 'Pack'),
          OrderItem(name: 'Kalonji', emoji: '⚪', pack: ''),
          OrderItem(name: 'Clay Diyas', emoji: '🪔', pack: 'Pack of 10'),
          OrderItem(name: 'Peanut Chikki', emoji: '🥜', pack: 'Pack'),
        ],
        status: 'Delivered',
        statusColor: Colors.green,
        date: 'Track to Delivery',
        total: '₹79',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final orders = getOrders();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: "My Order"),
      body: SafeArea(
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                return OrderCard(
                  order: orders[index],
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const TrackOrderPage(),
                    //   ),
                    // );
                  },
                );
              },
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: CustomElevatedIconButton(
                  text: "Back to Home",
                  icon: Icons.home,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyHomeScreen(index: 0)),
                      (route) => false, // removes all previous routes
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Order Card Widget
class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMultiItem = order.items.length > 1;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (!isMultiItem)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                order.items[0].emoji,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.items[0].name,
                                style: text16(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                order.items[0].pack,
                                style: text14(color: AppColors.grey600),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.orderDetails,
                                  );
                                },
                                child: Text(
                                  "View Details",
                                  style: text13(color: AppColors.button),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        order.orderNumber,
                        style: text20(
                          fontWeight: FontWeight.bold,
                          color: AppColors.button,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.7,
                            ),
                        itemCount: order.items.length > 4
                            ? 4
                            : order.items.length,
                        itemBuilder: (context, index) {
                          final item = order.items[index];
                          return Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    item.emoji,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.pack,
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (order.items.length > 4) ...[
                        const SizedBox(height: 10),
                        AppButton(
                          title: "View Details",
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.orderDetails,
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.button,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 5,
            child: Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: order.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.status,
                    style: text14(
                      color: order.statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
