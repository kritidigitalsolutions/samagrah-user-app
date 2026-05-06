// // ================ create customize kit ==========================

// class CreateKitRequest {
//   final String name;
//   final String? baseKit;
//   final List<KitItem> items;

//   CreateKitRequest({required this.name, this.baseKit, required this.items});

//   /// 🔹 Convert to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       "name": name,
//       "baseKit": baseKit,
//       "items": items.map((e) => e.toJson()).toList(),
//     };
//   }
// }

// class KitItem {
//   final String productId;
//   final int quantity;

//   KitItem({required this.productId, required this.quantity});

//   Map<String, dynamic> toJson() {
//     return {"productId": productId, "quantity": quantity};
//   }
// }
