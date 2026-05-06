


// class UserKitItems {
//   UserKitItems({
//     required this.product,
//     required this.quantity,
//     required this.priceAtTime,
//     required this.id,
//   });

//   final UserDraftProduct? product;
//   final int? quantity;
//   final int? priceAtTime;
//   final String? id;

//   factory UserKitItems.fromJson(Map<String, dynamic> json) {
//     return UserKitItems(
//       product: json["product"] == null
//           ? null
//           : UserDraftProduct.fromJson(json["product"]),
//       quantity: json["quantity"],
//       priceAtTime: json["priceAtTime"],
//       id: json["_id"],
//     );
//   }
// }


// // ============== User current kit ============================

// class UserKitResModel {
//   UserKitResModel({
//     required this.success,
//     required this.msg,
//     required this.data,
//   });

//   final bool? success;
//   final String? msg;
//   final UserKitData? data;

//   factory UserKitResModel.fromJson(Map<String, dynamic> json) {
//     return UserKitResModel(
//       success: json["success"],
//       msg: json["message"],
//       data: json["data"] == null ? null : UserKitData.fromJson(json["data"]),
//     );
//   }
// }
