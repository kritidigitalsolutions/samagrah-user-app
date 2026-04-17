import 'package:flutter_riverpod/legacy.dart';

class LocationModel {
  final String? city;
  final String? state;

  LocationModel({this.city, this.state});
}

final locationProvider = StateProvider<LocationModel?>((ref) => null);
