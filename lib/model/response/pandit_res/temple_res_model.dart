class TempleResModel {
  TempleResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<TempleData> data;

  factory TempleResModel.fromJson(Map<String, dynamic> json) {
    return TempleResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<TempleData>.from(
              json["data"]!.map((x) => TempleData.fromJson(x)),
            ),
    );
  }
}

class TempleData {
  TempleData({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.contactPhone,
    required this.contactPerson,
    required this.openingTime,
    required this.closingTime,
    required this.facilities,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? name;
  final String? image;
  final String? description;
  final String? contactPhone;
  final String? contactPerson;
  final String? openingTime;
  final String? closingTime;
  final List<String> facilities;
  final Address? address;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory TempleData.fromJson(Map<String, dynamic> json) {
    return TempleData(
      id: json["_id"],
      name: json["name"],
      image: json["image"],
      description: json["description"],
      contactPhone: json["contactPhone"],
      contactPerson: json["contactPerson"],
      openingTime: json["openingTime"],
      closingTime: json["closingTime"],
      facilities: json["facilities"] == null
          ? []
          : List<String>.from(json["facilities"]!.map((x) => x)),
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
      status: json["status"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

class Address {
  Address({
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.landmark,
  });

  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pinCode;
  final String? landmark;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"],
      state: json["state"],
      pinCode: json["pinCode"],
      landmark: json["landmark"],
    );
  }
}
