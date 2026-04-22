class ProductBookedResModel {
  ProductBookedResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final Data? data;

  factory ProductBookedResModel.fromJson(Map<String, dynamic> json) {
    return ProductBookedResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.orders});

  final List<Order> orders;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      orders: json["orders"] == null
          ? []
          : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
    );
  }
}

class Order {
  Order({
    required this.id,
    required this.user,
    required this.items,
    required this.totalAmount,
    required this.amountBreakup,
    required this.address,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentGateway,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.orderStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.tracking,
    required this.itemCount,
  });

  final String? id;
  final String? user;
  final List<OrderItem> items;
  final int? totalAmount;
  final AmountBreakup? amountBreakup;
  final Address? address;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentGateway;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final Tracking? tracking;
  final int? itemCount;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["_id"],
      user: json["user"],
      items: json["items"] == null
          ? []
          : List<OrderItem>.from(
              json["items"]!.map((x) => OrderItem.fromJson(x)),
            ),
      totalAmount: json["totalAmount"],
      amountBreakup: json["amountBreakup"] == null
          ? null
          : AmountBreakup.fromJson(json["amountBreakup"]),
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
      paymentMethod: json["paymentMethod"],
      paymentStatus: json["paymentStatus"],
      paymentGateway: json["paymentGateway"],
      razorpayOrderId: json["razorpayOrderId"],
      razorpayPaymentId: json["razorpayPaymentId"],
      razorpaySignature: json["razorpaySignature"],
      orderStatus: json["orderStatus"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      tracking: json["tracking"] == null
          ? null
          : Tracking.fromJson(json["tracking"]),
      itemCount: json["itemCount"],
    );
  }
}

class Address {
  Address({
    required this.name,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String? name;
  final String? phone;
  final String? fullAddress;
  final String? city;
  final String? state;
  final String? pincode;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json["name"],
      phone: json["phone"],
      fullAddress: json["fullAddress"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
    );
  }
}

class AmountBreakup {
  AmountBreakup({required this.itemTotal, required this.deliveryFee});

  final int? itemTotal;
  final int? deliveryFee;

  factory AmountBreakup.fromJson(Map<String, dynamic> json) {
    return AmountBreakup(
      itemTotal: json["itemTotal"],
      deliveryFee: json["deliveryFee"],
    );
  }
}

class OrderItem {
  OrderItem({
    required this.productType,
    required this.product,
    required this.quantity,
    required this.price,
    required this.id,
  });

  final String? productType;
  final PurpleProduct? product;
  final int? quantity;
  final int? price;
  final String? id;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productType: json["productType"],
      product: json["product"] == null
          ? null
          : PurpleProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      price: json["price"],
      id: json["_id"],
    );
  }
}

class PurpleProduct {
  PurpleProduct({
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
    required this.category,
    required this.pricing,
    required this.media,
    required this.ratings,
    required this.stock,
    required this.flags,
    required this.title,
    required this.slug,
    required this.tags,
    required this.description,
    required this.image,
    required this.kitPrice,
    required this.savings,
  });

  final String? id;
  final String? user;
  final String? name;
  final dynamic baseKit;
  final List<ProductItem> items;
  final int? totalPrice;
  final String? status;
  final String? paymentStatus;
  final String? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final Category? category;
  final Pricing? pricing;
  final Media? media;
  final Ratings? ratings;
  final Stock? stock;
  final Flags? flags;
  final String? title;
  final String? slug;
  final List<String> tags;
  final String? description;
  final String? image;
  final int? kitPrice;
  final int? savings;

  factory PurpleProduct.fromJson(Map<String, dynamic> json) {
    return PurpleProduct(
      id: json["_id"],
      user: json["user"],
      name: json["name"],
      baseKit: json["baseKit"],
      items: json["items"] == null
          ? []
          : List<ProductItem>.from(
              json["items"]!.map((x) => ProductItem.fromJson(x)),
            ),
      totalPrice: json["totalPrice"],
      status: json["status"],
      paymentStatus: json["paymentStatus"],
      order: json["order"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
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
      title: json["title"],
      slug: json["slug"],
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"]!.map((x) => x)),
      description: json["description"],
      image: json["image"],
      kitPrice: json["kitPrice"],
      savings: json["savings"],
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

class ProductItem {
  ProductItem({
    required this.product,
    required this.quantity,
    required this.priceAtTime,
    required this.id,
  });

  final FluffyProduct? product;
  final int? quantity;
  final int? priceAtTime;
  final String? id;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      product: json["product"] == null
          ? null
          : FluffyProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      priceAtTime: json["priceAtTime"],
      id: json["_id"],
    );
  }
}

class FluffyProduct {
  FluffyProduct({
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
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
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
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory FluffyProduct.fromJson(Map<String, dynamic> json) {
    return FluffyProduct(
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
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
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

class Tracking {
  Tracking({
    required this.currentStatus,
    required this.isCancelled,
    required this.steps,
    required this.placedAt,
    required this.lastUpdatedAt,
  });

  final String? currentStatus;
  final bool? isCancelled;
  final List<Step> steps;
  final DateTime? placedAt;
  final DateTime? lastUpdatedAt;

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      currentStatus: json["currentStatus"],
      isCancelled: json["isCancelled"],
      steps: json["steps"] == null
          ? []
          : List<Step>.from(json["steps"]!.map((x) => Step.fromJson(x))),
      placedAt: DateTime.tryParse(json["placedAt"] ?? ""),
      lastUpdatedAt: DateTime.tryParse(json["lastUpdatedAt"] ?? ""),
    );
  }
}

class Step {
  Step({required this.label, required this.completed, required this.active});

  final String? label;
  final bool? completed;
  final bool? active;

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      label: json["label"],
      completed: json["completed"],
      active: json["active"],
    );
  }
}
