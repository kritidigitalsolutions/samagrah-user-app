class CreateOrderResModel {
  CreateOrderResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory CreateOrderResModel.fromJson(Map<String, dynamic> json) {
    return CreateOrderResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.itemTotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.currency,
    required this.razorpayOrder,
  });

  final int? itemTotal;
  final int? deliveryFee;
  final int? totalAmount;
  final String? currency;
  final RazorpayOrder? razorpayOrder;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      itemTotal: json["itemTotal"],
      deliveryFee: json["deliveryFee"],
      totalAmount: json["totalAmount"],
      currency: json["currency"],
      razorpayOrder: json["razorpayOrder"] == null
          ? null
          : RazorpayOrder.fromJson(json["razorpayOrder"]),
    );
  }
}

class RazorpayOrder {
  RazorpayOrder({
    required this.amount,
    required this.attempts,
    required this.id,
    required this.offerId,
    required this.status,
  });

  final int? amount;
  final int? attempts;
  final String? id;
  final dynamic offerId;
  final String? status;

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      amount: json["amount"],
      attempts: json["attempts"],
      id: json["id"],
      offerId: json["offer_id"],
      status: json["status"],
    );
  }
}
