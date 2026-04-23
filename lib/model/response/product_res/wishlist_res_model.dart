class WishlistResModel {
  WishlistResModel({
    required this.success,
    required this.count,
    required this.total,
    required this.data,
  });

  final bool? success;
  final int? count;
  final int? total;
  final List<Datum> data;

  factory WishlistResModel.fromJson(Map<String, dynamic> json) {
    return WishlistResModel(
      success: json["success"],
      count: json["count"],
      total: json["total"],
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

    required this.product,
    required this.quantity,
    required this.priceAtAdd,
  });

  final String? id;
  final String? user;

  final CartProduct? product;
  final int? quantity;
  final int? priceAtAdd;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["_id"],
      user: json["user"],

      product: json["product"] == null
          ? null
          : CartProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      priceAtAdd: json["priceAtAdd"],
    );
  }
}

class CartProduct {
  CartProduct({
    required this.category,
    required this.pricing,
    required this.media,
    required this.ratings,
    required this.stock,
    required this.flags,
    required this.id,
    required this.title,
    required this.slug,
    required this.tags,
  });

  final Category? category;
  final Pricing? pricing;
  final Media? media;
  final Ratings? ratings;
  final Stock? stock;
  final Flags? flags;
  final String? id;
  final String? title;
  final String? slug;
  final List<String> tags;

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      media: json["media"] == null ? null : Media.fromJson(json["media"]),
      ratings: json["ratings"] == null
          ? null
          : Ratings.fromJson(json["ratings"]),
      stock: json["stock"] == null ? null : Stock.fromJson(json["stock"]),
      flags: json["flags"] == null ? null : Flags.fromJson(json["flags"]),
      id: json["_id"],
      title: json["title"],
      slug: json["slug"],
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"]!.map((x) => x)),
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

class Flags {
  Flags({
    required this.isRecommended,
    required this.isMostPoojaEssentials,
    required this.isMostUsed,
    required this.isEveryDayRitual,
    required this.isRitualItems,
  });

  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Flags.fromJson(Map<String, dynamic> json) {
    return Flags(
      isRecommended: json["isRecommended"],
      isMostPoojaEssentials: json["isMostPoojaEssentials"],
      isMostUsed: json["isMostUsed"],
      isEveryDayRitual: json["isEveryDayRitual"],
      isRitualItems: json["isRitualItems"],
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

class Ratings {
  Ratings({required this.average, required this.totalReviews});

  final int? average;
  final int? totalReviews;

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      average: json["average"],
      totalReviews: json["totalReviews"],
    );
  }
}

class Stock {
  Stock({required this.quantity});

  final int? quantity;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(quantity: json["quantity"]);
  }
}
