class UserDraftKitResModel {
  UserDraftKitResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<Datum> data;

  factory UserDraftKitResModel.fromJson(Map<String, dynamic> json) {
    return UserDraftKitResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
    required this.id,
    required this.user,
    required this.name,
    required this.baseKit,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? user;
  final String? name;
  final dynamic baseKit;
  final List<Item> items;
  final int? totalPrice;
  final String? status;
  final String? paymentStatus;
  final dynamic order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["_id"],
      user: json["user"],
      name: json["name"],
      baseKit: json["baseKit"],
      items: json["items"] == null
          ? []
          : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
      totalPrice: json["totalPrice"],
      status: json["status"],
      paymentStatus: json["paymentStatus"],
      order: json["order"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

class Item {
  Item({
    required this.product,
    required this.quantity,
    required this.priceAtTime,
    required this.id,
  });

  final UserDraftProduct? product;
  final int? quantity;
  final int? priceAtTime;
  final String? id;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      product: json["product"] == null
          ? null
          : UserDraftProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      priceAtTime: json["priceAtTime"],
      id: json["_id"],
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
