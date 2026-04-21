class CreateOrderReqModel {
  final int deliveryFee;
  final List<VerifyItem> items;

  CreateOrderReqModel({required this.deliveryFee, required this.items});

  Map<String, dynamic> toJson() {
    return {
      "deliveryFee": deliveryFee,
      "items": items.map((e) => e.toJson()).toList(),
    };
  }
}

// =================== verify payment ===========================

class VerifyPaymentReqModel {
  final String paymentMethod;
  final int deliveryFee;
  final Address address;
  final List<VerifyItem> items;

  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  VerifyPaymentReqModel({
    required this.paymentMethod,
    required this.deliveryFee,
    required this.address,
    required this.items,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      "paymentMethod": paymentMethod,
      "deliveryFee": deliveryFee,
      "address": address.toJson(),
      "items": items.map((e) => e.toJson()).toList(),
      "razorpayOrderId": razorpayOrderId,
      "razorpayPaymentId": razorpayPaymentId,
      "razorpaySignature": razorpaySignature,
    };
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
