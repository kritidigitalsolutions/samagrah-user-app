import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/repo/customize_kit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/state/customizeKit_state.dart';

final selectedPoojaProvider = StateProvider<String?>((ref) => null);

// ========================== loader ===============================

final defaultKitLoaderPro = StateProvider<bool>((ref) => false);

// customize kit

class CustomizeKitNotifier extends Notifier<List<Item>> {
  late List<Item> originalItems;

  @override
  List<Item> build() {
    return []; // initial empty, will be set when screen loads
  }

  void initializeFromDefault(DefaultKitData kit) {
    originalItems = kit.items
        .map((item) => Item(product: item.product, quantity: item.quantity))
        .toList();

    state = [...originalItems];
  }

  void updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1 || index < 0 || index >= state.length) return;

    final updated = List<Item>.from(state);
    updated[index] = Item(
      product: updated[index].product,
      quantity: newQuantity,
    );
    state = updated;
  }

  void deleteItem(int index) {
    if (index < 0 || index >= state.length) return;
    final updated = List<Item>.from(state)..removeAt(index);
    state = updated;
  }

  void addItem(UserDraftProduct product, {int quantity = 1}) {
    final updated = List<Item>.from(state);
    // Check if item already exists
    final existingIndex = updated.indexWhere(
      (item) => item.product?.id == product.id,
    );

    if (existingIndex != -1) {
      // Increase quantity if already added
      final existingQty = updated[existingIndex].quantity ?? 1;
      updated[existingIndex] = Item(
        product: product,
        quantity: existingQty + quantity,
      );
    } else {
      updated.add(Item(product: product, quantity: quantity));
    }
    state = updated;
  }

  void resetToDefault() {
    state = originalItems
        .map((item) => Item(product: item.product, quantity: item.quantity))
        .toList();
  }

  void applyItems(List<Item> items) {
    state = items
        .map((e) => Item(product: e.product, quantity: e.quantity))
        .toList();
  }

  // Helper getters
  num get totalPrice => state.fold(0, (sum, item) {
    final price = item.product?.pricing?.price ?? 0;
    return sum + (price * (item.quantity ?? 1));
  });

  num get originalTotalPrice => originalItems.fold(0, (sum, item) {
    final price = item.product?.pricing?.price ?? 0;
    return sum + (price * (item.quantity ?? 1));
  });

  num get savings => originalTotalPrice - totalPrice;

  // check in customize or not

  bool get isCustomized {
    if (state.length != originalItems.length) return true;

    for (int i = 0; i < state.length; i++) {
      final current = state[i];
      final original = originalItems[i];

      if (current.product?.id != original.product?.id ||
          (current.quantity ?? 1) != (original.quantity ?? 1)) {
        return true;
      }
    }

    return false;
  }
}

// Provider
final customizeKitProvider = NotifierProvider<CustomizeKitNotifier, List<Item>>(
  () => CustomizeKitNotifier(),
);

//final isFestivalProvider = StateProvider<bool>((ref) => true);

// kit name

final kitNameProvider = StateProvider<String>((ref) => '');
final searchQueryProvider = StateProvider<String>((ref) => '');

//========================== kit history =========================================

final userDraftKits = AsyncNotifierProvider<UserKitNotifier, CustomizekitState>(
  () => UserKitNotifier(),
);

class UserKitNotifier extends AsyncNotifier<CustomizekitState> {
  final _repo = CustomizeKitRepo();

  @override
  Future<CustomizekitState> build() async {
    final defaultKitRes = await _repo.defaultKit();

    return CustomizekitState(defaultKit: defaultKitRes);
  }
}

// add to cart

class CustomizeKitCartNotifier extends StateNotifier<Map<String, int>> {
  CustomizeKitCartNotifier() : super({});

  // Add one item or increase quantity
  void addItem(Product product) {
    final currentQty = state[product.id] ?? 0;
    state = {...state, product.id ?? '': currentQty + 1};
  }

  // Remove one item or decrease quantity
  void removeItem(String productId) {
    final currentQty = state[productId] ?? 0;
    if (currentQty <= 1) {
      // Remove completely if quantity becomes 0
      final newState = Map<String, int>.from(state);
      newState.remove(productId);
      state = newState;
    } else {
      state = {...state, productId: currentQty - 1};
    }
  }

  void removeProduct(String productId) {
    final newState = Map<String, int>.from(state);
    newState.remove(productId);
    state = newState;
  }

  // Clear all items (optional)
  void clearCart() {
    state = {};
  }

  // Get total items count
  int get totalItems => state.values.fold(0, (sum, qty) => sum + qty);

  // Get selected products with quantity (useful for next page)
  Map<String, int> get selectedItems => state;
}

// Provider
final customizeKitCartProvider =
    StateNotifierProvider<CustomizeKitCartNotifier, Map<String, int>>(
      (ref) => CustomizeKitCartNotifier(),
    );
