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

  final DefaultProduct? product;
  final int? quantity;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      product: json["product"] == null
          ? null
          : DefaultProduct.fromJson(json["product"]),
      quantity: json["quantity"],
    );
  }
}

class DefaultProduct {
  DefaultProduct({
    required this.pricing,
    required this.media,
    required this.id,
    required this.title,
  });

  final Pricing? pricing;
  final Media? media;
  final String? id;
  final String? title;

  factory DefaultProduct.fromJson(Map<String, dynamic> json) {
    return DefaultProduct(
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      media: json["media"] == null ? null : Media.fromJson(json["media"]),
      id: json["_id"],
      title: json["title"],
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
