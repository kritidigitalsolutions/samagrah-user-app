class UserRegisterResponseModel {
  UserRegisterResponseModel({
    required this.success,
    required this.isNewUser,
    required this.message,
    required this.data,
  });

  final bool? success;
  final bool? isNewUser;
  final String? message;
  final Data? data;

  factory UserRegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return UserRegisterResponseModel(
      success: json["success"],
      isNewUser: json["isNewUser"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.otp});

  final String? otp;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(otp: json["OTP"]);
  }
}

class VerifyOtpResponseModel {
  VerifyOtpResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final UserData? data;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : UserData.fromJson(json["data"]),
    );
  }
}

class UserData {
  UserData({required this.token, required this.user});

  final String? token;
  final User? user;

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      token: json["token"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }
}

class User {
  User({
    required this.phone,
    required this.name,
    required this.email,
    required this.address,
    required this.profileImage,
    required this.isProfileComplete,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? phone;
  final String? name;
  final String? email;
  final String? address;
  final dynamic profileImage;
  final bool? isProfileComplete;
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phone: json["phone"],
      name: json["name"],
      email: json["email"],
      address: json["address"],
      profileImage: json["profileImage"],
      isProfileComplete: json["isProfileComplete"],
      id: json["_id"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
