import 'package:samagrah/model/response/kit_response/user_draft_kit_res_model.dart';

class DefaultKitResModel {
  DefaultKitResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<DefaultKitData> data;

  factory DefaultKitResModel.fromJson(Map<String, dynamic> json) {
    return DefaultKitResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<DefaultKitData>.from(
              json["data"]!.map((x) => DefaultKitData.fromJson(x)),
            ),
    );
  }
}

class DefaultKitData {
  DefaultKitData({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.items,
    required this.totalPrice,
    required this.kitPrice,
    required this.savings,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.slug,
    required this.v,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final List<Item> items;
  final int? totalPrice;
  final int? kitPrice;
  final int? savings;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? slug;
  final int? v;

  factory DefaultKitData.fromJson(Map<String, dynamic> json) {
    return DefaultKitData(
      id: json["_id"],
      name: json["name"],
      description: json["description"],
      image: json["image"],
      items: json["items"] == null
          ? []
          : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      totalPrice: json["totalPrice"],
      kitPrice: json["kitPrice"],
      savings: json["savings"],
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      slug: json["slug"],
      v: json["__v"],
    );
  }
}

class Item {
  Item({required this.product, required this.quantity});

  final UserDraftProduct? product;
  final int? quantity;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      product: json["product"] == null
          ? null
          : UserDraftProduct.fromJson(json["product"]),
      quantity: json["quantity"],
    );
  }
}
