class AvailabilityResModel {
  AvailabilityResModel({
    required this.success,
    required this.data,
  });

  final bool? success;
  final Data? data;

  factory AvailabilityResModel.fromJson(Map<String, dynamic> json){
    return AvailabilityResModel(
      success: json["success"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.id,
    required this.month,
    required this.pandit,
    required this.year,
    required this.v,
    required this.availability
  });

  final String? id;
  final int? month;
  final String? pandit;
  final int? year;
  final int? v;
  final List<Availability> availability;

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      id: json["_id"],
      month: json["month"],
      pandit: json["pandit"],
      year: json["year"],
      v: json["__v"],
      availability: json["availability"] == null ? [] : List<Availability>.from(json["availability"]!.map((x) => Availability.fromJson(x))),

    );
  }
}

class Availability {
  Availability({
    required this.date,
    required this.status,
  });

  final String? date;
  final String? status;

  factory Availability.fromJson(Map<String, dynamic> json){
    return Availability(
      date: json["date"],
      status: json["status"],
    );
  }
}
