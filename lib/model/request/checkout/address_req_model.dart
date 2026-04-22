import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';

class AddressReqModel {
  final String addressType; // optional depending on API
  final Address address;

  AddressReqModel({required this.addressType, required this.address});

  // ✅ Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {"addressType": addressType, "address": address.toJson()};
  }
}
