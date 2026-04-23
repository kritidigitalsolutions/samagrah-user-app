// lib/view_model/after_login_provider/home_provider/cart_provider.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/repo/product_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier(this._productRepo)
    : super(CartState(items: [], isLoading: true)) {
    _loadCart();
  }

  final ProductRepo _productRepo;
  static const String _cartKey = 'user_cart';
  bool _isSyncing = false;

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, _PendingChange> _pendingSync = {};

  // 🔄 Load cart
  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      try {
        final List decoded = jsonDecode(cartJson);
        final items = decoded.map((e) => CartItem.fromJson(e)).toList();

        state = state.copyWith(items: items);
      } catch (e) {
        state = state.copyWith(items: []);
      }
    }

    await _syncWithServer();

    state = state.copyWith(isLoading: false);
  }

  // 🌐 Sync with server
  Future<void> _syncWithServer() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final response = await _productRepo.getMyCart();

      if (response.success == true && response.data.isNotEmpty) {
        final serverCart = response.data.map((product) {
          return CartItem(
            productId: product.product?.id ?? '',
            title: product.product?.title ?? '',
            thumbnail: product.product?.media?.image.first ?? '',
            price: (product.product?.pricing?.price ?? 0).toDouble(),
            quantity: product.quantity ?? 1,
          );
        }).toList();

        // ✅ FIXED
        state = state.copyWith(items: serverCart);
        await _saveCartLocally();

        print('✅ Synced ${serverCart.length} items from server');
      } else if (response.success == true && response.data.isEmpty) {
        if (state.items.isNotEmpty) {
          // ✅ FIXED
          state = state.copyWith(items: []);
          await _saveCartLocally();

          print('🗑️ Cleared local cart (server empty)');
        }
      }
    } catch (e) {
      print('❌ Cart sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // 💾 Save locally
  Future<void> _saveCartLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(
        state.items.map((item) => item.toJson()).toList(),
      );

      await prefs.setString(_cartKey, cartJson);

      print('💾 Saved ${state.items.length} items');
    } catch (e) {
      print('❌ Save failed: $e');
    }
  }

  // 🕐 Debounce API
  void _debouncedApiSync(String productId, int oldQuantity, int newQuantity) {
    _debounceTimers[productId]?.cancel();

    if (_pendingSync.containsKey(productId)) {
      _pendingSync[productId] = _PendingChange(
        oldQuantity: _pendingSync[productId]!.oldQuantity,
        newQuantity: newQuantity,
      );
    } else {
      _pendingSync[productId] = _PendingChange(
        oldQuantity: oldQuantity,
        newQuantity: newQuantity,
      );
    }

    _debounceTimers[productId] = Timer(
      const Duration(milliseconds: 800),
      () async {
        final change = _pendingSync[productId];
        if (change == null) return;

        _pendingSync.remove(productId);

        final delta = change.newQuantity - change.oldQuantity;

        try {
          if (change.newQuantity == 0) {
            await _productRepo.removeFromCart(
              productId: productId,
              quantity: change.oldQuantity,
            );
          } else if (delta > 0) {
            await _productRepo.addToCart(productId: productId, quantity: delta);
          } else if (delta < 0) {
            await _productRepo.removeFromCart(
              productId: productId,
              quantity: delta.abs(),
            );
          }
        } catch (e) {
          print('⚠️ Sync failed: $e');
        }
      },
    );
  }

  // ➕ Add item
  Future<void> addItem(CartItem item) async {
    final index = state.items.indexWhere((i) => i.productId == item.productId);

    int oldQuantity = 0;

    if (index >= 0) {
      oldQuantity = state.items[index].quantity;

      final updatedItems = [...state.items];
      updatedItems[index] = CartItem(
        productId: updatedItems[index].productId,
        title: updatedItems[index].title,
        thumbnail: updatedItems[index].thumbnail,
        price: updatedItems[index].price,
        quantity: updatedItems[index].quantity + 1,
      );

      state = state.copyWith(items: updatedItems);
    } else {
      oldQuantity = 0;

      // ✅ FIXED (important)
      state = state.copyWith(items: [...state.items, item]);
    }

    await _saveCartLocally();

    final newQuantity = index >= 0 ? state.items[index].quantity : 1;

    _debouncedApiSync(item.productId, oldQuantity, newQuantity);
  }

  // ➕ Increase
  Future<void> increaseQuantity(String productId) async {
    final index = state.items.indexWhere((i) => i.productId == productId);

    if (index >= 0) {
      final oldQuantity = state.items[index].quantity;

      final updatedItems = [...state.items];
      updatedItems[index] = CartItem(
        productId: updatedItems[index].productId,
        title: updatedItems[index].title,
        thumbnail: updatedItems[index].thumbnail,
        price: updatedItems[index].price,
        quantity: updatedItems[index].quantity + 1,
      );

      state = state.copyWith(items: updatedItems);
      await _saveCartLocally();

      _debouncedApiSync(productId, oldQuantity, updatedItems[index].quantity);
    }
  }

  // ➖ Decrease
  Future<void> decreaseQuantity(String productId) async {
    final index = state.items.indexWhere((i) => i.productId == productId);

    if (index >= 0) {
      final oldQuantity = state.items[index].quantity;

      if (oldQuantity > 1) {
        final updatedItems = [...state.items];
        updatedItems[index] = CartItem(
          productId: updatedItems[index].productId,
          title: updatedItems[index].title,
          thumbnail: updatedItems[index].thumbnail,
          price: updatedItems[index].price,
          quantity: updatedItems[index].quantity - 1,
        );

        state = state.copyWith(items: updatedItems);
        await _saveCartLocally();

        _debouncedApiSync(productId, oldQuantity, updatedItems[index].quantity);
      } else {
        await removeItem(productId);
      }
    }
  }

  // ❌ Remove
  Future<void> removeItem(String productId) async {
    _debounceTimers[productId]?.cancel();
    _pendingSync.remove(productId);

    final index = state.items.indexWhere((i) => i.productId == productId);

    final quantityToRemove = index >= 0 ? state.items[index].quantity : 1;

    // ✅ FIXED
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );

    await _saveCartLocally();

    try {
      await _productRepo.removeFromCart(
        productId: productId,
        quantity: quantityToRemove,
      );
    } catch (e) {
      print('⚠️ Remove failed: $e');
    }
  }

  // 🗑️ Clear cart
  Future<void> clearCart() async {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }

    _debounceTimers.clear();
    _pendingSync.clear();

    // ✅ FIXED
    state = state.copyWith(items: []);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  Future<void> deleteCart(String productId) async {
    try {
      // 🛑 stop debounce
      _debounceTimers[productId]?.cancel();
      _pendingSync.remove(productId);

      // 🧠 find item
      final index = state.items.indexWhere((i) => i.productId == productId);
      final quantityToRemove = index >= 0 ? state.items[index].quantity : 1;

      // ✅ UI update instantly
      state = state.copyWith(
        items: state.items.where((i) => i.productId != productId).toList(),
      );

      await _saveCartLocally();

      // 🌐 API call
      await _productRepo.deleteCart(id: productId);

      print("🗑️ Deleted $productId");
    } catch (e) {
      print('⚠️ Delete failed: $e');
    }
  }

  Future<void> refreshCart() async {
    await _syncWithServer();
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
    _pendingSync.clear();
    super.dispose();
  }
}

// ---------------- MODELS ----------------

class _PendingChange {
  final int oldQuantity;
  final int newQuantity;

  _PendingChange({required this.oldQuantity, required this.newQuantity});
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ProductRepo());
});

final cartQuantityProvider = Provider.family<int, String>((ref, productId) {
  final cartState = ref.watch(cartProvider);

  final item = cartState.items
      .where((item) => item.productId == productId)
      .toList();

  if (item.isEmpty) return 0;

  return item.first.quantity;
});

final totalItemsProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold(0, (sum, item) => sum + item.quantity);
});

final totalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.items.fold(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );
});

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

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'title': title,
    'thumbnail': thumbnail,
    'price': price,
    'quantity': quantity,
  };

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

class CartState {
  final List<CartItem> items;
  final bool isLoading;

  CartState({required this.items, required this.isLoading});

  CartState copyWith({List<CartItem>? items, bool? isLoading}) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
