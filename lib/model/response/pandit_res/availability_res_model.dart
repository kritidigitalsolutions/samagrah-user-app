class AvailabilityResModel {
  AvailabilityResModel({required this.success, required this.data});

  final bool? success;
  final Data? data;

  factory AvailabilityResModel.fromJson(Map<String, dynamic> json) {
    final rawData = json["data"];
    return AvailabilityResModel(
      success: json["success"],
      data: rawData == null ? null : Data.fromDynamic(rawData),
    );
  }
}

Map<String, dynamic> _asStringMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

class Data {
  Data({
    required this.id,
    required this.month,
    required this.pandit,
    required this.year,
    required this.v,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final int? month;
  final String? pandit;
  final int? year;
  final int? v;
  final List<Availability> availability;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Data.fromDynamic(dynamic json) {
    if (json is List) {
      return Data.fromList(json);
    }

    if (json is Map) {
      return Data.fromJson(_asStringMap(json));
    }

    return Data.empty();
  }

  factory Data.empty() {
    return Data(
      id: null,
      month: null,
      pandit: null,
      year: null,
      v: null,
      availability: [],
      createdAt: null,
      updatedAt: null,
    );
  }

  factory Data.fromList(List<dynamic> json) {
    final availability = <Availability>[];
    Data? firstData;
    DateTime? latestUpdatedAt;

    for (final item in json) {
      if (item is! Map) continue;

      final data = Data.fromJson(_asStringMap(item));
      firstData ??= data;
      availability.addAll(data.availability);

      final updatedAt = data.updatedAt;
      if (updatedAt != null &&
          (latestUpdatedAt == null || updatedAt.isAfter(latestUpdatedAt))) {
        latestUpdatedAt = updatedAt;
      }
    }

    availability.sort((a, b) => (a.date ?? '').compareTo(b.date ?? ''));

    return Data(
      id: firstData?.id,
      month: firstData?.month,
      pandit: firstData?.pandit,
      year: firstData?.year,
      v: firstData?.v,
      availability: availability,
      createdAt: firstData?.createdAt,
      updatedAt: latestUpdatedAt ?? firstData?.updatedAt,
    );
  }

  factory Data.fromJson(Map<String, dynamic> json) {
    final availabilityList = _asList(json["availability"])
        .whereType<Map>()
        .map((x) => Availability.fromJson(_asStringMap(x)))
        .toList();

    return Data(
      id: json["_id"]?.toString(),
      month: int.tryParse(json["month"]?.toString() ?? ""),
      pandit: json["pandit"]?.toString(),
      year: int.tryParse(json["year"]?.toString() ?? ""),
      v: int.tryParse(json["__v"]?.toString() ?? ""),
      availability: availabilityList,
      createdAt: DateTime.tryParse(json["createdAt"]?.toString() ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"]?.toString() ?? ""),
    );
  }
}

class Availability {
  Availability({required this.date, required this.status, required this.slots});

  final String? date;
  final String? status;
  final List<Slot> slots;

  factory Availability.fromJson(Map<String, dynamic> json) {
    final slots = _asList(json["slots"])
        .whereType<Map>()
        .map((x) => Slot.fromJson(_asStringMap(x)))
        .toList();

    return Availability(
      date: json["date"]?.toString(),
      status: json["status"]?.toString(),
      slots: slots,
    );
  }
}

class Slot {
  Slot({required this.time, required this.status});

  final String? time;
  final String? status;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      time: json["time"]?.toString(),
      status: json["status"]?.toString(),
    );
  }
}
