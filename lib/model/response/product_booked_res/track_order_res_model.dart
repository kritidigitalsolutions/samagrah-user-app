import 'package:samagrah/model/response/product_booked_res/product_booked_res_modle.dart';
import 'package:samagrah/model/response/product_res/product_response_model.dart';

class TrackOrderResModel {
  TrackOrderResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory TrackOrderResModel.fromJson(Map<String, dynamic> json) {
    return TrackOrderResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.order, required this.tracking});

  final TrackOrder? order;
  final Tracking? tracking;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      order: json["order"] == null ? null : TrackOrder.fromJson(json["order"]),
      tracking: json["tracking"] == null
          ? null
          : Tracking.fromJson(json["tracking"]),
    );
  }
}

class TrackOrder {
  TrackOrder({
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
    required this.addressType,
  });

  final String? id;
  final String? user;
  final List<OrderItem> items;
  final num? totalAmount;
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
  final String? addressType;

  factory TrackOrder.fromJson(Map<String, dynamic> json) {
    return TrackOrder(
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
      addressType: json["addressType"],
    );
  }
}

class AmountBreakup {
  AmountBreakup({required this.itemTotal, required this.deliveryFee});

  final num? itemTotal;
  final num? deliveryFee;

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
  final num? quantity;
  final num? price;
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
  });

  final String? id;
  final String? user;
  final String? name;
  final dynamic baseKit;
  final List<ProductItem> items;
  final num? totalPrice;
  final String? status;
  final String? paymentStatus;
  final String? order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
  final num? quantity;
  final num? priceAtTime;
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
    required this.compliance,
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
  });

  final Category? category;
  final Pricing? pricing;
  final Compliance? compliance;
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

  factory FluffyProduct.fromJson(Map<String, dynamic> json) {
    return FluffyProduct(
      category: json["category"] == null
          ? null
          : Category.fromJson(json["category"]),
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      compliance: json["compliance"] == null
          ? null
          : Compliance.fromJson(json["compliance"]),
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

class Compliance {
  Compliance({required this.hsnCode, required this.city});

  final String? hsnCode;
  final String? city;

  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(hsnCode: json["hsnCode"], city: json["city"]);
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
  Pricing({
    required this.basePrice,
    required this.gstPercent,
    required this.gstAmount,
    required this.priceIncludesGst,
    required this.price,
    required this.mrp,
    required this.currency,
  });

  final num? basePrice;
  final num? gstPercent;
  final num? gstAmount;
  final bool? priceIncludesGst;
  final num? price;
  final num? mrp;
  final String? currency;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      basePrice: json["basePrice"],
      gstPercent: json["gstPercent"],
      gstAmount: json["gstAmount"],
      priceIncludesGst: json["priceIncludesGst"],
      price: json["price"],
      mrp: json["mrp"],
      currency: json["currency"],
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
    required this.orderSteps,
    required this.placedAt,
    required this.lastUpdatedAt,
  });

  final String? currentStatus;
  final bool? isCancelled;
  final List<OrderStep> orderSteps;
  final DateTime? placedAt;
  final DateTime? lastUpdatedAt;

  factory Tracking.fromJson(Map<String, dynamic> json) {
    return Tracking(
      currentStatus: json["currentStatus"],
      isCancelled: json["isCancelled"],
      orderSteps: json["steps"] == null
          ? []
          : List<OrderStep>.from(
              json["steps"]!.map((x) => OrderStep.fromJson(x)),
            ),
      placedAt: DateTime.tryParse(json["placedAt"] ?? ""),
      lastUpdatedAt: DateTime.tryParse(json["lastUpdatedAt"] ?? ""),
    );
  }
}

class OrderStep {
  OrderStep({
    required this.label,
    required this.completed,
    required this.active,
  });

  final String? label;
  final bool? completed;
  final bool? active;

  factory OrderStep.fromJson(Map<String, dynamic> json) {
    return OrderStep(
      label: json["label"],
      completed: json["completed"],
      active: json["active"],
    );
  }
}
