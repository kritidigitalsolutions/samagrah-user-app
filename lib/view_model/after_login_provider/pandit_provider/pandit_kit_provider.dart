import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/views/after_login/pandit/pandit_recommended_kit_pages/pandit_rec_kit_selection.dart';

class ProductNotifier extends StateNotifier<Map<String, CartItem>> {
  ProductNotifier() : super({});

  /// ADD PRODUCT
  void addProduct(Product product) {
    if (state.containsKey(product.name)) {
      final existing = state[product.name]!;
      state = {
        ...state,
        product.name: existing.copyWith(quantity: existing.quantity + 1),
      };
    } else {
      state = {...state, product.name: CartItem(product: product, quantity: 1)};
    }
  }

  /// REMOVE PRODUCT
  void removeProduct(Product product) {
    if (!state.containsKey(product.name)) return;

    final existing = state[product.name]!;

    if (existing.quantity == 1) {
      final newState = {...state};
      newState.remove(product.name);
      state = newState;
    } else {
      state = {
        ...state,
        product.name: existing.copyWith(quantity: existing.quantity - 1),
      };
    }
  }

  /// CHECK SELECTED
  bool isSelected(Product product) {
    return state.containsKey(product.name);
  }

  /// GET QUANTITY
  int getQuantity(Product product) {
    return state[product.name]?.quantity ?? 0;
  }
}

final productProvider =
    StateNotifierProvider<ProductNotifier, Map<String, CartItem>>(
      (ref) => ProductNotifier(),
    );

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) {
    return CartItem(product: product, quantity: quantity ?? this.quantity);
  }
}
