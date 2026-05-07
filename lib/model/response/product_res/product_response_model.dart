import 'package:samagrah/model/response/kit_response/default_kit_res_model.dart';

class ProductResModel {
  ProductResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory ProductResModel.fromJson(Map<String, dynamic> json) {
    return ProductResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.products, required this.pagination});

  final List<Product> products;
  final Pagination? pagination;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      products: json["products"] == null
          ? []
          : List<Product>.from(
              json["products"]!.map((x) => Product.fromJson(x)),
            ),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
    );
  }
}

class Pagination {
  Pagination({
    required this.totalProducts,
    required this.currentPage,
    required this.totalPages,
  });

  final int? totalProducts;
  final int? currentPage;
  final int? totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalProducts: json["totalProducts"],
      currentPage: json["currentPage"],
      totalPages: json["totalPages"],
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.details,
    required this.price,
    required this.oldPrice,
    this.pricing,
    required this.discountPercent,
    required this.thumbnail,
    required this.images,
    required this.category,
    required this.inStock,
    required this.ratings,
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
  final int? price;
  final int? oldPrice;
  final Pricing? pricing;
  final int? discountPercent;
  final String? thumbnail;
  final List<String> images;
  final Category? category;
  final bool? inStock;
  final Ratings? ratings;
  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      title: json["title"],
      description: json["description"],
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
      price: json["price"],
      oldPrice: json["oldPrice"],
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      discountPercent: json["discountPercent"],
      thumbnail: json["thumbnail"],
      images: json["products"] == null
          ? []
          : List<String>.from(json["products"]!.map((x) => x)),
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
      inStock: json["inStock"],
      ratings: json["ratings"] == null
          ? null
          : Ratings.fromJson(json["ratings"]),
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

class Ratings {
  Ratings({
    required this.counts,
    required this.average,
    required this.totalReviews,
  });

  final Counts? counts;
  final int? average;
  final int? totalReviews;

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      counts: json["counts"] == null ? null : Counts.fromJson(json["counts"]),
      average: json["average"],
      totalReviews: json["totalReviews"],
    );
  }
}

class Counts {
  Counts({
    required this.rating1,
    required this.rating2,
    required this.rating3,
    required this.rating4,
    required this.rating5,
  });

  final int? rating1;
  final int? rating2;
  final int? rating3;
  final int? rating4;
  final int? rating5;

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      rating1: json["rating1"],
      rating2: json["rating2"],
      rating3: json["rating3"],
      rating4: json["rating4"],
      rating5: json["rating5"],
    );
  }
}
