import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';
import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/repo/kit/customize_kit_repo.dart';
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

  void initializeFromUser(UserKitData kit) {
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

  // Helper getters
  int get totalPrice => state.fold(0, (sum, item) {
    final price = item.product?.pricing?.price ?? 0;
    return sum + (price * (item.quantity ?? 1));
  });

  int get originalTotalPrice => originalItems.fold(0, (sum, item) {
    final price = item.product?.pricing?.price ?? 0;
    return sum + (price * (item.quantity ?? 1));
  });

  int get savings => originalTotalPrice - totalPrice;

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

final isFestivalProvider = StateProvider<bool>((ref) => true);

// kit name

final kitNameProvider = StateProvider<String>((ref) => '');

//========================== kit history =========================================

final userDraftKits = AsyncNotifierProvider<UserKitNotifier, CustomizekitState>(
  () => UserKitNotifier(),
);

class UserKitNotifier extends AsyncNotifier<CustomizekitState> {
  final _repo = CustomizeKitRepo();

  @override
  Future<CustomizekitState> build() async {
    final res = await _repo.getMyKit();
    final defaultKitRes = await _repo.defaultKit();

    return CustomizekitState(userKit: res, defaultKit: defaultKitRes);
  }

  // referash my kit

  Future<void> refreshUserKit() async {
    final previousState = state.value;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final res = await _repo.getMyKit(); // 👈 only this API
      return CustomizekitState(
        userKit: res,
        defaultKit: previousState?.defaultKit, // 👈 preserve old
      );
    });
  }

  // Updated method - Accept CreateKitRequest
  Future<UserKitData?> createDraftKit(CreateKitRequest request) async {
    final previousState = state.value;

    state = const AsyncLoading();

    try {
      final res = await _repo.createCustoizeKits(request);

      // ✅ Extract actual kit
      final createdKit = res.data;

      // Refresh list
      final userKitRes = await _repo.getMyKit();

      state = AsyncData(
        CustomizekitState(
          userKit: userKitRes,
          defaultKit: previousState?.defaultKit,
        ),
      );

      return createdKit; // ✅ RETURN THIS
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> deleteMyKit(String id) async {
    final previousState = state.value;
    if (previousState == null) return;

    try {
      // ✅ Safe list handling
      final updatedList = (previousState.userKit?.data ?? [])
          .where((kit) => kit.id != id)
          .toList();

      // ✅ Preserve old fields
      final updatedUserKit = UserDraftKitResModel(
        data: updatedList,
        success: previousState.userKit?.success,
        count: updatedList.length, // 👈 optional better update
      );

      // ✅ Update UI instantly
      state = AsyncData(
        CustomizekitState(
          userKit: updatedUserKit,
          defaultKit: previousState.defaultKit,
        ),
      );

      // ✅ API call
      await _repo.deleteMyKit(id);
    } catch (e, st) {
      // ❌ rollback
      state = AsyncError(e, st);
      state = AsyncData(previousState);
    }
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
