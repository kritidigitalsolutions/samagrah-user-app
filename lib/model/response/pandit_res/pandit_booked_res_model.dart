import 'package:samagrah/model/response/pandit_res/pandit_res_model.dart';

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
    required this.cancellationRequests,
    required this.rescheduleRequests,
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
  final DatumAddress? address;
  final Temple? temple;
  final TempleSnapshot? templeSnapshot;
  final int? dakshinaAmount;
  final dynamic recommendedKit;
  final String? bookingStatus;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final List<CancellationRequest> cancellationRequests;
  final List<dynamic> rescheduleRequests;

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
          : DatumAddress.fromJson(json["address"]),
      temple: json["temple"] == null ? null : Temple.fromJson(json["temple"]),
      templeSnapshot: json["templeSnapshot"] == null
          ? null
          : TempleSnapshot.fromJson(json["templeSnapshot"]),
      dakshinaAmount: json["dakshinaAmount"],
      recommendedKit: json["recommendedKit"],
      bookingStatus: json["bookingStatus"],
      notes: json["notes"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      cancellationRequests: json["cancellationRequests"] == null
          ? []
          : List<CancellationRequest>.from(
              json["cancellationRequests"]!.map(
                (x) => CancellationRequest.fromJson(x),
              ),
            ),
      rescheduleRequests: json["rescheduleRequests"] == null
          ? []
          : List<dynamic>.from(json["rescheduleRequests"]!.map((x) => x)),
    );
  }
}

class DatumAddress {
  DatumAddress({
    required this.name,
    required this.phone,
    required this.secondPhone,
    required this.fullAddress,
    required this.email,
    required this.addressType,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String? name;
  final String? phone;
  final String? secondPhone;
  final String? fullAddress;
  final String? email;
  final String? addressType;
  final String? city;
  final String? state;
  final String? pincode;

  factory DatumAddress.fromJson(Map<String, dynamic> json) {
    return DatumAddress(
      name: json["name"],
      phone: json["phone"],
      secondPhone: json["secondPhone"],
      fullAddress: json["fullAddress"],
      email: json["email"],
      addressType: json["addressType"],
      city: json["city"],
      state: json["state"],
      pincode: json["pincode"],
    );
  }
}

class CancellationRequest {
  CancellationRequest({
    required this.reason,
    required this.notes,
    required this.requestedBy,
    required this.requestedAt,
    required this.id,
  });

  final String? reason;
  final String? notes;
  final String? requestedBy;
  final DateTime? requestedAt;
  final String? id;

  factory CancellationRequest.fromJson(Map<String, dynamic> json) {
    return CancellationRequest(
      reason: json["reason"],
      notes: json["notes"],
      requestedBy: json["requestedBy"],
      requestedAt: DateTime.tryParse(json["requestedAt"] ?? ""),
      id: json["_id"],
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

class Pandit {
  Pandit({
    required this.id,
    required this.phone,
    required this.fullName,
    required this.profileImage,
    required this.ratingAverage,
    required this.yearsOfExperience,
    required this.languagesSpoken,
    required this.poojaOfferings,
  });

  final String? id;
  final String? phone;
  final String? fullName;
  final String? profileImage;
  final double? ratingAverage;
  final int? yearsOfExperience;
  final List<String> languagesSpoken;
  final List<PoojaOffering> poojaOfferings;

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
      poojaOfferings: json["poojaOfferings"] == null
          ? []
          : List<PoojaOffering>.from(
              json["poojaOfferings"]!.map((x) => PoojaOffering.fromJson(x)),
            ),
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
    required this.transactionId,
    required this.gateway,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
    required this.paidAt,
  });

  final String? status;
  final String? method;
  final String? transactionId;
  final String? gateway;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final DateTime? paidAt;

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      status: json["status"],
      method: json["method"],
      transactionId: json["transactionId"],
      gateway: json["gateway"],
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

class Temple {
  Temple({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.contactPhone,
    required this.contactPerson,
    required this.address,
  });

  final String? id;
  final String? name;
  final String? image;
  final String? description;
  final String? contactPhone;
  final String? contactPerson;
  final TempleAddress? address;

  factory Temple.fromJson(Map<String, dynamic> json) {
    return Temple(
      id: json["_id"],
      name: json["name"],
      image: json["image"],
      description: json["description"],
      contactPhone: json["contactPhone"],
      contactPerson: json["contactPerson"],
      address: json["address"] == null
          ? null
          : TempleAddress.fromJson(json["address"]),
    );
  }
}

class TempleAddress {
  TempleAddress({
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

  factory TempleAddress.fromJson(Map<String, dynamic> json) {
    return TempleAddress(
      line1: json["line1"],
      line2: json["line2"],
      city: json["city"],
      state: json["state"],
      pinCode: json["pinCode"],
      landmark: json["landmark"],
    );
  }
}

class TempleSnapshot {
  TempleSnapshot({
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

  factory TempleSnapshot.fromJson(Map<String, dynamic> json) {
    return TempleSnapshot(
      name: json["name"],
      image: json["image"],
      city: json["city"],
      state: json["state"],
      line1: json["line1"],
      landmark: json["landmark"],
    );
  }
}
