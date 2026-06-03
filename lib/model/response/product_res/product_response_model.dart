class ProductResModel {
  ProductResModel({
    required this.success,
    required this.city,
    required this.data,
  });

  final bool? success;
  final String? city;
  final Data? data;

  factory ProductResModel.fromJson(Map<String, dynamic> json) {
    return ProductResModel(
      success: json["success"],
      city: json["city"],
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
  Pagination({required this.totalProducts, required this.totalPages});

  final int? totalProducts;
  final int? totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      totalProducts: json["totalProducts"],
      totalPages: json["totalPages"],
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.itemCode,
    required this.title,
    required this.description,
    required this.details,
    required this.discount,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.thumbnail,
    required this.images,
    required this.categoryId,
    required this.category,
    required this.brandId,
    required this.brand,
    required this.inStock,
    required this.review,
    required this.ratings,
    required this.isRecommended,
    required this.isMostPoojaEssentials,
    required this.isMostUsed,
    required this.isEveryDayRitual,
    required this.isRitualItems,
  });

  final String? id;
  final String? itemCode;
  final String? title;
  final String? description;
  final Details? details;
  final Discount? discount;
  final int? price;
  final int? oldPrice;
  final int? discountPercent;
  final String? thumbnail;
  final List<String> images;
  final CategoryId? categoryId;
  final Category? category;
  final BrandId? brandId;
  final Brand? brand;
  final bool? inStock;
  final ProductReview? review;
  final Ratings? ratings;
  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      itemCode: json["itemCode"],
      title: json["title"],
      description: json["description"],
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
      discount: json["discount"] == null
          ? null
          : Discount.fromJson(json["discount"]),
      price: json["price"],
      oldPrice: json["oldPrice"],
      discountPercent: json["discountPercent"],
      thumbnail: json["thumbnail"],
      images: json["products"] == null
          ? []
          : List<String>.from(json["products"]!.map((x) => x)),
      categoryId: json["categoryId"] == null
          ? null
          : CategoryId.fromJson(json["categoryId"]),
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
      brandId: json["brandId"] == null
          ? null
          : BrandId.fromJson(json["brandId"]),
      brand: json["brand"] == null ? null : Brand.fromJson(json["brand"]),
      inStock: json["inStock"],
      review: json["review"] == null
          ? null
          : ProductReview.fromJson(json["review"]),
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

class Brand {
  Brand({required this.name, required this.subBrand});

  final String? name;
  final String? subBrand;

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(name: json["name"], subBrand: json["subBrand"]);
  }
}

class BrandId {
  BrandId({required this.id, required this.name, required this.subBrand});

  final String? id;
  final String? name;
  final String? subBrand;

  factory BrandId.fromJson(Map<String, dynamic> json) {
    return BrandId(
      id: json["_id"],
      name: json["name"],
      subBrand: json["subBrand"],
    );
  }
}

class Category {
  Category({required this.name, required this.subCategory});

  final String? name;
  final String? subCategory;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json["name"], subCategory: json["subCategory"]);
  }
}

class CategoryId {
  CategoryId({required this.id, required this.name, required this.subCategory});

  final String? id;
  final String? name;
  final String? subCategory;

  factory CategoryId.fromJson(Map<String, dynamic> json) {
    return CategoryId(
      id: json["_id"],
      name: json["name"],
      subCategory: json["subCategory"],
    );
  }
}

class Details {
  Details({
    required this.brand,
    required this.subBrand,
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
  final String? subBrand;
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
      subBrand: json["subBrand"],
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

class ProductReview {
  ProductReview({required this.review});

  final ReviewReview? review;

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
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
