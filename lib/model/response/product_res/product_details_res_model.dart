import 'package:samagrah/model/response/product_res/product_response_model.dart';

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
    required this.description,
    required this.details,
    required this.discount,
    required this.category,
    required this.pricing,
    required this.image,
    required this.stock,
    required this.review,
    required this.ratings,
    required this.tags,
    required this.isRecommended,
    required this.isMostPoojaEssentials,
    required this.isMostUsed,
    required this.isEveryDayRitual,
    required this.isRitualItems,
  });

  final String? id;
  final String? title;
  final String? description;
  final Details? details;
  final Discount? discount;
  final Category? category;
  final Pricing? pricing;
  final List<String> image;
  final Stock? stock;
  final DataReview? review;
  final Ratings? ratings;
  final List<dynamic> tags;
  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
      discount: json["discount"] == null
          ? null
          : Discount.fromJson(json["discount"]),
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      image: json["image"] == null
          ? []
          : List<String>.from(json["image"]!.map((x) => x)),
      stock: json["stock"] == null ? null : Stock.fromJson(json["stock"]),
      review: json["review"] == null
          ? null
          : DataReview.fromJson(json["review"]),
      ratings: json["ratings"] == null
          ? null
          : Ratings.fromJson(json["ratings"]),
      tags: json["tags"] == null
          ? []
          : List<dynamic>.from(json["tags"]!.map((x) => x)),
      isRecommended: json["isRecommended"],
      isMostPoojaEssentials: json["isMostPoojaEssentials"],
      isMostUsed: json["isMostUsed"],
      isEveryDayRitual: json["isEveryDayRitual"],
      isRitualItems: json["isRitualItems"],
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

class Details {
  Details({
    required this.brand,
    required this.sku,
    required this.unit,
    required this.weight,
    required this.dimensions,
    required this.material,
    required this.color,
    required this.manufacturer,
    required this.countryOfOrigin,
    required this.packageContents,
    required this.usageInstructions,
    required this.careInstructions,
    required this.expiryInfo,
  });

  final String? brand;
  final String? sku;
  final String? unit;
  final String? weight;
  final String? dimensions;
  final String? material;
  final String? color;
  final String? manufacturer;
  final String? countryOfOrigin;
  final String? packageContents;
  final String? usageInstructions;
  final String? careInstructions;
  final String? expiryInfo;

  factory Details.fromJson(Map<String, dynamic> json) {
    return Details(
      brand: json["brand"],
      sku: json["sku"],
      unit: json["unit"],
      weight: json["weight"],
      dimensions: json["dimensions"],
      material: json["material"],
      color: json["color"],
      manufacturer: json["manufacturer"],
      countryOfOrigin: json["countryOfOrigin"],
      packageContents: json["packageContents"],
      usageInstructions: json["usageInstructions"],
      careInstructions: json["careInstructions"],
      expiryInfo: json["expiryInfo"],
    );
  }
}

class Discount {
  Discount({
    required this.type,
    required this.value,
    required this.isActive,
    required this.startsAt,
    required this.expiresAt,
  });

  final String? type;
  final int? value;
  final bool? isActive;
  final dynamic startsAt;
  final dynamic expiresAt;

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      type: json["type"],
      value: json["value"],
      isActive: json["isActive"],
      startsAt: json["startsAt"],
      expiresAt: json["expiresAt"],
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

class DataReview {
  DataReview({required this.review});

  final ReviewReview? review;

  factory DataReview.fromJson(Map<String, dynamic> json) {
    return DataReview(
      review: json["review"] == null
          ? null
          : ReviewReview.fromJson(json["review"]),
    );
  }
}

class ReviewReview {
  ReviewReview({required this.comment, required this.rating});

  final String? comment;
  final int? rating;

  factory ReviewReview.fromJson(Map<String, dynamic> json) {
    return ReviewReview(comment: json["comment"], rating: json["rating"]);
  }
}

class Stock {
  Stock({required this.status});

  final String? status;

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(status: json["status"]);
  }
}
