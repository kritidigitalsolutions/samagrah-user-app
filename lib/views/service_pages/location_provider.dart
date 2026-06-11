import 'package:flutter_riverpod/legacy.dart';

class LocationModel {
  final String city;
  final String state;
  final String pincode; // ← add

  LocationModel({
    required this.city,
    required this.state,
    this.pincode = '', // ← add (optional, backward compatible)
  });
}

final locationProvider = StateProvider<LocationModel?>((ref) => null);
