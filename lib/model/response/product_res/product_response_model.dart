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
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.thumbnail,
    required this.images,
    required this.category,
    required this.inStock,
    required this.isRecommended,
    required this.isMostPoojaEssentials,
    required this.isMostUsed,
    required this.isEveryDayRitual,
    required this.isRitualItems,
  });

  final String? id;
  final String? title;
  final int? price;
  final int? oldPrice;
  final int? discountPercent;
  final dynamic thumbnail;
  final List<dynamic> images;
  final String? category;
  final bool? inStock;
  final bool? isRecommended;
  final bool? isMostPoojaEssentials;
  final bool? isMostUsed;
  final bool? isEveryDayRitual;
  final bool? isRitualItems;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      oldPrice: json["oldPrice"],
      discountPercent: json["discountPercent"],
      thumbnail: json["thumbnail"],
      images: json["images"] == null
          ? []
          : List<dynamic>.from(json["images"]!.map((x) => x)),
      category: json["category"],
      inStock: json["inStock"],
      isRecommended: json["isRecommended"],
      isMostPoojaEssentials: json["isMostPoojaEssentials"],
      isMostUsed: json["isMostUsed"],
      isEveryDayRitual: json["isEveryDayRitual"],
      isRitualItems: json["isRitualItems"],
    );
  }
}
