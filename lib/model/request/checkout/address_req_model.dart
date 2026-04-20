class AddressReqModel {
  final String addressType;
  final String name;
  final String phone;
  final String house;
  final String city;
  final String state;
  final String pincode;

  AddressReqModel({
    required this.addressType,
    required this.name,
    required this.phone,
    required this.house,
    required this.city,
    required this.state,
    required this.pincode,
  });

  // ✅ Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      "addressType": addressType,
      "name": name,
      "phone": phone,
      "house": house,
      "city": city,
      "state": state,
      "pincode": pincode,
    };
  }

  // ✅ copyWith (very useful for form updates)
  AddressReqModel copyWith({
    String? addressType,
    String? name,
    String? phone,
    String? house,
    String? city,
    String? state,
    String? pincode,
  }) {
    return AddressReqModel(
      addressType: addressType ?? this.addressType,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      house: house ?? this.house,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }
}
