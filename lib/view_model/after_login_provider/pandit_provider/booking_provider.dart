import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:samagrah/model/response/pandit_res/pandit_booked_res_model.dart';
import 'package:samagrah/repo/pandit_repo.dart';

// Existing provider
final typeSelected = StateProvider<String>((ref) => "home");

// Repository provider
final panditRepoProvider = Provider((ref) => PanditRepo());

// API provider for fetching bookings
final panditBookingProvider = FutureProvider<PanditBookedResModel>((ref) async {
  final repo = ref.read(panditRepoProvider);
  return repo.getPnanditBooked();
});

// Provider to hold selected booking for details page
final selectedBookingProvider = StateProvider<Datum?>((ref) => null);
