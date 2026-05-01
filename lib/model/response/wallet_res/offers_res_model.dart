class OffersResModel {
  OffersResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory OffersResModel.fromJson(Map<String, dynamic> json) {
    return OffersResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.offers});

  final List<Offer> offers;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      offers: json["offers"] == null
          ? []
          : List<Offer>.from(json["offers"]!.map((x) => Offer.fromJson(x))),
    );
  }
}

class Offer {
  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.offerType,
    required this.discountType,
    required this.value,
    required this.minOrderAmount,
    required this.maxBenefit,
    required this.isActive,
    required this.startsAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? offerType;
  final String? discountType;
  final int? value;
  final int? minOrderAmount;
  final int? maxBenefit;
  final bool? isActive;
  final dynamic startsAt;
  final dynamic expiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      offerType: json["offerType"],
      discountType: json["discountType"],
      value: json["value"],
      minOrderAmount: json["minOrderAmount"],
      maxBenefit: json["maxBenefit"],
      isActive: json["isActive"],
      startsAt: json["startsAt"],
      expiresAt: json["expiresAt"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }
}
