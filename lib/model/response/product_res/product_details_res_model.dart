class ProductDetailsResModel {
  ProductDetailsResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory ProductDetailsResModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.id,
    required this.title,
    required this.category,
    required this.pricing,
    required this.image,
    required this.stock,
    required this.tags,
    required this.isRecommended,
    required this.isMostPoojaEssentials,
    required this.isMostUsed,
    required this.isEveryDayRitual,
    required this.isRitualItems,
  });

  final String? id;
  final String? title;
  final String? category;
  final Pricing? pricing;
  final List<String> image;
  final Stock? stock;
  final List<String> tags;
  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"],
      title: json["title"],
      category: json["category"],
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      image: json["image"] == null
          ? []
          : List<String>.from(json["image"]!.map((x) => x)),
      stock: json["stock"] == null ? null : Stock.fromJson(json["stock"]),
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"]!.map((x) => x)),
      isRecommended: json["isRecommended"],
      isMostPoojaEssentials: json["isMostPoojaEssentials"],
      isMostUsed: json["isMostUsed"],
      isEveryDayRitual: json["isEveryDayRitual"],
      isRitualItems: json["isRitualItems"],
    );
  }
}

class Pricing {
  Pricing({
    required this.price,
    required this.mrp,
    required this.discountPercent,
    required this.savings,
    required this.currency,
  });

  final int? price;
  final int? mrp;
  final int? discountPercent;
  final int? savings;
  final String? currency;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      price: json["price"],
      mrp: json["mrp"],
      discountPercent: json["discountPercent"],
      savings: json["savings"],
      currency: json["currency"],
    );
  }
}

class Stock {
  Stock({required this.status});

  final String? status;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(status: json["status"]);
  }
}
