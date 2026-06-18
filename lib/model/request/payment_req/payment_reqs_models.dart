class CreateOrderReqModel {
  final double deliveryFee;
  final List<VerifyItem> items;
  final String? couponCode;
  final String? offerId;
  final String? panditId;

  CreateOrderReqModel({
    required this.deliveryFee,
    required this.items,
    this.couponCode,
    this.offerId,
    this.panditId,
  });

  Map<String, dynamic> toJson() {
    return {
      "deliveryFee": deliveryFee,
      "items": items.map((e) => e.toJson()).toList(),
      "couponCode": couponCode,
      "offerId": offerId,
      "pandit_id": panditId,
    };
  }
}

// =================== verify payment ===========================

class VerifyPaymentReqModel {
  final String paymentMethod;
  final num deliveryFee;
  final num? walletAmount;
  final String? couponCode;
  final String? offerId;
  final Address address;
  final List<VerifyItem> items;
  final String? panditId;

  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;

  VerifyPaymentReqModel({
    required this.paymentMethod,
    required this.deliveryFee,
    required this.address,
    required this.items,
    this.walletAmount,
    this.couponCode,
    this.offerId,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.panditId,
  });

  Map<String, dynamic> toJson() {
    final data = {
      "paymentMethod": paymentMethod,
      "deliveryFee": deliveryFee,
      "address": address.toJson(),
      "items": items.map((e) => e.toJson()).toList(),
      "couponCode": couponCode,
      "offerId": offerId,
      "pandit_id": panditId,
    };

    if (razorpayOrderId != null && razorpayOrderId!.isNotEmpty) {
      data["razorpayOrderId"] = razorpayOrderId!;
    }

    if (razorpayPaymentId != null && razorpayPaymentId!.isNotEmpty) {
      data["razorpayPaymentId"] = razorpayPaymentId!;
    }

    if (razorpaySignature != null && razorpaySignature!.isNotEmpty) {
      data["razorpaySignature"] = razorpaySignature!;
    }

    if (paymentMethod == "WALLET") {
      data["walletAmount"] = walletAmount!;
    }

    return data;
  }
}

class Address {
  final String name;
  final String phone;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;

  Address({
    required this.name,
    required this.phone,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "phone": phone,
      "fullAddress": fullAddress,
      "city": city,
      "state": state,
      "pincode": pincode,
    };
  }
}

class VerifyItem {
  final String productId;

  final int quantity;

  VerifyItem({required this.productId, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {"productId": productId, "quantity": quantity};
  }
}
