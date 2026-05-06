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

    required this.slug,
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

  final String? slug;

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

      slug: json["slug"],
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

class UserDraftProduct {
  UserDraftProduct({
    required this.pricing,
    required this.media,
    required this.id,
    required this.title,
    required this.slug,
  });

  final Pricing? pricing;
  final Media? media;
  final String? id;
  final String? title;
  final String? slug;

  factory UserDraftProduct.fromJson(Map<String, dynamic> json) {
    return UserDraftProduct(
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      media: json["media"] == null ? null : Media.fromJson(json["media"]),
      id: json["_id"],
      title: json["title"],
      slug: json["slug"],
    );
  }
}

class Media {
  Media({required this.image});

  final List<String> image;

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      image: json["image"] == null
          ? []
          : List<String>.from(json["image"]!.map((x) => x)),
    );
  }
}

class Pricing {
  Pricing({required this.price, required this.mrp, required this.currency});

  final int? price;
  final int? mrp;
  final String? currency;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      price: json["price"],
      mrp: json["mrp"],
      currency: json["currency"],
    );
  }
}
