import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';

class PanditCreateOrderReqModel {
  final String ritualId;
  final String bookingMode;
  final String panditId;
  final String? templeId;
  final DateAndTimeWrapper dateAndTime;
  final Address? address;
  final int price;

  PanditCreateOrderReqModel({
    required this.ritualId,
    required this.bookingMode,
    required this.panditId,
    required this.dateAndTime,
    this.address,
    required this.price,
    this.templeId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "ritualId": ritualId,
      "bookingMode": bookingMode,
      "panditId": panditId,
      "dateAndTime": dateAndTime.toJson(),
      "price": price,
    };

    // ✅ If home visit → send address
    if (bookingMode == "home" && address != null) {
      data["address"] = address!.toJson();
    }

    // ✅ If temple visit → send mandirId
    if (bookingMode == "temple" && templeId != null) {
      data["mandirId"] = templeId!;
    }

    return data;
  }
}

class DateAndTimeWrapper {
  final List<DateTimeSlot> dateAndTime;

  DateAndTimeWrapper({required this.dateAndTime});

  Map<String, dynamic> toJson() {
    return {"dateAndTime": dateAndTime.map((e) => e.toJson()).toList()};
  }
}

class DateTimeSlot {
  final String date;
  final String time;

  DateTimeSlot({required this.date, required this.time});

  Map<String, dynamic> toJson() {
    return {"date": date, "time": time};
  }
}
