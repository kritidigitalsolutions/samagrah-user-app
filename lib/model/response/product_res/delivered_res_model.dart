class DeliveredResModel {
  DeliveredResModel({
    required this.success,
    required this.city,
    required this.pincode,
    required this.count,
    required this.data,
  });

  final bool? success;
  final String? city;
  final String? pincode;
  final int? count;
  final List<Datum> data;

  factory DeliveredResModel.fromJson(Map<String, dynamic> json) {
    return DeliveredResModel(
      success: json["success"],
      city: json["city"],
      pincode: json["pincode"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
    required this.id,
    required this.vendorId,
    required this.locationName,
    required this.state,
    required this.pincode,
    required this.deliveryCharge,
    required this.codCharge,
    required this.status,
  });

  final String? id;
  final String? vendorId;
  final String? locationName;
  final String? state;
  final String? pincode;
  final int? deliveryCharge;
  final int? codCharge;
  final String? status;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["_id"],
      vendorId: json["vendorId"],
      locationName: json["locationName"],
      state: json["state"],
      pincode: json["pincode"],
      deliveryCharge: json["deliveryCharge"],
      codCharge: json["codCharge"],
      status: json["status"],
    );
  }
}
