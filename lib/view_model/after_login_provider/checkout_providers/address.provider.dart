import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/request/payment_req/payment_reqs_models.dart';

final addressProvider = StateProvider<Address?>((ref) => null);
final bookingItemProvider = StateProvider<List<VerifyItem>>((ref) => []);
final totalPrice = StateProvider<num>((ref) => 0);
