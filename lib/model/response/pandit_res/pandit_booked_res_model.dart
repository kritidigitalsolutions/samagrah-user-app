class PanditBookedResModel {
  PanditBookedResModel({
    required this.success,
    required this.count,
    required this.data,
  });

  final bool? success;
  final int? count;
  final List<Datum> data;

  factory PanditBookedResModel.fromJson(Map<String, dynamic> json) {
    return PanditBookedResModel(
      success: json["success"],
      count: json["count"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
    required this.payment,
    required this.panditDecision,
    required this.id,
    required this.user,
    required this.pandit,
    required this.ritual,
    required this.ritualRef,
    required this.bookingMode,
    required this.bookingDate,
    required this.dateAndTime,
    required this.address,
    required this.temple,
    required this.templeSnapshot,
    required this.dakshinaAmount,
    required this.recommendedKit,
    required this.bookingStatus,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.mandir,
    required this.mandirSnapshot,
  });

  final Payment? payment;
  final PanditDecision? panditDecision;
  final String? id;
  final String? user;
  final Pandit? pandit;
  final Ritual? ritual;
  final RitualRef? ritualRef;
  final String? bookingMode;
  final String? bookingDate;
  final DatumDateAndTime? dateAndTime;
  final Address? address;
  final dynamic temple;
  final Snapshot? templeSnapshot;
  final int? dakshinaAmount;
  final dynamic recommendedKit;
  final String? bookingStatus;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final dynamic mandir;
  final Snapshot? mandirSnapshot;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      payment: json["payment"] == null
          ? null
          : Payment.fromJson(json["payment"]),
      panditDecision: json["panditDecision"] == null
          ? null
          : PanditDecision.fromJson(json["panditDecision"]),
      id: json["_id"],
      user: json["user"],
      pandit: json["pandit"] == null ? null : Pandit.fromJson(json["pandit"]),
      ritual: json["ritual"] == null ? null : Ritual.fromJson(json["ritual"]),
      ritualRef: json["ritualRef"] == null
          ? null
          : RitualRef.fromJson(json["ritualRef"]),
      bookingMode: json["bookingMode"],
      bookingDate: json["bookingDate"],
      dateAndTime: json["dateAndTime"] == null
          ? null
          : DatumDateAndTime.fromJson(json["dateAndTime"]),
      address: json["address"] == null
          ? null
          : Address.fromJson(json["address"]),
      temple: json["temple"],
      templeSnapshot: json["templeSnapshot"] == null
          ? null
          : Snapshot.fromJson(json["templeSnapshot"]),
      dakshinaAmount: json["dakshinaAmount"],
      recommendedKit: json["recommendedKit"],
      bookingStatus: json["bookingStatus"],
      notes: json["notes"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      mandir: json["mandir"],
      mandirSnapshot: json["mandirSnapshot"] == null
          ? null
          : Snapshot.fromJson(json["mandirSnapshot"]),
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

class DatumDateAndTime {
  DatumDateAndTime({required this.dateAndTime});

  final List<DateAndTimeElement> dateAndTime;

  factory DatumDateAndTime.fromJson(Map<String, dynamic> json) {
    return DatumDateAndTime(
      dateAndTime: json["dateAndTime"] == null
          ? []
          : List<DateAndTimeElement>.from(
              json["dateAndTime"]!.map((x) => DateAndTimeElement.fromJson(x)),
            ),
    );
  }
}

class DateAndTimeElement {
  DateAndTimeElement({required this.date, required this.time});

  final String? date;
  final String? time;

  factory DateAndTimeElement.fromJson(Map<String, dynamic> json) {
    return DateAndTimeElement(date: json["date"], time: json["time"]);
  }
}

class Snapshot {
  Snapshot({
    required this.name,
    required this.image,
    required this.city,
    required this.state,
    required this.line1,
    required this.landmark,
  });

  final String? name;
  final String? image;
  final String? city;
  final String? state;
  final String? line1;
  final String? landmark;

  factory Snapshot.fromJson(Map<String, dynamic> json) {
    return Snapshot(
      name: json["name"],
      image: json["image"],
      city: json["city"],
      state: json["state"],
      line1: json["line1"],
      landmark: json["landmark"],
    );
  }
}

class Pandit {
  Pandit({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.profileImage,
    required this.ratingAverage,
    required this.yearsOfExperience,
    required this.languagesSpoken,
  });

  final String? id;
  final String? phone;
  final String? fullName;
  final String? profileImage;
  final double? ratingAverage;
  final int? yearsOfExperience;
  final List<String> languagesSpoken;

  factory Pandit.fromJson(Map<String, dynamic> json) {
    return Pandit(
      id: json["_id"],
      phone: json["phone"],
      fullName: json["fullName"],
      profileImage: json["profileImage"],
      ratingAverage: json["ratingAverage"],
      yearsOfExperience: json["yearsOfExperience"],
      languagesSpoken: json["languagesSpoken"] == null
          ? []
          : List<String>.from(json["languagesSpoken"]!.map((x) => x)),
    );
  }
}

class PanditDecision {
  PanditDecision({
    required this.samagriType,
    required this.rejectReasonType,
    required this.rejectReasonText,
    required this.note,
    required this.decidedAt,
  });

  final String? samagriType;
  final String? rejectReasonType;
  final String? rejectReasonText;
  final String? note;
  final dynamic decidedAt;

  factory PanditDecision.fromJson(Map<String, dynamic> json) {
    return PanditDecision(
      samagriType: json["samagriType"],
      rejectReasonType: json["rejectReasonType"],
      rejectReasonText: json["rejectReasonText"],
      note: json["note"],
      decidedAt: json["decidedAt"],
    );
  }
}

class Payment {
  Payment({
    required this.status,
    required this.method,
    required this.gateway,
    required this.transactionId,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.paidAt,
  });

  final String? status;
  final String? method;
  final String? gateway;
  final String? transactionId;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final DateTime? paidAt;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      status: json["status"],
      method: json["method"],
      gateway: json["gateway"],
      transactionId: json["transactionId"],
      razorpayOrderId: json["razorpayOrderId"],
      razorpayPaymentId: json["razorpayPaymentId"],
      razorpaySignature: json["razorpaySignature"],
      paidAt: DateTime.tryParse(json["paidAt"] ?? ""),
    );
  }
}

class Ritual {
  Ritual({required this.name, required this.description, required this.image});

  final String? name;
  final String? description;
  final String? image;

  factory Ritual.fromJson(Map<String, dynamic> json) {
    return Ritual(
      name: json["name"],
      description: json["description"],
      image: json["image"],
    );
  }
}

class RitualRef {
  RitualRef({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.durationHours,
    required this.status,
  });

  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final int? durationHours;
  final String? status;

  factory RitualRef.fromJson(Map<String, dynamic> json) {
    return RitualRef(
      id: json["_id"],
      title: json["title"],
      description: json["description"],
      image: json["image"],
      durationHours: json["durationHours"],
      status: json["status"],
    );
  }
}
