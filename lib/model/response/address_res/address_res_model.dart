class AddressResModel {
  AddressResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory AddressResModel.fromJson(Map<String, dynamic> json) {
    return AddressResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.addresses});

  final List<AddressRes> addresses;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      addresses: json["addresses"] == null
          ? []
          : List<AddressRes>.from(
              json["addresses"]!.map((x) => AddressRes.fromJson(x)),
            ),
    );
  }
}

class AddressRes {
  AddressRes({
    required this.addressType,
    required this.name,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.isDefault,
    required this.id,
  });

  final String? addressType;

  final String? name;
  final String? phone;
  final String? fullAddress;
  final String? city;
  final String? state;
  final String? pincode;
  final bool? isDefault;
  final String? id;

  factory AddressRes.fromJson(Map<String, dynamic> json) {
    return AddressRes(
      addressType: json["addressType"],

      name: json["name"],
      phone: json["phone"],
      fullAddress: json["fullAddress"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
      isDefault: json["isDefault"],
      id: json["_id"],
    );
  }
}
