import 'package:samagrah/model/response/product_res/product_response_model.dart';

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
    required this.vendorId,
    required this.items,
    required this.totalAmount,
    required this.amountBreakup,
    required this.couponCode,
    required this.offer,
    required this.discountTotal,
    required this.cashbackAmount,
    required this.walletUsed,
    required this.payableAmount,
    required this.addressType,
    required this.address,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentGateway,
    required this.deliveryBoy,
    required this.deliveryAssignedAt,
    required this.deliveryAssignedBy,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.orderStatus,
    required this.inventoryAdjusted,
    required this.cancellationRequests,
    required this.rescheduleRequests,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.tracking,
    required this.itemCount,
  });

  final String? id;
  final String? user;
  final String? vendorId;
  final List<OrderItem> items;
  final num? totalAmount;
  final AmountBreakup? amountBreakup;
  final dynamic couponCode;
  final Offer? offer;
  final num? discountTotal;
  final num? cashbackAmount;
  final num? walletUsed;
  final num? payableAmount;
  final String? addressType;
  final Address? address;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentGateway;
  final dynamic deliveryBoy;
  final dynamic deliveryAssignedAt;
  final dynamic deliveryAssignedBy;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? orderStatus;
  final bool? inventoryAdjusted;
  final List<dynamic> cancellationRequests;
  final List<dynamic> rescheduleRequests;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final Tracking? tracking;
  final int? itemCount;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["_id"],
      user: json["user"],
      vendorId: json["vendorId"],
      items: json["items"] == null
          ? []
          : List<OrderItem>.from(
              json["items"]!.map((x) => OrderItem.fromJson(x)),
            ),
      totalAmount: json["totalAmount"],
      amountBreakup: json["amountBreakup"] == null
          ? null
          : AmountBreakup.fromJson(json["amountBreakup"]),
      couponCode: json["couponCode"],
      offer: json["offer"] == null ? null : Offer.fromJson(json["offer"]),
      discountTotal: json["discountTotal"],
      cashbackAmount: json["cashbackAmount"],
      walletUsed: json["walletUsed"],
      payableAmount: json["payableAmount"],
      addressType: json["addressType"],
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
      paymentMethod: json["paymentMethod"],
      paymentStatus: json["paymentStatus"],
      paymentGateway: json["paymentGateway"],
      deliveryBoy: json["deliveryBoy"],
      deliveryAssignedAt: json["deliveryAssignedAt"],
      deliveryAssignedBy: json["deliveryAssignedBy"],
      razorpayOrderId: json["razorpayOrderId"],
      razorpayPaymentId: json["razorpayPaymentId"],
      razorpaySignature: json["razorpaySignature"],
      orderStatus: json["orderStatus"],
      inventoryAdjusted: json["inventoryAdjusted"],
      cancellationRequests: json["cancellationRequests"] == null
          ? []
          : List<dynamic>.from(json["cancellationRequests"]!.map((x) => x)),
      rescheduleRequests: json["rescheduleRequests"] == null
          ? []
          : List<dynamic>.from(json["rescheduleRequests"]!.map((x) => x)),
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
    required this.addressType,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String? name;
  final String? phone;
  final String? fullAddress;
  final String? addressType;
  final String? city;
  final String? state;
  final String? pincode;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json["name"],
      phone: json["phone"],
      fullAddress: json["fullAddress"],
      addressType: json["addressType"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
    );
  }
}

class AmountBreakup {
  AmountBreakup({
    required this.itemTotal,
    required this.deliveryFee,
    required this.couponDiscount,
    required this.offerDiscount,
    required this.walletUsed,
    required this.payableAmount,
  });

  final num? itemTotal;
  final num? deliveryFee;
  final num? couponDiscount;
  final num? offerDiscount;
  final num? walletUsed;
  final num? payableAmount;

  factory AmountBreakup.fromJson(Map<String, dynamic> json) {
    return AmountBreakup(
      itemTotal: json["itemTotal"],
      deliveryFee: json["deliveryFee"],
      couponDiscount: json["couponDiscount"],
      offerDiscount: json["offerDiscount"],
      walletUsed: json["walletUsed"],
      payableAmount: json["payableAmount"],
    );
  }
}

class OrderItem {
  OrderItem({
    required this.productType,
    required this.product,
    required this.quantity,
    required this.price,
    required this.isUserReview,
    required this.id,
  });

  final String? productType;
  final PurpleProduct? product;
  final num? quantity;
  final bool? isUserReview;
  final num? price;
  final String? id;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productType: json["productType"],
      product: json["product"] == null
          ? null
          : PurpleProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      isUserReview: json["isUserReview"],
      price: json["price"],
      id: json["_id"],
    );
  }
}

class PurpleProduct {
  PurpleProduct({
    required this.category,
    required this.details,
    required this.pricing,
    required this.discount,
    required this.compliance,
    required this.media,
    required this.ratings,
    required this.stock,
    required this.flags,
    required this.id,
    required this.vendorId,
    required this.title,
    required this.slug,
    required this.description,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCode,
    required this.v,
    required this.kitType,
    required this.name,
    required this.image,
    required this.isMostPopularKit,
    required this.isMostUserUse,
    required this.isPanditApproved,
    required this.items,
    required this.totalPrice,
    required this.kitPrice,
    required this.savings,
  });

  final dynamic category;
  final Details? details;
  final Pricing? pricing;
  final Discount? discount;
  final Compliance? compliance;
  final Media? media;
  final Ratings? ratings;
  final Stock? stock;
  final Flags? flags;
  final String? id;
  final String? vendorId;
  final String? title;
  final String? slug;
  final String? description;
  final List<dynamic> tags;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? itemCode;
  final int? v;
  final String? kitType;
  final String? name;
  final String? image;
  final bool? isMostPopularKit;
  final bool? isMostUserUse;
  final bool? isPanditApproved;
  final List<ProductItem> items;
  final num? totalPrice;
  final num? kitPrice;
  final num? savings;

  factory PurpleProduct.fromJson(Map<String, dynamic> json) {
    return PurpleProduct(
      category: json["category"],
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      discount: json["discount"] == null
          ? null
          : Discount.fromJson(json["discount"]),
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
      vendorId: json["vendorId"],
      title: json["title"],
      slug: json["slug"],
      description: json["description"],
      tags: json["tags"] == null
          ? []
          : List<dynamic>.from(json["tags"]!.map((x) => x)),
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      itemCode: json["itemCode"],
      v: json["__v"],
      kitType: json["kitType"],
      name: json["name"],
      image: json["image"],
      isMostPopularKit: json["isMostPopularKit"],
      isMostUserUse: json["isMostUserUse"],
      isPanditApproved: json["isPanditApproved"],
      items: json["items"] == null
          ? []
          : List<ProductItem>.from(
              json["items"]!.map((x) => ProductItem.fromJson(x)),
            ),
      totalPrice: json["totalPrice"],
      kitPrice: json["kitPrice"],
      savings: json["savings"],
    );
  }
}

class CategoryClass {
  CategoryClass({required this.name, required this.subCategory});

  final String? name;
  final String? subCategory;

  factory CategoryClass.fromJson(Map<String, dynamic> json) {
    return CategoryClass(name: json["name"], subCategory: json["subCategory"]);
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
  final num? value;
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
    required this.id,
  });

  final FluffyProduct? product;
  final int? quantity;
  final String? id;

  factory ProductItem.fromJson(Map<String, dynamic> json) {
    return ProductItem(
      product: json["product"] == null
          ? null
          : FluffyProduct.fromJson(json["product"]),
      quantity: json["quantity"],
      id: json["_id"],
    );
  }
}

class FluffyProduct {
  FluffyProduct({
    required this.category,
    required this.details,
    required this.pricing,
    required this.discount,
    required this.compliance,
    required this.media,
    required this.ratings,
    required this.stock,
    required this.flags,
    required this.id,
    required this.vendorId,
    required this.title,
    required this.slug,
    required this.description,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.itemCode,
    required this.v,
  });

  final CategoryClass? category;
  final Details? details;
  final Pricing? pricing;
  final Discount? discount;
  final Compliance? compliance;
  final Media? media;
  final Ratings? ratings;
  final Stock? stock;
  final Flags? flags;
  final String? id;
  final String? vendorId;
  final String? title;
  final String? slug;
  final String? description;
  final List<String> tags;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? itemCode;
  final int? v;

  factory FluffyProduct.fromJson(Map<String, dynamic> json) {
    return FluffyProduct(
      category: json["category"] == null
          ? null
          : CategoryClass.fromJson(json["category"]),
      details: json["details"] == null
          ? null
          : Details.fromJson(json["details"]),
      pricing: json["pricing"] == null
          ? null
          : Pricing.fromJson(json["pricing"]),
      discount: json["discount"] == null
          ? null
          : Discount.fromJson(json["discount"]),
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
      vendorId: json["vendorId"],
      title: json["title"],
      slug: json["slug"],
      description: json["description"],
      tags: json["tags"] == null
          ? []
          : List<String>.from(json["tags"]!.map((x) => x)),
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      itemCode: json["itemCode"],
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

  Map<String, dynamic> toJson() => {"image": image.map((x) => x).toList()};
}

class Pricing {
  Pricing({
    required this.price,
    required this.basePrice,
    required this.gstPercent,
    required this.gstAmount,
    required this.priceIncludesGst,
    required this.currency,
    required this.mrp,
  });

  final num? price;
  final num? basePrice;
  final num? gstPercent;
  final num? gstAmount;
  final bool? priceIncludesGst;
  final String? currency;
  final num? mrp;

  factory Pricing.fromJson(Map<String, dynamic> json) {
    return Pricing(
      price: json["price"],
      basePrice: json["basePrice"],
      gstPercent: json["gstPercent"],
      gstAmount: json["gstAmount"],
      priceIncludesGst: json["priceIncludesGst"],
      currency: json["currency"],
      mrp: json["mrp"],
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

class Offer {
  Offer({required this.id, required this.type});

  final dynamic id;
  final dynamic type;

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(id: json["id"], type: json["type"]);
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
