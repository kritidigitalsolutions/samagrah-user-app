import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/kit/customize_kit_req_model.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';
import 'package:samagrah/repo/kit/customize_kit_repo.dart';
import 'package:samagrah/view_model/after_login_provider/customize_kit_providers/state/customizeKit_state.dart';

final selectedPoojaProvider = StateProvider<String?>((ref) => null);

// customize kit

final isFestivalProvider = StateProvider<bool>((ref) => true);

// kit name

final kitNameProvider = StateProvider<String>((ref) => '');

final userDraftKits = AsyncNotifierProvider<UserKitNotifier, CustomizekitState>(
  () => UserKitNotifier(),
);

class UserKitNotifier extends AsyncNotifier<CustomizekitState> {
  final _repo = CustomizeKitRepo();

  @override
  Future<CustomizekitState> build() async {
    final res = await _repo.getMyKit();

    return CustomizekitState(userKit: res);
  }

  // Updated method - Accept CreateKitRequest
  Future<void> createDraftKit(CreateKitRequest request) async {
    final previousState = state.value; // 👈 store old state

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final res = await _repo.createCustoizeKits(request);

      return CustomizekitState(
        userKit: previousState?.userKit, // 👈 preserve old data
        kitId: res["data"]["_id"],
      );
    });
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
