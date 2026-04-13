class UserRequestModel {
  final String name;
  final String? email;
  final String? address;
  final String phone;
  final String? profileImage;

  UserRequestModel({
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{"name": name, "phone": phone};

    if (email != null) data["email"] = email;
    if (address != null) data["address"] = address;
    if (profileImage != null) data["profileImage"] = profileImage;

    return data;
  }
}
