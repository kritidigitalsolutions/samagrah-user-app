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
    required this.festivalType,
    // required this.createdAt,
    // required this.updatedAt,
    // required this.slug,
    // required this.v,
    required this.kitType,
    required this.status,
    required this.category,
    required this.isMostPopularKit,
    required this.isMostUserUse,
    required this.isPanditApproved,
  });

  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final List<Item> items;
  final num? totalPrice;
  final num? kitPrice;
  final num? savings;
  final String? festivalType;
  // final DateTime? createdAt;
  // final DateTime? updatedAt;
  // final String? slug;
  // final int? v;
  final String? kitType;
  final String? status;
  final String? category;
  final bool? isMostPopularKit;
  final bool? isMostUserUse;
  final bool? isPanditApproved;

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
      festivalType: json["festivalType"],
      // createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      // updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      // slug: json["slug"],
      // v: json["__v"],
      kitType: json["kitType"],
      status: json["status"],
      category: json["category"],
      isMostPopularKit: json["isMostPopularKit"],
      isMostUserUse: json["isMostUserUse"],
      isPanditApproved: json["isPanditApproved"],
    );
  }
}

class Item {
  Item({required this.product, required this.quantity, this.id});

  final UserDraftProduct? product;
  final int? quantity;
  final String? id;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      product: json["product"] == null
          ? null
          : UserDraftProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      id: json["_id"],
    );
  }
}

class UserDraftProduct {
  UserDraftProduct({
    required this.category,
    required this.pricing,
    required this.media,
    required this.id,
    required this.title,
    required this.slug,
  });

  final Category? category;
  final Pricing? pricing;
  final Media? media;
  final String? id;
  final String? title;
  final String? slug;

  factory UserDraftProduct.fromJson(Map<String, dynamic> json) {
    return UserDraftProduct(
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
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

class Category {
  Category({required this.name});

  final String? name;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json["name"]);
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
  Pricing({
    required this.price,
    required this.mrp,
    required this.currency,
    required this.basePrice,
    required this.gstAmount,
    required this.gstPercent,
    required this.priceIncludesGst,
  });

  final num? price;
  final num? mrp;
  final String? currency;
  final num? basePrice;
  final num? gstAmount;
  final num? gstPercent;
  final bool? priceIncludesGst;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      price: json["price"],
      mrp: json["mrp"],
      currency: json["currency"],
      basePrice: json["basePrice"],
      gstAmount: json["gstAmount"],
      gstPercent: json["gstPercent"],
      priceIncludesGst: json["priceIncludesGst"],
    );
  }
}
