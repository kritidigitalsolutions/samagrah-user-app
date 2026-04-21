// lib/view_model/after_login_provider/home_provider/cart_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadCart();
  }

  static const String _cartKey = 'user_cart';

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      final List<dynamic> decoded = jsonDecode(cartJson);
      state = decoded.map((item) => CartItem.fromJson(item)).toList();
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = jsonEncode(state.map((item) => item.toJson()).toList());
    await prefs.setString(_cartKey, cartJson);
  }

  void addItem(CartItem item) {
    final existingIndex = state.indexWhere(
      (i) => i.productId == item.productId,
    );

    if (existingIndex >= 0) {
      state[existingIndex].quantity++;
      state = [...state];
    } else {
      state = [...state, item];
    }
    _saveCart();
  }

  void increaseQuantity(String productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      state[index].quantity++;
      state = [...state];
      _saveCart();
    }
  }

  void decreaseQuantity(String productId) {
    final index = state.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];
      } else {
        state = state.where((i) => i.productId != productId).toList();
      }
      _saveCart();
    }
  }

  Future<void> clearCart() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// ✅ OPTIMIZED: Only rebuilds when THIS specific product's quantity changes
final cartQuantityProvider = Provider.family<int, String>((ref, productId) {
  final cart = ref.watch(cartProvider);
  final item = cart.firstWhere(
    (item) => item.productId == productId,
    orElse: () => CartItem(
      productId: '',
      title: '',
      thumbnail: '',
      price: 0,
      quantity: 0,
    ),
  );
  return item.quantity;
});

// ✅ OPTIMIZED: Only rebuilds bottom bar
final totalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

final totalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});

// lib/model/cart_item.dart
class CartItem {
  final String productId;
  final String title;
  final String thumbnail;
  final double price;
  int quantity;

  CartItem({
    required this.productId,
    required this.title,
    required this.thumbnail,
    required this.price,
    this.quantity = 1,
  });

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'thumbnail': thumbnail,
      'price': price,
      'quantity': quantity,
    };
  }

  // ✅ Create from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
    );
  }
}
